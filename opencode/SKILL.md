---
name: opencode
description: "Interact with OpenCode using the `opencode` CLI. Use `opencode run`, `opencode agent`, `opencode mcp`, and `opencode models` to execute automation workflows, manage agents, configure tools, and run headless coding tasks."
metadata: {
  "pepebot": {
    "emoji": "🤖",
    "requires": {
      "bins": ["opencode"]
    },
    "install": [
      {
        "id": "install-script",
        "kind": "shell",
        "command": "curl -fsSL https://opencode.ai/install | bash",
        "bins": ["opencode"],
        "label": "Install OpenCode CLI (install script)"
      },
      {
        "id": "npm",
        "kind": "npm",
        "package": "opencode-ai",
        "bins": ["opencode"],
        "label": "Install OpenCode CLI (npm)"
      },
      {
        "id": "brew",
        "kind": "brew",
        "formula": "opencode",
        "bins": ["opencode"],
        "label": "Install OpenCode CLI (brew)"
      }
    ]
  }
}
---

# OpenCode CLI Skill

## When to use
Use this skill when:
- Running OpenCode automation workflows
- Executing coding tasks via CLI
- Managing OpenCode agents
- Running CI/CD automation using OpenCode
- Connecting MCP tools
- Listing or selecting models

---

## Core usage

Run interactive TUI:

    opencode

Run task headless:

    opencode run "your task"

Continue last session:

    opencode --continue

---

## Agent commands

Create agent:

    opencode agent create

List agents:

    opencode agent list

Run agent:

    opencode --agent <agent-name>

---

## MCP tools

Add MCP server:

    opencode mcp add

List MCP:

    opencode mcp list

Debug MCP:

    opencode mcp debug <name>

---

## Models

List available models:

    opencode models

---

## Rules for agent
1. Prefer `opencode run` for automation
2. Prefer `opencode agent` for reusable workflows
3. Always verify CLI exists before execution
4. Provide exact runnable commands
5. Confirm destructive actions before execution

