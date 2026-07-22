<!--
  Docat workflow rules. `docat init` copies this to docat/rules.md and imports it into your
  CLAUDE.md via `@docat/rules.md` (auto-loaded each session). Managed by Docat — `docat-remove`
  deletes this file. Do not hand-edit.
-->

## Docat workflow (this repo uses Docat)

Issue docs live at `docat/<status>/<id>-<slug>.md`. **The folder IS the status.** The doc owns
only the *how* and *decisions*; planning and the data contract are **referenced** (link / code),
never re-sourced.

### Lifecycle — you (Claude) judge the move and run `git mv` as part of the flow

- **draft/** — being designed. Fill `Why` (+ a rough `How`).
- **draft → approved/** — ONLY after a human approves the design. Never self-approve — ask.
  That commit is the record that this exact design was approved before build.
- **approved → in-progress/** — the moment you start implementing.
- **in-progress → done/** — ONLY after review/tests pass (the gate is green). Then the doc is
  **frozen** — never edit a `done/` doc again. For a material post-approval change, `git mv`
  back to `approved/` and re-approve.

Judge these transitions from the work situation and perform the `git mv` yourself — the user
should not have to invoke a command for each move. **Confirm the human-gated moves**
(draft→approved, and the final →done) with the user before doing them; the rest you may do
automatically as the work progresses.

### Keep issues small — split when they grow

If an issue doc grows long (past roughly a screen or two), that is a signal the **issue itself
is too big**. **Suggest splitting it into smaller issues** — link them with `supersedes` /
`follows` — rather than letting one doc balloon. Length is a signal to split, not to fatten.

### Invariants (never violate)

- **Folder = status** — never add a `status` field to a doc.
- **`index.md` is auto-generated** — never hand-edit it.
- **`done/` is frozen** — never edit a done doc.
- **Reference, don't re-source** — link planning/contract; a *dated, non-authoritative excerpt*
  is fine, a *maintained copy (second source of truth)* is not.
- **id** comes from the tracker, or `<prefix>-<seq>` from `.docat.yml` — never a shared counter.
- Commit messages cross-link the issue `id` (and, for done, the code commit SHA).

### Creating an issue

New substantive work → create `docat/draft/<id>-<slug>.md` from the template. Author
`title`/`summary`/body in the team's `lang` (from `.docat.yml`); the filename `slug` is ASCII.
