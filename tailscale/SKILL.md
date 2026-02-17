---
name: tailscale-autonomous
description: "Manage secure infrastructure connectivity using the `tailscale` CLI. Use this skill for authentication, node discovery, remote SSH orchestration, subnet routing, service exposure, and autonomous multi-node infrastructure workflows."
metadata: {
  "pepebot": {
    "emoji": "🔐",
    "requires": {
      "bins": ["tailscale"]
    },
    "install": [
      {
        "id": "linux",
        "kind": "shell",
        "command": "curl -fsSL https://tailscale.com/install.sh | sh",
        "bins": ["tailscale"],
        "label": "Install Tailscale CLI (Linux)"
      },
      {
        "id": "brew",
        "kind": "brew",
        "formula": "tailscale",
        "bins": ["tailscale"],
        "label": "Install Tailscale CLI (brew)"
      }
    ]
  }
}
---

# Tailscale Autonomous Infrastructure Skill

## Purpose
Use this skill to securely connect and orchestrate infrastructure nodes using Tailscale mesh networking.

---

# Authentication

Login:

    sudo tailscale up

Check login:

    tailscale status

Logout:

    sudo tailscale logout

---

# Node discovery

List connected nodes:

    tailscale status

Show node IP:

    tailscale ip

Retrieve node JSON (automation use):

    tailscale status --json

---

# Remote SSH orchestration

Connect to node:

    tailscale ssh user@hostname

Execute remote command:

    tailscale ssh user@hostname "uptime"

Multi-node execution example:

    for h in host1 host2 host3; do
        tailscale ssh user@$h "sudo systemctl restart docker"
    done

---

# Service exposure

Serve local service internally:

    tailscale serve 8080

Expose publicly:

    tailscale funnel 8080

Disable funnel:

    tailscale funnel --disable

---

# Subnet routing

Advertise subnet:

    sudo tailscale up --advertise-routes=192.168.1.0/24

Approve routes from admin console after advertising.

---

# Exit node usage

Advertise exit node:

    sudo tailscale up --advertise-exit-node

Use exit node:

    sudo tailscale up --exit-node=<node-ip>

---

# Automation workflows

## Cluster deployment workflow

1. Discover nodes using `tailscale status`
2. Retrieve internal IPs
3. Execute remote deployment commands via `tailscale ssh`
4. Verify service health
5. Expose services using `tailscale serve`

## Remote maintenance workflow

1. List nodes
2. Execute updates:

        tailscale ssh user@node "sudo apt update && sudo apt upgrade -y"

3. Restart services if required

---

# Security rules

1. Verify node identity before SSH
2. Prefer internal Tailscale IP instead of public IP
3. Confirm funnel exposure before enabling internet access
4. Log all executed remote operations
5. Disable unused advertised routes

---

# Best practices

- Always check `tailscale status` before orchestration
- Prefer SSH orchestration over open ports
- Use subnet routing instead of VPN tunnels where possible
- Rotate authentication periodically
