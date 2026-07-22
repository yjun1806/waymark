# Waymark

**English** · [한국어](./README.ko.md)

**Spec-driven development for teams whose truth already lives elsewhere.**

## Why Waymark?

The plan usually already exists somewhere — Confluence, Notion, a PDF. You design
and build from it. Bolt Spec-Kit-style SDD on top and the initial setup of
spec/plan/tasks is fine; the trouble is everything after. The plan changes, a
"can you tweak this" comes in, mid-build you hit "this approach won't work." Every
time, a human has to reflect it by hand across several files.

The docs bloat, and at some point the line between plan and tasks blurs. You can
wire up skills and prompts to hold the structure, but if the agent doesn't invoke
them at the right moment, they don't hold. The result is drift — docs
contradicting each other, legacy info lingering. Cleaning it up with another AI
pass just burns tokens. And those carefully shared docs? Once they're old, nobody
reads them — everyone knows they no longer match reality.

Waymark is the set of conclusions worked backward from that experience. Not a
framework — a thin **convention**.

- **Reference, don't duplicate.** Planning lives in Confluence, the contract in
  code, progress in the tracker. Make no copy and there's no reconciliation work
  and no copy to rot (**authority drift is zero** — content drift is *minimized*
  by hooks/CI gates, not eliminated). A context excerpt is dated and written
  **once**, never updated. When planning changes you don't sync a copy; you
  **re-fetch** from the source at the next kickoff, and for a material change you
  move the doc back to `approved` and re-approve.
- **One issue = one thin doc.** The doc owns only the *how* and the *decisions*.
  Nothing is split across spec/plan/task, so there's no boundary to blur.
- **The folder owns the status.** `draft → approved → in-progress → done` — the
  folder a file sits in *is* its status. At `done` it **freezes**. Meaning: you
  never trust a stale doc nobody reads to describe "now." Need the current state?
  Derive it instead of maintaining it (ARCHITECTURE §7).
- **Only code enforces.** Having felt what happens when a skill isn't invoked in
  time, the rules that must hold live in hooks and gates, not prompts. What code
  blocks today: id uniqueness, required frontmatter, headings, and the `done`
  freeze. Judgment calls — like when to move a folder — are still discipline.

You can also start with no planning doc at all — a verbal "we need this feature."
With no external source, the Waymark doc *is* the point-in-time SSOT
(ARCHITECTURE §0). But in a true greenfield where you want a readable
current-state spec kept up to date, Spec Kit / OpenSpec is the right tool.

## Install

Waymark is a **Claude Code plugin**. In a **Claude Code session** (terminal or
IDE), run:

```
/plugin marketplace add yjun1806/waymark
/plugin install waymark@waymark
```

Installing activates the `waymark-init` skill and the `/work-new` command.
Prerequisites: Claude Code · git · python3. (If the repo is private, `marketplace
add` needs git access — only people with access can install, which is fine for
internal team distribution.)

## Quick start

1. **`waymark init`** (or "set up Waymark") — pick a mode (satellite/embedded),
   scaffold the `waymark/` folders, `.waymark.yml`, and the git gate.
2. **`/work-new`** — create a new issue doc (`waymark/draft/`).
3. **Status moves are automatic** — Claude judges the situation and `git mv`s the
   doc (`draft → approved → in-progress → done`). The move *is* the status change
   and the audit log. Only the human gates (design approval, final done) ask for
   confirmation; the rest follows the rules in CLAUDE.md.

On commit the gate (`waymark-check`) validates id uniqueness, required fields, and
headings, and the index (`waymark/<status>/index.md`) is regenerated.

## Deployment modes (satellite / embedded)

Where Waymark's data (`waymark/` + `.waymark.yml`) lives. **`waymark init` asks at
setup.**

- **satellite** (default) — keep Waymark in its **own repo** and **reference** the
  managed code repos via `repos:` in `.waymark.yml` (the code repos stay
  untouched). Fits solo, multi-repo, and teams not yet bought in.
- **embedded** — put `waymark/` **inside** the code repo (docs-with-code). No
  `repos:` needed. For versioning code + docs in the same PR in a single repo.

Both modes share the same shape — `waymark/<status>/` at the root. Details in
[ARCHITECTURE.md](./ARCHITECTURE.md) §12.

