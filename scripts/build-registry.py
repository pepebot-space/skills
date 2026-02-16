#!/usr/bin/env python3
"""Build skills.json registry from SKILL.md frontmatter."""

import json
import re
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Optional


def parse_frontmatter(content: str) -> Optional[dict]:
    """Parse YAML-like frontmatter from SKILL.md content."""
    match = re.match(r"^---\s*\n(.*?)\n---", content, re.DOTALL)
    if not match:
        return None

    raw = match.group(1)
    data = {}

    # Parse name
    m = re.search(r'^name:\s*(.+)$', raw, re.MULTILINE)
    if m:
        data["name"] = m.group(1).strip().strip('"\'')

    # Parse description
    m = re.search(r'^description:\s*(.+)$', raw, re.MULTILINE)
    if m:
        data["description"] = m.group(1).strip().strip('"\'')

    # Parse metadata block as JSON
    m = re.search(r'^metadata:\s*(\{.*\})\s*$', raw, re.MULTILINE | re.DOTALL)
    if m:
        json_str = m.group(1)
        # The metadata spans multiple lines — grab from first { to matching }
        # Re-extract from the raw frontmatter more carefully
        pass

    # Better metadata extraction: find "metadata:" then capture the JSON block
    meta_match = re.search(r'metadata:\s*', raw)
    if meta_match:
        json_start = meta_match.end()
        # Find the balanced JSON object
        depth = 0
        json_end = json_start
        for i in range(json_start, len(raw)):
            if raw[i] == '{':
                depth += 1
            elif raw[i] == '}':
                depth -= 1
                if depth == 0:
                    json_end = i + 1
                    break
        json_str = raw[json_start:json_end]
        try:
            data["metadata"] = json.loads(json_str)
        except json.JSONDecodeError:
            print(f"  Warning: failed to parse metadata JSON", file=sys.stderr)

    return data if data else None


def build_registry(repo_root: Path) -> dict:
    """Scan all skill directories and build the registry."""
    skills = []

    for entry in sorted(repo_root.iterdir()):
        if not entry.is_dir() or entry.name.startswith('.'):
            continue

        skill_file = entry / "SKILL.md"
        if not skill_file.exists():
            continue

        content = skill_file.read_text(encoding="utf-8")
        frontmatter = parse_frontmatter(content)
        if not frontmatter:
            print(f"  Skipping {entry.name}: no valid frontmatter", file=sys.stderr)
            continue

        skill_entry = {
            "name": frontmatter.get("name", entry.name),
            "description": frontmatter.get("description", ""),
            "path": entry.name,
        }

        metadata = frontmatter.get("metadata", {})
        if metadata:
            skill_entry["metadata"] = metadata

        skills.append(skill_entry)
        print(f"  Found skill: {skill_entry['name']}", file=sys.stderr)

    return {
        "version": 1,
        "updated_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "skills_count": len(skills),
        "skills": skills,
    }


def main():
    repo_root = Path(__file__).resolve().parent.parent
    print(f"Scanning skills in: {repo_root}", file=sys.stderr)

    registry = build_registry(repo_root)
    output_path = repo_root / "skills.json"
    output_path.write_text(
        json.dumps(registry, indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )

    print(f"Written {registry['skills_count']} skills to {output_path}", file=sys.stderr)


if __name__ == "__main__":
    main()
