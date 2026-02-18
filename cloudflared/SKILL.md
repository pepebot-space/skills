---
name: cloudflared
description: "Expose local services to the internet using Cloudflare Tunnel (`cloudflared`). Create named tunnels, route DNS to subdomains, run persistent tunnels, and manage tunnel lifecycle — all automated by the AI agent."
metadata: {
  "pepebot": {
    "emoji": "☁️",
    "requires": {
      "bins": ["cloudflared"]
    },
    "install": [
      {
        "id": "linux",
        "kind": "shell",
        "command": "curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o cloudflared && chmod +x cloudflared && sudo mv cloudflared /usr/local/bin/",
        "bins": ["cloudflared"],
        "label": "Install cloudflared CLI (Linux)"
      },
      {
        "id": "brew",
        "kind": "brew",
        "formula": "cloudflared",
        "bins": ["cloudflared"],
        "label": "Install cloudflared (brew)"
      }
    ]
  }
}
---

# Cloudflared — Expose Local Services via Cloudflare Tunnel

This skill allows Pepebot to expose local services to the internet using **Cloudflare Tunnel** (`cloudflared`). It manages named tunnel creation, DNS routing to subdomains `*.yourdomain.com`, and running tunnel processes.

## Prerequisites

1. `cloudflared` must be installed on the host
2. `cloudflared` must be authenticated (`cloudflared tunnel login`) with access to your DNS zone

## Configuration

- **Base Domain:** `yourdomain.com` (replace with your domain registered on Cloudflare)
- **Subdomain Pattern:** `<subdomain>.yourdomain.com`

---

## 1. Start Tunnel (Expose Port)

Create a new tunnel, register DNS, and run it.

**Steps (Automated by AI):**

### A. Determine Subdomain
If the user doesn't specify one, generate a *readable* name:
- Examples: `happy-frog`, `red-table`, `cool-api`

### B. Determine Target
Parse user input:
- `3000` → `localhost:3000`
- `192.168.1.5:80` → `192.168.1.5:80`
- `http://localhost:8080` → use as-is

### C. Execute Commands

**Create Named Tunnel:**
```bash
cloudflared tunnel create <SUBDOMAIN>
```
*(Save the tunnel UUID from JSON or text output)*

**Route DNS:**
```bash
cloudflared tunnel route dns <SUBDOMAIN> <SUBDOMAIN>.yourdomain.com
```

**Run Tunnel (Background):**
Use `nohup` so the process persists:
```bash
nohup cloudflared tunnel run --url <TARGET> <SUBDOMAIN> > /tmp/tunnel-<SUBDOMAIN>.log 2>&1 &
echo $! > /tmp/tunnel-<SUBDOMAIN>.pid
```
*Note: `--url` directs traffic from the named tunnel to the local service.*

### D. Verify
Tell the user the access URL:
```
https://<SUBDOMAIN>.yourdomain.com
```

---

## 2. List Active Tunnels

View running tunnels:

**Via Cloudflare:**
```bash
cloudflared tunnel list
```

**Via PID files (tunnels started by this skill):**
```bash
ls -l /tmp/tunnel-*.pid
```

**Check process status:**
```bash
for f in /tmp/tunnel-*.pid; do
  name=$(basename "$f" .pid | sed 's/tunnel-//')
  pid=$(cat "$f")
  if kill -0 "$pid" 2>/dev/null; then
    echo "✅ $name (PID: $pid) - running"
  else
    echo "❌ $name (PID: $pid) - stopped"
  fi
done
```

---

## 3. Stop & Delete Tunnel

Stop a tunnel and clean up its records.

### Stop Process
```bash
kill $(cat /tmp/tunnel-<SUBDOMAIN>.pid) && rm /tmp/tunnel-<SUBDOMAIN>.pid
```

### Remove DNS Route
```bash
cloudflared tunnel route dns delete <SUBDOMAIN>
```

### Delete Tunnel
```bash
cloudflared tunnel delete <SUBDOMAIN>
```

---

## 4. Quick Temporary Tunnel

Expose a service quickly without a named tunnel (auto-generated URL from Cloudflare):
```bash
cloudflared tunnel --url http://localhost:8080
```

---

## 5. Config File (Multi-Service)

To route multiple services at once, create a config file:

**`~/.cloudflared/config.yml`:**
```yaml
tunnel: my-tunnel
credentials-file: ~/.cloudflared/<TUNNEL-UUID>.json

ingress:
  - hostname: app.yourdomain.com
    service: http://localhost:3000
  - hostname: api.yourdomain.com
    service: http://localhost:8080
  - hostname: grafana.yourdomain.com
    service: http://localhost:3001
  - service: http_status:404
```

**Run with config:**
```bash
cloudflared tunnel run my-tunnel
```

**Install as system service:**
```bash
sudo cloudflared service install
```

---

## 6. Authentication

Login to Cloudflare (opens browser):
```bash
cloudflared tunnel login
```

Check login status:
```bash
ls ~/.cloudflared/cert.pem && echo "Authenticated" || echo "Not authenticated"
```

---

## Error Handling

| Error | Solution |
|-------|----------|
| `cloudflared: command not found` | Install cloudflared (see install options in header) |
| `permissions` / `login required` | Run `cloudflared tunnel login` in the terminal |
| `tunnel already exists` | Use `cloudflared tunnel list` and pick a different name |
| `DNS route conflict` | Delete old route: `cloudflared tunnel route dns delete <name>` |
| `connection refused` | Ensure the local service is running on the target port |

---

## Security Rules

1. Prefer named tunnels over temporary tunnels
2. Store credentials securely (`~/.cloudflared/`)
3. Restrict DNS routing to only required domains
4. Use [Cloudflare Access](https://developers.cloudflare.com/cloudflare-one/policies/access/) for authentication
5. Rotate tunnel credentials periodically

---

## Best Practices

- Always run `cloudflared tunnel list` before creating a new tunnel
- Use named tunnels for production, quick tunnels for development
- Store PID files at `/tmp/tunnel-<name>.pid` for process tracking
- Use config files for multi-service routing
- Monitor logs: `tail -f /tmp/tunnel-<SUBDOMAIN>.log`
- Install as a system service for persistent tunnels
