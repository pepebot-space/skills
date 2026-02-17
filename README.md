# 🐸 PEPEBOT Skills

A curated collection of AI agent skills for PEPEBOT. Each skill provides specialized knowledge, workflows, or tool integrations.

## 📦 Skills (55)

### 🤖 AI & Agent Tools
| Skill | Description |
|-------|-------------|
| 🧠 [claude-code](./claude-code) | Interact with Claude Code CLI — run coding agents, manage MCP tools, autonomous workflows |
| 🤖 [opencode](./opencode) | OpenCode CLI — automation workflows, agents, headless coding tasks |
| 🌐 [browser-use](./browser-use) | Automate browser interactions — navigate, fill forms, screenshots, autonomous tasks |
| 📱 [phone-use](./phone-use) | Control iPhone/Android via PhoneAgent JSON-RPC — UI automation, accessibility trees |
| 📱 [termux-api](./termux-api) | Android device control via Termux API — battery, camera, SMS, sensors |
| 🤖 [llm-application-dev](./llm-application-dev) | Build LLM applications — prompt engineering, RAG patterns, AI integration |
| 🔧 [mcp-builder](./mcp-builder) | Create MCP servers for LLM-to-service integration (Python/Node) |
| 🛠️ [skill-creator](./skill-creator) | Guide for creating new PEPEBOT skills |

### 🌐 Infrastructure & DevOps
| Skill | Description |
|-------|-------------|
| ☁️ [cloudflared](./cloudflared) | Cloudflare Tunnel — secure service exposure, DNS routing, zero-trust |
| 🔐 [tailscale](./tailscale) | Tailscale mesh networking — SSH orchestration, subnet routing, service exposure |
| 🏠 [home-assistant](./home-assistant) | Home Assistant CLI & REST API — smart device control, automations |
| ▲ [vercel-deploy](./vercel-deploy) | Deploy to Vercel — edge functions, serverless, ISR |
| 🚀 [expo-deployment](./expo-deployment) | Deploy Expo apps to App Store, Play Store, and web |

### 💻 Development
| Skill | Description |
|-------|-------------|
| 🐍 [python-development](./python-development) | Python 3.12+, Django, FastAPI, async patterns, production best practices |
| 🟨 [javascript-typescript](./javascript-typescript) | JS/TS with ES6+, Node.js, React, modern web development |
| ⚛️ [react-best-practices](./react-best-practices) | React hooks, component patterns, state management, performance |
| ⚙️ [backend-development](./backend-development) | Backend API design, database architecture, microservices |
| 🗄️ [database-design](./database-design) | Database schema design, optimization, migrations (PostgreSQL, MySQL, etc.) |
| 📱 [expo-app-design](./expo-app-design) | Cross-platform mobile apps with Expo Router & NativeWind |
| ⬆️ [upgrading-expo](./upgrading-expo) | Upgrade Expo SDK versions and fix dependency issues |

### 🎨 Design & UI
| Skill | Description |
|-------|-------------|
| 🎨 [frontend-design](./frontend-design) | Production-grade frontend interfaces with exceptional aesthetics |
| 🖌️ [canvas-design](./canvas-design) | Visual art in .png/.pdf — posters, designs, static visuals |
| 🌐 [web-design-guidelines](./web-design-guidelines) | Responsive layouts, accessibility, visual hierarchy |
| 🎭 [theme-factory](./theme-factory) | Apply professional themes to artifacts — slides, docs, landing pages |
| 🎯 [brand-guidelines](./brand-guidelines) | Apply brand colors & typography to artifacts |
| 🎨 [algorithmic-art](./algorithmic-art) | Generative art with p5.js — flow fields, particle systems, seeded randomness |

### 📄 Document Processing
| Skill | Description |
|-------|-------------|
| 📕 [pdf](./pdf) | PDF manipulation — text extraction, tables, create/merge/split, forms |
| 📑 [docx](./docx) | Word document creation, editing, tracked changes, text extraction |
| 📊 [pptx](./pptx) | PowerPoint creation, editing, layouts, speaker notes |
| 📊 [xlsx](./xlsx) | Spreadsheet creation, formulas, formatting, data analysis |

### ✅ Best Practices & Quality
| Skill | Description |
|-------|-------------|
| ✅ [best-practices](./best-practices) | Transform vague prompts into optimized structured prompts |
| 📝 [code-documentation](./code-documentation) | API docs, README files, inline comments, technical guides |
| ♻️ [code-refactoring](./code-refactoring) | Code refactoring patterns for improved quality |
| 🔍 [code-review](./code-review) | Automated code review for pull requests |
| 🧪 [qa-regression](./qa-regression) | Automated QA regression testing with Playwright |
| 🧪 [webapp-testing](./webapp-testing) | Web app testing with Playwright — screenshots, logs, debugging |
| ❓ [ask-questions-if-underspecified](./ask-questions-if-underspecified) | Clarify requirements before implementing |

### ✍️ Content & Research
| Skill | Description |
|-------|-------------|
| ✍️ [content-research-writer](./content-research-writer) | Research-driven content writing with citations |
| 📄 [doc-coauthoring](./doc-coauthoring) | Structured workflow for co-authoring documentation |
| 📋 [changelog-generator](./changelog-generator) | Auto-generate user-facing changelogs from git commits |
| 💬 [internal-comms](./internal-comms) | Write internal communications — status reports, updates |
| 🌍 [domain-name-brainstormer](./domain-name-brainstormer) | Generate creative domain name ideas and check availability |
| 🖼️ [image-enhancer](./image-enhancer) | Enhance image quality — resolution, sharpness, clarity |
| 🎬 [slack-gif-creator](./slack-gif-creator) | Create animated GIFs optimized for Slack |
| 📹 [video-downloader](./video-downloader) | Download videos from YouTube and other platforms |

### 📊 Business & Productivity
| Skill | Description |
|-------|-------------|
| 🎫 [jira-issues](./jira-issues) | Create, update, and manage Jira issues from natural language |
| 💼 [job-application](./job-application) | Tailored cover letters and job applications |
| 🔬 [lead-research-assistant](./lead-research-assistant) | Identify high-quality leads for sales and business development |
| 📊 [competitive-ads-extractor](./competitive-ads-extractor) | Extract and analyze competitors' ads from ad libraries |
| 📅 [meeting-insights-analyzer](./meeting-insights-analyzer) | Analyze meeting transcripts for communication insights |
| 📈 [developer-growth-analysis](./developer-growth-analysis) | Analyze coding patterns and developer growth |
| 🧾 [invoice-organizer](./invoice-organizer) | Organize invoices and receipts for tax preparation |
| 🎲 [raffle-winner-picker](./raffle-winner-picker) | Pick random winners for giveaways and contests |
| 📂 [file-organizer](./file-organizer) | Intelligently organize files and folders |
| 🏗️ [artifacts-builder](./artifacts-builder) | Build elaborate multi-component HTML artifacts |

## 🚀 Adding a Skill

Each skill lives in its own directory with a `SKILL.md` file using this header format:

```yaml
---
name: skill-name
description: "What the skill does..."
metadata: {
  "pepebot": {
    "emoji": "🔧",
    "requires": {
      "bins": ["tool-name"]
    },
    "install": [
      {
        "id": "install-id",
        "kind": "shell",
        "command": "install command",
        "bins": ["tool-name"],
        "label": "Install description"
      }
    ]
  }
}
---
```

Register the skill in `skills.json` after adding it.

## 📜 License

See individual skill files for license information.
