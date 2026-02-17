---
name: expo-deployment
description: "Deploy Expo apps to iOS App Store, Android Play Store, and web."
metadata: {
  "pepebot": {
    "emoji": "🚀",
    "requires": {
      "bins": ["eas"]
    },
    "install": [
      {
        "id": "npm",
        "kind": "npm",
        "package": "eas-cli",
        "bins": ["eas"],
        "label": "Install EAS CLI (npm)"
      }
    ]
  }
}
---

# Expo Deployment

Deploy Expo apps to iOS App Store, Android Play Store, and web.

## When to Use

- Publishing to App Store / Play Store
- EAS Build configuration
- OTA updates
- CI/CD workflows for mobile

## Source

This skill references patterns from [Expo's skills](https://github.com/expo/skills).
