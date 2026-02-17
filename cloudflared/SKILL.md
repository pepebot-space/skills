---
name: cloudflared
description: "Create and manage Cloudflare Tunnel connections using the `cloudflared` CLI. Use this skill to authenticate, create tunnels, route DNS records, expose local services securely, and run persistent zero-trust service tunnels."
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

# Cloudflared Tunnel Skill

## Purpose
Use this skill to create secure Cloudflare Tunnels that expose local services to the internet without opening firewall ports.

---

# Authentication

Login to Cloudflare:

    cloudflared tunnel login

This opens a browser to authenticate the account.

---

# Create tunnel

Create tunnel:

    cloudflared tunnel create my-tunnel

List tunnels:

    cloudflared tunnel list

---

# Configure tunnel

Create config file:

    ~/.cloudflared/config.yml

Example:

    tunnel: my-tunnel
    credentials-file: ~/.cloudflared/my-tunnel.json

    ingress:
      - hostname: app.example.com
        service: http://localhost:8080
      - service: http_status:404

---

# Route DNS

Map hostname to tunnel:

    cloudflared tunnel route dns my-tunnel app.example.com

---

# Run tunnel

Start tunnel:

    cloudflared tunnel run my-tunnel

Run as service:

    sudo cloudflared service install

---

# Quick temporary tunnel

Expose local service quickly:

    cloudflared tunnel --url http://localhost:8080

---

# Automation workflows

## Expose internal app

1. Authenticate
2. Create tunnel
3. Route DNS
4. Run tunnel service
5. Monitor connectivity

## Multi-service routing

Add multiple ingress rules to config.yml for several services.

---

# Security rules

1. Prefer named tunnels over temporary tunnels
2. Store credentials securely
3. Restrict DNS routing to required domains
4. Use Cloudflare Access for authentication
5. Rotate tunnel credentials periodically

---

# Best practices

- Always run `cloudflared tunnel list` before creating new tunnels
- Prefer persistent service installation for production
- Use DNS routing instead of public IP exposure
- Monitor logs for connection failures
