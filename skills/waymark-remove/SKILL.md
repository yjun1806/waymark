---
name: waymark-remove
description: Cleanly remove Waymark from a repository — uninstall the git hooks, strip the ambient workflow rules from CLAUDE.md/AGENTS.md, clean the gitignore, and (optionally) delete the waymark/ folder and config. Use when the user wants to remove / uninstall / tear down / stop using Waymark in a repo ("waymark remove", "uninstall waymark", "Waymark 제거", "Waymark 지워", "Waymark 삭제").
---

# Waymark remove

Cleanly undo `waymark init`. Issue docs and git history are involved, so **ask, confirm, then
act** — never delete without an explicit yes. Speak in the repo's `lang` if known.

## Step 1 — Detect what's installed

Report what's present:
- `waymark/` folder (and roughly how many issue docs)
- `.waymark.yml` / `.waymark.local.yml`
- git hook: `.git/hooks/pre-commit` + `.git/hooks/waymark-index.py` / `waymark-check.py`
- `waymark/rules.md` + the import block in `CLAUDE.md` between `<!-- waymark:start -->` and `<!-- waymark:end -->`
- `AGENTS.md` symlink → `CLAUDE.md`

## Step 2 — Ask the SCOPE (decides what gets deleted)

- **A) Unwire only — keep your issue docs** *(recommended)* — remove the hooks, the ambient
  rules, and the wiring, but **keep `waymark/`** (your issue history stays as plain markdown).
  Waymark just stops managing/enforcing.
- **B) Full remove** — also delete `waymark/`, `.waymark.yml`, `.waymark.local.yml`. **Destructive:**
  removes all issue docs (including frozen `done/` history) from the working tree. They remain
  in **git history** (recoverable) unless history is also rewritten.

Confirm the choice. For **B**, confirm again explicitly and state exactly what will be deleted.

## Step 3 — Remove the git hooks

Delete `.git/hooks/pre-commit`, `.git/hooks/waymark-index.py`, `.git/hooks/waymark-check.py`
(only if they are the Waymark ones — check the pre-commit references waymark).

## Step 4 — Strip the workflow rules

Delete `waymark/rules.md`. In `CLAUDE.md`, remove the Waymark import block between
`<!-- waymark:start -->` and `<!-- waymark:end -->` (inclusive). If `CLAUDE.md` is now empty, remove
it. If `AGENTS.md` is a symlink to `CLAUDE.md` (created by Waymark), remove the symlink.

## Step 5 — Clean the gitignore

Remove the `.waymark.local.yml` line from `.gitignore`.

## Step 6 — (Scope B only) Delete the data

`git rm -r waymark/ .waymark.yml` and remove `.waymark.local.yml`. Using `git rm` stages the removal
so it's captured in the next commit.

## Step 7 — Confirm and commit

Show exactly what was removed. Remind the user:
- Committed issue docs still live in **git history** and are recoverable unless history is rewritten.
- Suggest committing the removal, e.g. `chore: remove waymark`.
