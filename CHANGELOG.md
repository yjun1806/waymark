# Changelog

All notable changes to Waymark are recorded here. Versions follow semver —
pre-1.0, breaking changes may land in a minor bump.

## v0.2.2 — 2026-07-22

First-pass review fixes.

- **Index no longer breaks on `|`** — free-text `id`/`title`/`summary`/`assignee` are escaped
  before entering the index table (a pipe in a title used to corrupt the row).
- **Bounded commit time as `done/` grows** — `done/` is frozen, so the index reuses its
  `created`/`updated` from the existing index.md instead of shelling out to git per doc on every
  commit; only new arrivals do a one-time git lookup.
- **`waymark-check` survives unreadable files** — a read error (race / permission) is reported
  per file instead of crashing the pre-commit hook.
- Minor: the frozen-`done/` file list prints space-safely; index docstring updated.

## v0.2.1 — 2026-07-22

- **Fix: plugin load error** — removed the redundant `"hooks": "./hooks/hooks.json"` from
  `plugin.json`. Claude Code auto-loads `hooks/hooks.json` from the standard location, so the
  explicit manifest reference double-loaded it ("Duplicate hooks file detected"). The hook still
  loads automatically.

## v0.2.0 — 2026-07-22

- **`waymark-work` skill** — the new-issue flow (link gathering, id allocation, template
  scaffolding) is now a skill, so it runs whether you type `/work-new` or just start describing
  work. `/work-new` is a thin entry point to the same flow (single source of truth); the ambient
  rules point to it.
- **`waymark-update` skill** — sync an existing install with the current plugin: re-vendors the
  git hooks, refreshes the ambient rules, migrates config (`tracker` → `tracker_type`), and
  regenerates indexes. Idempotent; **never rewrites frozen `done/` docs** (prefers tolerant readers).

## v0.1.1 — 2026-07-22

- **Index now shows `created`** — the per-folder `index.md` gains a `created` column
  (git first-commit date, tracked across status-folder moves with `--follow`) next to
  `updated`. Both are git-derived; no hand-written date fields (they would drift — §4).

## v0.1.0 — 2026-07-22

Initial public release.

- **Convention** — one issue = one thin doc; the folder is the status
  (`draft → approved → in-progress → done`); frozen on `done`.
- **`/work-new`** — create an issue doc, with an explicit step that gathers the
  planning source and tracker issue links (multiple / cross-tool supported).
- **Commit gates** (`waymark-check`) — id uniqueness, required frontmatter, the
  four verbatim headings, and the `done/` freeze; per-folder `index.md`
  regenerated on commit (`waymark-index`).
- **Skills** — `waymark-init` (interactive setup) and `waymark-remove`.
- **Deployment modes** — satellite (default) and embedded.
- **Docs** — bilingual README and ARCHITECTURE (English + Korean).