**Config files** (created by `waymark init`):
- `.waymark.yml` — `lang` · `repos` (satellite) · `assignees` roster. **Shared in git.**
- `.waymark.local.yml` — local checkout paths (per machine). **gitignored.**

```yaml
# .waymark.yml example (satellite)
lang: en
repos:
  backend: { remote: github.com/myteam/backend }
assignees:
  younjun-kim: YJ          # github-id → prefix (id source when there's no tracker)
```

## The three principles

The formal names for the conclusions above — rationale in
[ARCHITECTURE.md](./ARCHITECTURE.md).

1. **Reference, don't duplicate** — no maintained copy. Excerpts are write-once;
   re-fetch at kickoff instead of updating.
2. **Own only the HOW** — implementation intent and decisions only. Planning /
   contract / progress are delegated to their sources.
3. **Time-box authority** — live while in a status folder, frozen at `done`.

## What it is NOT

- **Not a framework** — a thin convention + enforcing hooks + skills.
- **Not a quality or methodology tool** — it doesn't touch *how to write well*
  (doc quality/consistency) or *how to design and build* (methodology). That's the
  job of dedicated skills (review, TDD, design, doc-writing). Waymark owns only the
  **management convention and state of a work unit** (one issue = one doc) — where
  it lives, what state it's in, when it freezes. Even the hooks enforce *structure*
  (id, headings, status, freeze), not whether the *content* is any good.
- **Not a tracker replacement** — it **complements** Jira/Linear (finer execution
  state). No mirroring.
- **vs OpenSpec** — OpenSpec pays the maintenance cost to keep a readable
  current-state spec; Waymark gives that spec up to remove drift. **A trade-off.**
  → [ARCHITECTURE.md](./ARCHITECTURE.md) §0.

## Compared to other approaches

All of these are legitimate, each with a **real strength**. Less "which is better"
than **what you give up and what you get**.

| Approach | Real strength | Where it shines |
|---|---|---|
| **Spec Kit** | Tool-neutral standard · team alignment before code · mature ecosystem | greenfield, big-team upfront agreement |
| **OpenSpec** | Readable current-state spec · self-contained · simple | no external SSOT, wants an in-repo spec |
| **BMAD** | Persona-team simulation · dense audit trail | complex, regulated, greenfield |
| **Jira / Linear** | Org-wide · non-dev access · mature | the source of project management (**Waymark complements it**) |
| **Waymark** | No authority copy (authority drift 0) · complements the tracker · git-native | **planning already lives outside (Confluence)**, contract in code |

The gap Waymark fills is *"the truth already lives elsewhere and I don't want to
copy it again."* Without that premise — greenfield, or you want a readable in-repo
spec — **Spec Kit / OpenSpec fit better, and we'd recommend them.** Fuller
comparison in [ARCHITECTURE.md](./ARCHITECTURE.md) §0.

## Scale

Solo → team → enterprise (dev org only). It scales **distributed, like git** —
each team is an independent instance, not one org-wide system. (There's no
inter-instance sync protocol — each stands alone.) →
[ARCHITECTURE.md](./ARCHITECTURE.md) §11.

## Layout

```
waymark/{draft,approved,in-progress,done}/   issue docs (folder = status) + auto-generated index.md
.waymark.yml                                  team config (lang · repos · assignees)
```

Plugin parts: `commands/` (slash commands) · `skills/` (`waymark-init`·`waymark-remove`) ·
`hooks/` (enforcement) · `templates/` (`work.template`·`waymark-rules`).

## Language

Generated docs (title · summary · body) are written in the team's **primary
language** (`.waymark.yml` `lang`) — English for English teams, Korean for Korean
teams. The filename **slug is always ASCII** (cross-OS git safety).

## Read more

- [ARCHITECTURE.md](./ARCHITECTURE.md) — positioning (vs OpenSpec), folder model, id/schema, deployment modes, enforcement — all the design decisions.

## The name

**Waymark** — from the cairn / trail marker: a few stones stacked **thin** to point
to the next fork. Not a grand monument but the **minimal trace that connects a
path** — exactly what this tool does. It's also `way` (path/workflow) + `mark`
(marking an issue the way git marks a commit).

## License

MIT — [LICENSE](./LICENSE). © 2026 Youngjun Kim.
