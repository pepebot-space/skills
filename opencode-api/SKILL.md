---
name: opencode-api
description: "Interact with OpenCode programmatically via its HTTP server API. Start a headless server with `opencode serve`, then use REST endpoints to manage sessions, send prompts, search files, control agents, and stream events — ideal for automation, CI/CD, and building custom AI coding workflows."
metadata: {
  "pepebot": {
    "emoji": "🔌",
    "requires": {
      "bins": ["opencode", "curl"]
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

# OpenCode Server API

Interact with OpenCode programmatically via its HTTP server. Start a headless server, then use REST API endpoints to create sessions, send prompts, manage files, and stream events.

## When to Use

- Automating coding tasks via HTTP instead of CLI
- Building custom AI coding workflows
- CI/CD pipeline integration
- Driving OpenCode from another agent or script
- Managing multiple sessions programmatically

---

## Start Server

```bash
opencode serve [--port <number>] [--hostname <string>] [--cors <origin>]
```

### Options

| Flag | Default | Description |
|------|---------|-------------|
| `--port` | `4096` | HTTP port |
| `--hostname` | `127.0.0.1` | Bind address |
| `--mdns` | `false` | Enable mDNS discovery |
| `--mdns-domain` | `opencode.local` | mDNS domain |
| `--cors` | `[]` | Allowed CORS origins (repeatable) |

### Examples

```bash
# Start on default port 4096
opencode serve

# Custom port with CORS
opencode serve --port 8080 --cors http://localhost:5173 --cors https://app.example.com

# Background mode
nohup opencode serve --port 4096 > /tmp/opencode-server.log 2>&1 &
```

### Authentication

Set `OPENCODE_SERVER_PASSWORD` to protect with HTTP basic auth:

```bash
OPENCODE_SERVER_PASSWORD=your-password opencode serve
```

- Username defaults to `opencode`, override with `OPENCODE_SERVER_USERNAME`
- Applies to both `opencode serve` and `opencode web`

### OpenAPI Spec

The server publishes an OpenAPI 3.1 spec at:

```
http://<hostname>:<port>/doc
```

Use this to generate SDK clients or inspect types in a Swagger explorer.

---

## Core Workflow

The typical automation flow:

```
1. Start server        →  opencode serve
2. Create session      →  POST /session
3. Send prompt         →  POST /session/:id/message
4. Stream events       →  GET  /event (SSE)
5. Check results       →  GET  /session/:id/message
6. View diffs          →  GET  /session/:id/diff
```

---

## API Reference

Base URL: `http://localhost:4096`

### Health Check

```bash
curl http://localhost:4096/global/health
```
Response: `{ "healthy": true, "version": "string" }`

---

### Sessions

**List all sessions:**
```bash
curl http://localhost:4096/session
```

**Create a new session:**
```bash
curl -X POST http://localhost:4096/session \
  -H "Content-Type: application/json" \
  -d '{"title": "Fix login bug"}'
```

**Get session by ID:**
```bash
curl http://localhost:4096/session/<session-id>
```

**Get session status (all sessions):**
```bash
curl http://localhost:4096/session/status
```

**Delete session:**
```bash
curl -X DELETE http://localhost:4096/session/<session-id>
```

**Update session title:**
```bash
curl -X PATCH http://localhost:4096/session/<session-id> \
  -H "Content-Type: application/json" \
  -d '{"title": "New title"}'
```

**Fork session (branch from a message):**
```bash
curl -X POST http://localhost:4096/session/<session-id>/fork \
  -H "Content-Type: application/json" \
  -d '{"messageID": "<message-id>"}'
```

**Abort running session:**
```bash
curl -X POST http://localhost:4096/session/<session-id>/abort
```

**Get todos from session:**
```bash
curl http://localhost:4096/session/<session-id>/todo
```

**Get file diffs from session:**
```bash
curl http://localhost:4096/session/<session-id>/diff
```

**Revert changes:**
```bash
curl -X POST http://localhost:4096/session/<session-id>/revert \
  -H "Content-Type: application/json" \
  -d '{"messageID": "<message-id>"}'
```

**Share session:**
```bash
curl -X POST http://localhost:4096/session/<session-id>/share
```

---

### Messages (Prompts)

**Send a prompt (synchronous):**
```bash
curl -X POST http://localhost:4096/session/<session-id>/message \
  -H "Content-Type: application/json" \
  -d '{
    "parts": [{"type": "text", "text": "Fix the login bug in auth.ts"}]
  }'
```

**Send a prompt (async — returns 204 immediately):**
```bash
curl -X POST http://localhost:4096/session/<session-id>/prompt_async \
  -H "Content-Type: application/json" \
  -d '{
    "parts": [{"type": "text", "text": "Refactor the database module"}]
  }'
```

**Send prompt with specific model/agent:**
```bash
curl -X POST http://localhost:4096/session/<session-id>/message \
  -H "Content-Type: application/json" \
  -d '{
    "model": "anthropic/claude-sonnet-4-20250514",
    "agent": "coder",
    "parts": [{"type": "text", "text": "Add unit tests for utils.ts"}]
  }'
```

**Get all messages in a session:**
```bash
curl http://localhost:4096/session/<session-id>/message
```

**Get specific message:**
```bash
curl http://localhost:4096/session/<session-id>/message/<message-id>
```

**Run a shell command via session:**
```bash
curl -X POST http://localhost:4096/session/<session-id>/shell \
  -H "Content-Type: application/json" \
  -d '{"agent": "coder", "command": "npm test"}'
```

**Run a slash command:**
```bash
curl -X POST http://localhost:4096/session/<session-id>/command \
  -H "Content-Type: application/json" \
  -d '{"command": "compact", "arguments": ""}'
```

**Handle permission requests:**
```bash
curl -X POST http://localhost:4096/session/<session-id>/permissions/<permission-id> \
  -H "Content-Type: application/json" \
  -d '{"response": "allow", "remember": true}'
```

---

### Files & Search

**Search file contents (grep):**
```bash
curl "http://localhost:4096/find?pattern=TODO"
```

**Find files by name (fuzzy):**
```bash
curl "http://localhost:4096/find/file?query=auth&type=file&limit=10"
```

Query parameters for `/find/file`:
- `query` (required) — search string (fuzzy match)
- `type` (optional) — `"file"` or `"directory"`
- `directory` (optional) — override project root
- `limit` (optional) — max results (1–200)

**Find symbols:**
```bash
curl "http://localhost:4096/find/symbol?query=handleLogin"
```

**List directory contents:**
```bash
curl "http://localhost:4096/file?path=src/"
```

**Get file content:**
```bash
curl "http://localhost:4096/file/content?path=src/auth.ts"
```

**Get file status (git status):**
```bash
curl http://localhost:4096/file/status
```

---

### Project & VCS

**Get current project info:**
```bash
curl http://localhost:4096/project/current
```

**List all projects:**
```bash
curl http://localhost:4096/project
```

**Get path info:**
```bash
curl http://localhost:4096/path
```

**Get VCS (git) info:**
```bash
curl http://localhost:4096/vcs
```

---

### Config

**Get current config:**
```bash
curl http://localhost:4096/config
```

**Update config:**
```bash
curl -X PATCH http://localhost:4096/config \
  -H "Content-Type: application/json" \
  -d '{"theme": "dark"}'
```

**List available providers:**
```bash
curl http://localhost:4096/config/providers
```

---

### Providers

**Get all providers and connection status:**
```bash
curl http://localhost:4096/provider
```

**Get auth methods per provider:**
```bash
curl http://localhost:4096/provider/auth
```

**OAuth authorize:**
```bash
curl -X POST http://localhost:4096/provider/<provider-id>/oauth/authorize
```

---

### Agents

**List available agents:**
```bash
curl http://localhost:4096/agent
```

---

### Commands

**List available slash commands:**
```bash
curl http://localhost:4096/command
```

---

### MCP, LSP & Formatters

**List MCP servers:**
```bash
curl http://localhost:4096/mcp
```

**Add MCP server:**
```bash
curl -X POST http://localhost:4096/mcp \
  -H "Content-Type: application/json" \
  -d '{"name": "my-mcp", "config": {}}'
```

**List LSP servers:**
```bash
curl http://localhost:4096/lsp
```

**List formatters:**
```bash
curl http://localhost:4096/formatter
```

---

### Tools (Experimental)

**List tool IDs:**
```bash
curl http://localhost:4096/experimental/tool/ids
```

**List tools for provider/model:**
```bash
curl "http://localhost:4096/experimental/tool?provider=anthropic&model=claude-sonnet-4-20250514"
```

---

### Events (Server-Sent Events)

Stream real-time events from the server:

```bash
curl -N http://localhost:4096/event
```

Events include `server.connected` and session-related updates. Use SSE to monitor prompt progress in real-time.

---

### TUI Control

Drive the OpenCode TUI remotely (used by IDE plugins):

```bash
# Append text to prompt input
curl -X POST http://localhost:4096/tui/append-prompt

# Submit the current prompt
curl -X POST http://localhost:4096/tui/submit-prompt

# Clear prompt
curl -X POST http://localhost:4096/tui/clear-prompt

# Execute a command
curl -X POST http://localhost:4096/tui/execute-command \
  -H "Content-Type: application/json" \
  -d '{"command": "compact"}'

# Show toast notification
curl -X POST http://localhost:4096/tui/show-toast \
  -H "Content-Type: application/json" \
  -d '{"title": "Done", "message": "Task completed", "variant": "success"}'

# Open panels
curl -X POST http://localhost:4096/tui/open-help
curl -X POST http://localhost:4096/tui/open-sessions
curl -X POST http://localhost:4096/tui/open-themes
curl -X POST http://localhost:4096/tui/open-models
```

---

### Logging

```bash
curl -X POST http://localhost:4096/log \
  -H "Content-Type: application/json" \
  -d '{"service": "my-script", "level": "info", "message": "Task started"}'
```

---

### Instance

**Dispose instance (shutdown):**
```bash
curl -X POST http://localhost:4096/instance/dispose
```

---

## Example: Full Automation Script

```bash
#!/bin/bash
# Automate a coding task via OpenCode API
BASE="http://localhost:4096"

# 1. Check health
curl -s "$BASE/global/health" | jq .

# 2. Create session
SESSION=$(curl -s -X POST "$BASE/session" \
  -H "Content-Type: application/json" \
  -d '{"title": "Auto: Fix login bug"}' | jq -r '.id')
echo "Session: $SESSION"

# 3. Send prompt
curl -s -X POST "$BASE/session/$SESSION/message" \
  -H "Content-Type: application/json" \
  -d '{
    "parts": [{"type": "text", "text": "Find and fix the login bug in src/auth.ts. The issue is that expired tokens are not being refreshed."}]
  }' | jq .

# 4. Check diffs
curl -s "$BASE/session/$SESSION/diff" | jq .

# 5. Check todos
curl -s "$BASE/session/$SESSION/todo" | jq .
```

---

## Best Practices

- Always check `/global/health` before sending requests
- Use `prompt_async` for long-running tasks, then poll via events or messages
- Stream `/event` (SSE) to monitor progress in real-time
- Use sessions to organize tasks — one session per logical task
- Set `OPENCODE_SERVER_PASSWORD` when exposing the server beyond localhost
- Use the OpenAPI spec at `/doc` to generate typed SDKs
- Fork sessions to experiment without losing history
