#!/usr/bin/env python3
"""docat-check — the ref-integrity gate. Validates issue docs; exit non-zero on any violation.

Checks (v0.1):
  - frontmatter block present
  - required fields: id, title
  - id UNIQUENESS across all docat/** (catches the self-collision from parallel branches)
  - no `status` field (the folder is the single source of status)
  - the 4 headings present in verbatim order: Why → How → Tasks → Decisions

Deferred to v0.2: planning/tracker link liveness, code-symbol resolution, contract tests.

Usage: docat-check.py [repo_root]     (default: current directory)
"""
import os
import re
import sys

STATUSES = ["draft", "approved", "in-progress", "done"]
HEADINGS = ["## Why", "## How", "## Tasks", "## Decisions"]
REQUIRED = ["id", "title"]


def parse(path):
    with open(path, encoding="utf-8") as f:
        text = f.read()
    m = re.match(r"^---\s*\n(.*?)\n---\s*\n(.*)$", text, re.S)
    if not m:
        return None, text
    fm = {}
    for line in m.group(1).splitlines():
        s = line.strip()
        if s and not s.startswith("#") and ":" in line:
            k, _, v = line.partition(":")
            fm[k.strip()] = v.strip().strip('"').strip("'")
    return fm, m.group(2)


def main():
    root = sys.argv[1] if len(sys.argv) > 1 else "."
    base = os.path.join(root, "docat")
    if not os.path.isdir(base):
        return 0
    errors = []
    ids = {}
    for status in STATUSES:
        folder = os.path.join(base, status)
        if not os.path.isdir(folder):
            continue
        for name in sorted(os.listdir(folder)):
            if not name.endswith(".md") or name == "index.md":
                continue
            rel = f"docat/{status}/{name}"
            fm, body = parse(os.path.join(folder, name))
            if fm is None:
                errors.append(f"{rel}: missing frontmatter (--- block)")
                continue
            for k in REQUIRED:
                if not fm.get(k):
                    errors.append(f"{rel}: missing required frontmatter '{k}'")
            if "status" in fm:
                errors.append(f"{rel}: remove 'status' frontmatter — the folder is the status")
            _id = fm.get("id")
            if _id:
                if _id in ids:
                    errors.append(f"{rel}: duplicate id '{_id}' (also in {ids[_id]})")
                else:
                    ids[_id] = rel
            pos = 0
            for h in HEADINGS:
                m = re.compile(r"(?m)^" + re.escape(h) + r"\s*$").search(body, pos)
                if not m:
                    errors.append(f"{rel}: missing or out-of-order heading '{h}'")
                    break
                pos = m.end()
    if errors:
        sys.stderr.write("docat-check: FAILED\n")
        for e in errors:
            sys.stderr.write(f"  ✗ {e}\n")
        return 1
    print(f"docat-check: OK ({len(ids)} issue(s))")
    return 0


if __name__ == "__main__":
    sys.exit(main())
