# Changelog

All notable changes to Waymark are recorded here. Versions follow semver —
pre-1.0, breaking changes may land in a minor bump.

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
