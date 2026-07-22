---
name: docat-remove
description: Cleanly remove Docat from a repository — uninstall the git hooks, strip the ambient workflow rules from CLAUDE.md/AGENTS.md, clean the gitignore, and (optionally) delete the docat/ folder and config. Use when the user wants to remove / uninstall / tear down / stop using Docat in a repo ("docat remove", "uninstall docat", "docat 제거", "docat 지워", "docat 삭제").
---

# Docat remove

Cleanly undo `docat init`. Issue docs and git history are involved, so **ask, confirm, then
act** — never delete without an explicit yes. Speak in the repo's `lang` if known.

## Step 1 — Detect what's installed

Report what's present:
- `docat/` folder (and roughly how many issue docs)
- `.docat.yml` / `.docat.local.yml`
- git hook: `.git/hooks/pre-commit` + `.git/hooks/docat-index.py` / `docat-check.py`
- `docat/rules.md` + the import block in `CLAUDE.md` between `<!-- docat:start -->` and `<!-- docat:end -->`
- `AGENTS.md` symlink → `CLAUDE.md`

## Step 2 — Ask the SCOPE (decides what gets deleted)

- **A) Unwire only — keep your issue docs** *(recommended)* — remove the hooks, the ambient
  rules, and the wiring, but **keep `docat/`** (your issue history stays as plain markdown).
  Docat just stops managing/enforcing.
- **B) Full remove** — also delete `docat/`, `.docat.yml`, `.docat.local.yml`. **Destructive:**
  removes all issue docs (including frozen `done/` history) from the working tree. They remain
  in **git history** (recoverable) unless history is also rewritten.

Confirm the choice. For **B**, confirm again explicitly and state exactly what will be deleted.

## Step 3 — Remove the git hooks

Delete `.git/hooks/pre-commit`, `.git/hooks/docat-index.py`, `.git/hooks/docat-check.py`
(only if they are the Docat ones — check the pre-commit references docat).

## Step 4 — Strip the workflow rules

Delete `docat/rules.md`. In `CLAUDE.md`, remove the Docat import block between
`<!-- docat:start -->` and `<!-- docat:end -->` (inclusive). If `CLAUDE.md` is now empty, remove
it. If `AGENTS.md` is a symlink to `CLAUDE.md` (created by Docat), remove the symlink.

## Step 5 — Clean the gitignore

Remove the `.docat.local.yml` line from `.gitignore`.

## Step 6 — (Scope B only) Delete the data

`git rm -r docat/ .docat.yml` and remove `.docat.local.yml`. Using `git rm` stages the removal
so it's captured in the next commit.

## Step 7 — Confirm and commit

Show exactly what was removed. Remind the user:
- Committed issue docs still live in **git history** and are recoverable unless history is rewritten.
- Suggest committing the removal, e.g. `chore: remove docat`.
