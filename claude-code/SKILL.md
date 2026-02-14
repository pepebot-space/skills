---
name: claude-code
description: "Interact with Claude Code using the `claude` CLI. Use `claude`, `claude run`, `claude mcp`, and `claude doctor` to execute coding agents, manage MCP tools, and run autonomous development workflows."
metadata: {
  "pepebot": {
    "emoji": "🧠",
    "requires": {
      "bins": ["claude"]
    },
    "install": [
      {
        "id": "native-install",
        "kind": "shell",
        "command": "curl -fsSL https://claude.ai/install.sh | bash",
        "bins": ["claude"],
        "label": "Install Claude Code CLI (native)"
      },
      {
        "id": "npm",
        "kind": "npm",
        "package": "@anthropic-ai/claude-code",
        "bins": ["claude"],
        "label": "Install Claude Code CLI (npm)"
      },
      {
        "id": "brew",
        "kind": "brew",
        "formula": "claude-code",
        "bins": ["claude"],
        "label": "Install Claude Code CLI (brew)"
      }
    ]
  }
}
---

# Claude Code CLI Skill

## When to use
Use this skill when:
- Running Claude Code terminal agents
- Performing autonomous coding tasks
- Running repository analysis or fixes
- Configuring MCP tools
- Running coding workflows via CLI

---

## Core commands

Start Claude Code interactive session:

    claude

Run headless task:

    claude run "task description"

Verify installation:

    claude doctor

Show help:

    claude --help

---

## MCP tools

Add MCP server:

    claude mcp add

List MCP servers:

    claude mcp list

---

## Rules for agent
1. Prefer `claude run` for automation workflows
2. Verify binary availability before execution
3. Provide exact runnable shell commands
4. Ask confirmation before destructive operations
5. Prefer MCP integration when external services are required

