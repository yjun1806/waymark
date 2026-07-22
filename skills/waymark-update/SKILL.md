---
name: waymark-update
description: Update / migrate an existing Waymark installation to the current plugin version — re-vendors the git hooks (so committed gates pick up the latest logic), refreshes the ambient rules, migrates the config, and regenerates the indexes. Idempotent and safe to run anytime. Use after updating the Waymark plugin, or when hooks / indexes seem stale ("waymark update", "migrate waymark", "refresh waymark hooks", "Waymark 업데이트", "Waymark 갱신", "Waymark 마이그레이션").
---

# Waymark update

Sync an already-set-up repo (`waymark/` exists) with the current plugin. The plugin ships new
logic, but `waymark init` **vendored copies** into the repo (`.git/hooks/*`, `waymark/rules.md`) so
that gates run even from a plain terminal `git commit` — those copies don't refresh on their own.
This skill re-syncs them. **Idempotent**: it detects old shapes and fixes them, safe to run
repeatedly. Speak in the repo's `lang`. Don't run where there's no `waymark/` (suggest `waymark
init` instead).

## Guiding rule — refresh machinery, don't rewrite frozen history
Waymark freezes `done/`. A migration must **never rewrite `done/` docs** — that would break the one
guarantee the freeze makes. Prefer **tolerant readers** (tooling that accepts both the old and new
shape) over rewriting past docs. Only *live* docs (`draft` / `approved` / `in-progress`) may be
normalized, and only when necessary — report before doing so.

## Step 1 — Detect and report
Confirm `waymark/` exists. Report the current plugin version (`.claude-plugin/plugin.json` under
`${CLAUDE_PLUGIN_ROOT}` or `~/.claude/plugins/*waymark*/`) and what's vendored in the repo (the
hooks in `.git/hooks/`, `waymark/rules.md`, `.waymark.yml`).

## Step 2 — Re-vendor the git hooks
Re-run the installer from the repo root: `sh "${CLAUDE_PLUGIN_ROOT}/hooks/install.sh"` (or find
`*waymark*/hooks/install.sh` under `~/.claude/plugins`). It overwrites `.git/hooks/pre-commit` and
copies the latest `waymark-index.py` / `waymark-check.py`, so terminal commits use current logic
(e.g. the `created` index column). If the repo sets `core.hooksPath` (husky/lefthook), install.sh
prints how to wire it instead of installing into `.git/hooks`.

## Step 3 — Refresh the ambient rules
Copy the plugin's latest `templates/waymark-rules.md` over `waymark/rules.md`. Leave the CLAUDE.md
import block (`<!-- waymark:start -->` … `<!-- waymark:end -->`) as-is — only the referenced file
refreshes. (This is Waymark's own reference-not-duplicate principle: the rules live in one place.)

## Step 4 — Migrate the config (idempotent)
In `.waymark.yml`: if a bare `tracker:` key exists (the old name for the tracker tool), rename it to
`tracker_type:`. Leave everything else untouched. (A doc's per-issue `tracker` frontmatter is a
different thing and is not touched here.)

## Step 5 — Normalize LIVE docs only, if a schema needs it (never done/)
If a frontmatter schema changed (e.g. `tracker` used to be a single string and is now an inline
list), you MAY normalize docs in `draft` / `approved` / `in-progress` (e.g. `tracker: "url"` →
`tracker: ["url"]`). **Skip `done/` entirely** — it's frozen, and the tooling reads old shapes
tolerantly. List every live doc you change.

## Step 6 — Regenerate indexes
Run `python3 "${CLAUDE_PLUGIN_ROOT}/hooks/waymark-index.py" "$(git rev-parse --show-toplevel)"` (or
the vendored `.git/hooks/waymark-index.py`) so derived artifacts — like the new `created` column —
appear.

## Step 7 — Report and commit
Summarize what was refreshed and migrated. Suggest committing, e.g. `chore: update waymark to <version>`.
