---
name: vercel-deploy
description: "Deploy applications to Vercel with edge functions, serverless, and ISR."
metadata: {
  "pepebot": {
    "emoji": "▲",
    "requires": {
      "bins": ["vercel"]
    },
    "install": [
      {
        "id": "npm",
        "kind": "npm",
        "package": "vercel",
        "bins": ["vercel"],
        "label": "Install Vercel CLI (npm)"
      }
    ]
  }
}
---

# Vercel Deploy

Deploy applications to Vercel with edge functions, serverless, and ISR.

## When to Use

- Deploying Next.js applications
- Setting up edge functions
- Configuring ISR (Incremental Static Regeneration)
- Serverless deployments

## Source

This skill references patterns from [Vercel's agent-skills](https://github.com/vercel-labs/agent-skills).
