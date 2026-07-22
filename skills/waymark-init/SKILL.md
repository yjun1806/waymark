---
name: waymark-init
description: Initialize Waymark in a repository — an interactive, step-by-step setup. Asks satellite vs embedded mode, scaffolds the waymark/ status folders, writes .waymark.yml, installs the ambient workflow rules (into CLAUDE.md) and the git gate. Use when the user wants to set up / initialize / bootstrap / start using Waymark ("waymark init", "set up waymark", "Waymark 초기화", "Waymark 세팅").
---

# Waymark init

Walk the user through setting up Waymark in this repo **one decision at a time** — do not do it
all silently. Ask, wait for the answer, confirm, then act. Once `lang` is known, speak to the
user in that language.

## Step 0 — git repo?

Run `git rev-parse --show-toplevel`. If it fails, offer to `git init` first (Waymark's
enforcement lives in git hooks).

## Step 1 — Ask the MODE first (wait for the answer, then branch)

Present the choice and ask which one:

- **satellite** (recommended) — Waymark lives in its **own repo** and *references* the code repos
  it manages (via `repos:`). The code repos are never touched. Best for solo, multi-repo, or
  when the team hasn't adopted Waymark.
- **embedded** — Waymark lives **inside this code repo** (docs-with-code). No `repos:` needed.
  Best for a single repo that wants code + docs in the same PR.

Wait for their choice before continuing. Everything below branches on it.

## Step 2 — Scaffold the status folders

Create `waymark/draft/`, `waymark/approved/`, `waymark/in-progress/`, `waymark/done/`, each with a
`.gitkeep`. (Both modes use a root `waymark/` folder → `waymark/<status>/`.)

## Step 3 — Build `.waymark.yml` (ask one field at a time, confirm)

- `lang` — the team's primary language for generated docs (e.g. `ko`, `en`). Default from the
  user's locale; confirm.
- **satellite only** — for each code repo to manage, ask an `alias` and its `remote`, building
  `repos: { <alias>: { remote: <host/org/repo> } }`.
- `assignees` roster — resolve the current user's github id (`gh api user -q .login`, fallback
  `git config user.email`), then ask their short **unique** prefix (uppercase, e.g. `YJ`). Add
  `<github-id>: <PREFIX>`.
- Ask whether they use a tracker (Jira/Linear). If yes, set `tracker:` and note that ids will
  come from the tracker instead of the roster.

Write `.waymark.yml`.

## Step 4 — Local paths + gitignore (satellite only)

Write `.waymark.local.yml` with `paths: { <alias>: <local checkout path> }` (machine-specific),
and append `.waymark.local.yml` to `.gitignore` (never commit local paths).

## Step 5 — Install the workflow rules (reference, not inline)

The rules live in the waymark data and are *referenced* from CLAUDE.md — Waymark's own principle
applied to itself. Do two things:

1. Copy the plugin's `templates/waymark-rules.md` to **`waymark/rules.md`** in this repo (find the
   template at `${CLAUDE_PLUGIN_ROOT}/templates/waymark-rules.md` or under
   `~/.claude/plugins/*waymark*/templates/`).
2. Add an import to this repo's `CLAUDE.md` (create if absent) so the rules auto-load every
   session — a marked one-liner, **not** the whole block:

       <!-- waymark:start -->
       @waymark/rules.md
       <!-- waymark:end -->

Make `AGENTS.md` a symlink (or copy) of `CLAUDE.md` for tool-neutrality.

These rules make Claude follow the lifecycle and **move issue docs automatically** (`git mv`)
as work progresses — the user never invokes a move command; human-gated moves are just
confirmed first.

## Step 6 — Install the git gate

Run the plugin's installer from the repo root:
`sh "${CLAUDE_PLUGIN_ROOT}/hooks/install.sh"` (or find `*waymark*/hooks/install.sh` under
`~/.claude/plugins`). Every commit then regenerates the indexes and runs the gate.

## Step 7 — Confirm and hand off

Show the created structure and tell the user:
- **Start an issue**: just describe the work (or `/work-new`) → it creates
  `waymark/draft/<id>-<slug>.md`.
- **Status moves are automatic** — Claude `git mv`s the doc as work progresses (per the rules
  in CLAUDE.md); human-gated moves (approve the design, final done) are confirmed with you first.
- Folder = status (no `status` field) · `index.md` is auto-generated (don't edit) · `done/` is
  frozen · reference planning/contract (don't re-source them).
