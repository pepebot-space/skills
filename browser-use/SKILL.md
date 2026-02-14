---
name: browser-use
description: "Automate browser interactions using the `browser-use` CLI. Use `browser-use open`, `browser-use state`, `browser-use click`, `browser-use run`, and `browser-use extract` to navigate websites, fill forms, take screenshots, and perform autonomous browser tasks."
metadata: {
  "pepebot": {
    "emoji": "🌐",
    "requires": {
      "bins": ["browser-use"]
    },
    "install": [
      {
        "id": "install-script",
        "kind": "shell",
        "command": "curl -fsSL https://browser-use.com/cli/install.sh | bash",
        "bins": ["browser-use"],
        "label": "Install browser-use CLI (recommended)"
      },
      {
        "id": "pip",
        "kind": "pip",
        "package": "browser-use[cli]",
        "bins": ["browser-use"],
        "label": "Install browser-use CLI (pip)"
      }
    ]
  }
}
---

# Browser Automation with browser-use CLI

## When to use
Use this skill when:
- Navigating websites automatically
- Filling forms
- Clicking elements
- Taking screenshots
- Extracting web data
- Running autonomous browser agents

---

## Quick start

Open website:

    browser-use open https://example.com

Inspect page elements:

    browser-use state

Click element:

    browser-use click 5

Type text:

    browser-use input 3 "Hello"

Take screenshot:

    browser-use screenshot page.png

Close browser:

    browser-use close

---

## Autonomous tasks

Run AI browser task:

    browser-use run "Extract all product prices"

Requires API key:
- BROWSER_USE_API_KEY
- OPENAI_API_KEY
- ANTHROPIC_API_KEY

---

## Browser modes

Headless Chromium (default):

    browser-use --browser chromium open https://example.com

Real Chrome session:

    browser-use --browser real open https://example.com

Cloud browser:

    browser-use --browser remote open https://example.com

---

## Best practices

1. Always run `browser-use state` before interacting with elements
2. Use persistent sessions for multi-step workflows
3. Use `--headed` when debugging
4. Close sessions after tasks:

       browser-use close

