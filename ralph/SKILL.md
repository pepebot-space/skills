---
name: ralph
description: "Autonomous AI agent loop that runs coding tools (Amp, Claude Code, Gemini CLI, or OpenCode) repeatedly until all PRD items are complete. Use `ralph.sh` to deploy long-running autonomous development tasks, manage feature branches, track progress via prd.json, and auto-archive completed runs."
metadata: {
  "pepebot": {
    "emoji": "🔁",
    "requires": {
      "bins": ["jq", "git"]
    },
    "install": [
      {
        "id": "brew-jq",
        "kind": "brew",
        "formula": "jq",
        "bins": ["jq"],
        "label": "Install jq (brew)"
      },
      {
        "id": "apt-jq",
        "kind": "shell",
        "command": "sudo apt-get install -y jq",
        "bins": ["jq"],
        "label": "Install jq (apt)"
      }
    ]
  }
}
---

# Ralph — Autonomous AI Agent Loop

Ralph is an autonomous AI agent loop that runs AI coding tools (Amp, Claude Code, Gemini CLI, or OpenCode) repeatedly until all PRD (Product Requirements Document) items are complete. Each iteration is a fresh instance with clean context. Memory persists via git history, `progress.txt`, and `prd.json`.

Based on [Geoffrey Huntley's Ralph pattern](https://ghuntley.com/ralph/).

## How It Works

```
┌─────────────────────────────────────────────┐
│  ralph.sh starts iteration loop             │
│                                             │
│  ┌──────────────────────────────────┐       │
│  │ 1. Read prd.json                 │       │
│  │ 2. Read progress.txt (patterns)  │       │
│  │ 3. Checkout correct branch       │       │
│  │ 4. Pick highest priority story   │       │
│  │    where passes: false           │       │
│  │ 5. Implement the story           │       │
│  │ 6. Run quality checks            │       │
│  │ 7. Commit if checks pass         │       │
│  │ 8. Update prd.json (passes:true) │       │
│  │ 9. Append to progress.txt        │       │
│  │ 10. Update AGENTS.md             │       │
│  └──────────────┬───────────────────┘       │
│                 │                            │
│     All stories done? ──Yes──► COMPLETE      │
│          │No                                 │
│          └─── Next iteration ───┘            │
└─────────────────────────────────────────────┘
```

## Setup

> **Note:** This skill includes all required scripts in the `scripts/` directory:
> `ralph.sh`, `prompt.md`, `CLAUDE.md`, and `prd.json.example`.

### Option 1: Copy from This Skill to Your Project

```bash
# From your project root
mkdir -p scripts/ralph

# Copy all ralph files from this skill
cp /path/to/skills/ralph/scripts/* scripts/ralph/

chmod +x scripts/ralph/ralph.sh
```

### Option 2: Clone from GitHub

```bash
git clone https://github.com/snarktank/ralph.git
cd ralph
chmod +x ralph.sh
```

## Usage

```bash
# Using Amp (default)
./ralph.sh [max_iterations]
./ralph.sh 20

# Using Claude Code
./ralph.sh --tool claude [max_iterations]
./ralph.sh --tool claude 15

# Using Gemini CLI
./ralph.sh --tool gemini 20

# Using OpenCode
./ralph.sh --tool opencode 20

# Default: 10 iterations with Amp
./ralph.sh
```

### Supported Tools

| Tool | CLI Command | Flag |
|------|-------------|------|
| [Amp](https://ampcode.com) | `amp --dangerously-allow-all` | `--tool amp` (default) |
| [Claude Code](https://docs.anthropic.com/en/docs/claude-code) | `claude --dangerously-skip-permissions --print` | `--tool claude` |
| [Gemini CLI](https://github.com/google-gemini/gemini-cli) | `gemini -p` | `--tool gemini` |
| [OpenCode](https://opencode.ai) | `opencode run` | `--tool opencode` |

## Workflow

### 1. Create a PRD

Write a Product Requirements Document describing the feature you want built. Use detailed user stories with acceptance criteria.

### 2. Create prd.json

Convert your PRD into the Ralph JSON format:

```json
{
  "project": "MyApp",
  "branchName": "ralph/feature-name",
  "description": "Feature Description",
  "userStories": [
    {
      "id": "US-001",
      "title": "Add priority field to database",
      "description": "As a developer, I need to store task priority so it persists across sessions.",
      "acceptanceCriteria": [
        "Add priority column to tasks table: 'high' | 'medium' | 'low' (default 'medium')",
        "Generate and run migration successfully",
        "Typecheck passes"
      ],
      "priority": 1,
      "passes": false,
      "notes": ""
    },
    {
      "id": "US-002",
      "title": "Display priority indicator on task cards",
      "description": "As a user, I want to see task priority at a glance.",
      "acceptanceCriteria": [
        "Each task card shows colored priority badge (red=high, yellow=medium, gray=low)",
        "Priority visible without hovering or clicking",
        "Typecheck passes",
        "Verify in browser using dev-browser skill"
      ],
      "priority": 2,
      "passes": false,
      "notes": ""
    }
  ]
}
```

### 3. Run Ralph

```bash
./ralph.sh --tool claude 20
```

Ralph will autonomously iterate through all user stories until every story has `passes: true`.

## prd.json Schema

```yaml
project: string          # Project name
branchName: string       # Git branch (e.g., "ralph/my-feature")
description: string      # Feature description

userStories[]:
  id: string             # Story ID (e.g., "US-001")
  title: string          # Short title
  description: string    # User story format description
  acceptanceCriteria:     # Array of criteria strings
    - string
  priority: number       # Execution order (1 = first)
  passes: boolean        # true when completed by Ralph
  notes: string          # Optional notes / learnings
```

## Key Files

| File | Purpose |
|------|---------|
| `ralph.sh` | Main loop script — accepts `--tool amp\|claude` and `max_iterations` |
| `prompt.md` | Prompt template for Amp |
| `CLAUDE.md` | Prompt template for Claude Code |
| `prd.json` | PRD with user stories — tracks `passes` state |
| `progress.txt` | Accumulated learnings across iterations |
| `AGENTS.md` | Reusable patterns discovered during execution |
| `archive/` | Auto-archived previous runs |

## Critical Concepts

### Each Iteration = Fresh Context
Each iteration spawns a new AI instance with clean context. The only memory between iterations is:
- **Git history** — commits from previous iterations
- **progress.txt** — learnings and codebase patterns
- **prd.json** — which stories are done

### Right-Sized Stories
Each story should be small enough to complete in one context window:

**Good (right-sized):**
- Add a database column and migration
- Add a UI component to an existing page
- Update a server action with new logic
- Add a filter dropdown to a list

**Too big (split these):**
- "Build the entire dashboard"
- "Add authentication"
- "Refactor the API"

### AGENTS.md Updates
After each iteration, Ralph updates `AGENTS.md` with reusable patterns:

```markdown
# AGENTS.md
- This codebase uses X for Y
- Do not forget to update Z when changing W
- The settings panel is in component X
- Tests require dev server running on PORT 3000
```

### Progress Tracking
Ralph appends to `progress.txt` after each story:

```markdown
## [Date/Time] - US-001
- What was implemented
- Files changed
- **Learnings for future iterations:**
  - Patterns discovered
  - Gotchas encountered
  - Useful context

## Codebase Patterns (consolidated at top)
- Use `sql<number>` template for aggregations
- Always use `IF NOT EXISTS` for migrations
```

### Stop Condition
When all stories pass, Ralph outputs `<promise>COMPLETE</promise>` and exits.

### Auto-Archiving
When you start a new feature (different `branchName`), Ralph automatically archives the previous run to `archive/YYYY-MM-DD-feature-name/`.

## Debugging

```bash
# See which stories are done
cat prd.json | jq '.userStories[] | {id, title, passes}'

# See learnings from previous iterations
cat progress.txt

# Check git history
git log --oneline -10
```

## Example: Full Feature Workflow

```bash
# 1. Create your prd.json
cat > prd.json << 'EOF'
{
  "project": "TaskApp",
  "branchName": "ralph/add-search",
  "description": "Add search functionality to task list",
  "userStories": [
    {
      "id": "US-001",
      "title": "Add search input component",
      "description": "As a user, I want a search bar above the task list.",
      "acceptanceCriteria": [
        "Search input renders above task list",
        "Placeholder text: 'Search tasks...'",
        "Typecheck passes"
      ],
      "priority": 1,
      "passes": false,
      "notes": ""
    },
    {
      "id": "US-002",
      "title": "Implement search filtering",
      "description": "As a user, I want the task list filtered as I type.",
      "acceptanceCriteria": [
        "Tasks filter in real-time as user types",
        "Search matches title and description",
        "Empty state shows 'No tasks match your search'",
        "Typecheck passes"
      ],
      "priority": 2,
      "passes": false,
      "notes": ""
    }
  ]
}
EOF

# 2. Run Ralph with Claude Code, 15 iterations max
./ralph.sh --tool claude 15

# 3. Check status anytime
cat prd.json | jq '.userStories[] | {id, title, passes}'
```

## PRD-to-JSON Conversion Rules

When converting a PRD markdown to `prd.json`:

1. **Each user story → one JSON entry**
2. **IDs**: Sequential (US-001, US-002, ...)
3. **Priority**: Based on dependency order, then document order
4. **All stories**: `passes: false` and empty `notes`
5. **branchName**: Derive from feature name, kebab-case, prefixed with `ralph/`
6. **Always add**: "Typecheck passes" to every story's acceptance criteria

### Story Ordering: Dependencies First

Stories execute in priority order. Earlier stories must not depend on later ones:

1. Schema/database changes (migrations)
2. Server actions / backend logic
3. UI components that use the backend
4. Dashboard/summary views that aggregate data

### Acceptance Criteria: Must Be Verifiable

**Good (verifiable):**
- "Add `status` column to tasks table with default 'pending'"
- "Filter dropdown has options: All, Active, Completed"
- "Clicking delete shows confirmation dialog"

**Bad (vague):**
- "Works correctly"
- "Good UX"
- "Handles edge cases"

For UI stories, always include: `"Verify in browser using dev-browser skill"`

### Splitting Large PRDs

If a PRD has big features, split them into focused stories:

**Original:** "Add user notification system"

**Split into:**
1. US-001: Add notifications table to database
2. US-002: Create notification service
3. US-003: Add notification bell icon to header
4. US-004: Create notification dropdown panel
5. US-005: Add mark-as-read functionality
6. US-006: Add notification preferences page

> **Tip**: Use the [prd](../prd) skill to generate a PRD first, then convert it.

## Best Practices

- **Small stories**: Each story should be completable in one AI context window
- **Acceptance criteria**: Be specific — include "Typecheck passes", "Verify in browser"
- **Priority ordering**: Set priorities so dependencies are built first
- **Quality gates**: Ralph only commits when quality checks pass
- **Branch naming**: Use `ralph/feature-name` convention for feature branches
- **Review progress**: Check `progress.txt` and `git log` between runs
- **Customize prompts**: Edit `prompt.md` or `CLAUDE.md` for project-specific conventions
