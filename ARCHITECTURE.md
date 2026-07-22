# Waymark — Design decisions (ARCHITECTURE)

**English** · [한국어](./ARCHITECTURE.ko.md)

> Product: **Waymark**. The "why" and philosophy live in [README.md](./README.md);
> this doc holds the **concrete design decisions**. Status: v0.1, design in progress
> (WIP) — updated as decisions change.

---

## 0. Positioning — vs OpenSpec (what we give up, what we gain)

The closest neighbor is **OpenSpec**. The change→archive lifecycle, satellite repos
(Stores), deltas, brownfield support, thin markdown — we converge on much of it.
OpenSpec is **mature, popular, and for genuinely good reasons.** Waymark is not
"better" than OpenSpec — it picks a **different trade-off**.

**The core symmetry**:

> **OpenSpec accepts maintenance cost and drift → and gains a readable current-state
> spec inside the repo. Waymark gives up that spec → and eliminates the maintenance
> cost and authority drift (content drift is minimized by the §9 gates). Neither side
> is absolutely superior — it's a question of what your team chooses to give up and
> what it chooses to gain.**

**OpenSpec's real strengths** (what Waymark gives up):
- **A readable current-state spec** — a newcomer learns "what does this system do"
  from prose without reading all the code. For many teams, "go read the code" is not
  an answer to that question.
- **Self-contained and simple** — one repo is all you need; no external SSOT, no
  distributed instances. Simplicity is adoption.
- **In-repo agreement (spec-as-contract)** — forces "agree before code" on teams with
  weak upstream planning discipline.
- **Maturity and ecosystem** — actually shipped, maintained, multi-agent. Waymark is
  still at the design stage.

**Waymark's bet** (what OpenSpec pays for):
- **Zero authority-drift burden** — we never build a maintained current-state spec,
  so there is nothing to go stale (no daily updates, no cascades, §7). *Content*
  drift (stale excerpts, contract mismatches) is not eliminated — it is minimized by
  gates (§9).
- **No second source of truth** — if planning already lives outside (Confluence), we
  don't duplicate it.
- **Tracker complement** (§3) · **contract = code** · **CI enforcement** (§9).

| Axis | OpenSpec | Waymark |
|---|---|---|
| Current-state spec | **Kept readable** (strength) | Not maintained — zero drift; derived via §7 instead |
| External SSOT | Not needed (self-contained, simple) | **Assumed** — reference it if present; otherwise the doc is the point-in-time SSOT |
| Requirements | Restated in `specs/` | Referenced / recorded point-in-time |
| Files per issue | 4 (proposal/specs/design/tasks) | 1, fused |
| Folder = status | Binary (active/archive) | 4 stages + approval gate (§2) |
| Tracker | No integration (simple) | Complement (mirroring forbidden, §3) |
| CI enforcement | None | ref/contract/id gates (§9) |
| Maturity | **Shipped, proven** | Design stage |

**When to pick OpenSpec**: no external SSOT · you want a readable current-state
document inside the repo · upstream planning discipline is weak and you need in-repo
agreement · simplicity and maturity come first.

**When to pick Waymark**: your planning SSOT is already thick and lives outside (you
refuse to mint a second source) · you loathe drift and have a tracker-complement
culture · contract-equals-code culture.

**What to steal from OpenSpec** (no reinventing): the propose/archive UX, delta
thinking, the Stores (satellite) pattern, the multi-agent support structure. Borrow
that skeleton but **remove only the "maintain the spec" core** — that is Waymark's
single fundamental difference.

### Lineage — not a new invention

Waymark is not an invention but **a convention that fits three proven ideas
together**: OpenSpec's change→archive lifecycle, the ADR/design-doc tradition of a
single narrative document that references instead of restating, and a
folder-as-status workflow that **complements** (never mirrors) the tracker. We merely
bound these three to the "an external SSOT already exists" case — no framework had
aimed squarely at that combination.

## 1. Core model

- **One issue = one file.** A single file holds *why · how · what · decisions*. We do
  not split spec/plan/task across multiple files.
- Waymark is not a "framework" — it is **a thin convention + enforcing hooks +
  skills**.

### The HOW→WHAT leak rule (the doc owns only the how)

When planning is incomplete, a decision written under `Decisions` can become the
**only home of a WHAT** that never existed in the source (e.g. "duplicate signup →
409"). Once that doc freezes in `done`, that WHAT fossilizes inside a record that
explicitly claims not to describe the present. So one rule attaches — **a decision
that fills a planning gap must be backported upstream (to the planning source) before
freeze**, or at minimum flagged in the tracker/planning doc. Otherwise Waymark has
minted, through its own escape hatch (the deviation log), the very second source of
truth it forbids.

## 2. Folder = status (core decision)

```
waymark/
├── draft/           # being designed (agent/human writing the doc)
├── approved/        # 👤 a human said "good to go" — waiting for an agent to start
├── in-progress/     # agent building = "what is alive right now" (closest to the present)
└── done/            # completed & shipped = frozen, immutable (plays the archive role)
```

- **The folder a file sits in is that issue's status.** One issue = one file that
  **moves between folders via `git mv`** (no copying; history survives via
  `--follow`). See §1.
- **No `status` field in frontmatter** — the folder is the single source of status.
- **Review is a gate, not a folder.** When review/testing is instantaneous like a
  "skill run", work doesn't dwell there, so it fails the folder test → it becomes the
  **gate on the `in-progress → done` move** (review and tests must pass to move —
  though in satellite mode this gate is human confirmation in v0.1; hook enforcement
  is v0.2, §9). Only if a real QA period exists — one that takes time and bounces
  work back — do you add a `verifying/` folder, and only then (YAGNI).
  → **The folder qualification test**: does work *dwell* there + *wait on another
  actor* + *possibly bounce back*? All three → folder; otherwise → gate.

### Why a folder, not a field (path-native)

Put status **in the file** (a frontmatter `status:`) and an agent has to **read** the file to
learn its status. A grep hit inside a `done/` doc loads the whole file into context before the
agent discovers it's legacy and discards it — pure waste. With folder = status, status is a
**filesystem-level path fact**: `grep -r waymark/in-progress/` or `--exclude-dir=done` excludes
it **without reading** (zero tokens).

- `done/` is frozen and so **accumulates forever**, so the saving grows as legacy piles up (same
  family as the §8 done-cache — drive the cost of accumulated `done/` toward zero).
- Caveat: it only pays off if the agent actually scopes its search (a blanket `grep -r waymark/`
  still reads `done/`). Path exclusion is trivial and cheap; content-based status filtering is
  not — the structure makes the cheap path obvious, it doesn't force it.
- Assumes path-based retrieval (grep/glob). Less relevant to a semantic index, but Claude Code's
  dominant retrieval is path-based, so this matches the actual environment.

In short: **status is a path, not content — so the agent filters without reading.**

### `git mv` = the governance log (the key win for agent-driven development)

- The `git mv draft/ approved/` commit is an **immutable record with the content
  snapshot baked in**: **"a human approved this design (the document as it stood at
  that moment)."** Proof that the agent built from an approved design lives in git. A
  tracker status change (metadata, no content snapshot) cannot give you that.
- The move is **performed automatically by the agent skill** (move on completion),
  preventing the "forgotten mv" — part of the pipeline, not human discipline.

### Freezing happens only in `done`

- Docs in `draft` through `in-progress` are **live** — changes during review land
  directly in the document.
- Moving to `done` = **freeze**. Never touched afterwards.
- If a material change arises after approval, don't edit the doc — **move it back to
  `approved` and re-approve**.
- **The liveness boundary**: exactly one — `done` or not. The only boundary the
  current-state derivation (§7) depends on.

### File identity = `id`, not path

- Because files move between folders, tools and references track the frontmatter
  **`id`**, not the path. (The id stays a stable identifier even through rename/edit
  merge conflicts.)

### Filename · id issuance · configuration (`.waymark.yml`)

**Path**: `waymark/<status>/<id>-<slug>.md`  (e.g. `waymark/in-progress/YJ-6-party-signup.md`)

- **`<id>`** — references, commit tags, and `supersedes` always use the id (never
  filename or path). **The id is always exactly one** — even with multiple tracker
  issues linked (§3), the id comes from only **one primary** among them (or from
  prefix-seq); the remaining links are references in the `tracker` list, never the
  id. Issuance:
  - **Tracker present (primary designated)**: the primary tracker's issued id
    (`JIRA-123`) — centrally atomic, unique.
  - **No tracker / no primary designated / multiple**: **`<prefix>-<seq>`** from the
    `.waymark.yml` roster (`YJ-6`). The prefix is a github-id→code mapping (unique
    within the team); the seq is **max+1** over existing files with that prefix
    (scanning all of `waymark/**`, including done). **No shared sequence counter.**
    - Zero team collisions (prefix is unique). Self-collision (the same person on
      parallel branches) yields silent duplicate ids, so the **id-uniqueness CI
      gate** catches it (§9).
    - prefix ≠ assignee: the prefix is the **creator's namespace** (baked into the
      id, immutable); the assignee is the current owner (mutable). If YJ-6 is
      reassigned, the id is still YJ-6.
- **`<slug>`** — **always ASCII** (kebab). Cross-OS git safety (avoids the mac NFD ↔
  Linux NFC problem).
- **Human language = configured language**: `title` · `summary` · body are generated
  in the `.waymark.yml` `lang` — **English teams get English, Korean teams get
  Korean**. Only the slug is ASCII; everything else is the local language.

**`.waymark.yml`** (set up by the team in advance, shared via git):

```yaml
lang: ko                 # language of generated docs (title/summary/body). Slug is always ASCII
repos:                   # managed repos (satellite mode §12). alias → remote (portable)
  backend: { remote: github.com/myteam/backend }
  app:     { remote: github.com/myteam/app }
assignees:               # github-id → prefix (id issuance when there's no tracker)
  younjun-kim: YJ        # prefix is unique within the team
  minsu-kim:   KM
# tracker_type: jira      # (optional) the team's tracker. When set, ids come from the primary tracker; no prefix roster needed
# Local paths live in .waymark.local.yml (gitignored) — §12
```

## 3. Own vs reference (dividing truth by source)

| Layer | Owner | Mechanism |
|---|---|---|
| Planning (why/what) | Confluence/Notion | **Reference** (link) — duplication forbidden |
| Data contracts | Code (schema/types/OpenAPI) | **Reference** |
| Project tracker (backlog/sprint/PM) | Jira/Linear | **Reference** (`tracker:` links) — complement, not mirror |
| **Execution status** (draft→done) | **Folder** | Owned by the repo |
| How · decisions | **Document body** | The only thing the doc owns |
| Assignee | **frontmatter** | §5 |

### Tracker complement — not a replacement (the no-mirror rule)

Waymark **complements Jira/Linear, it does not replace them**. They are **different
axes**:

- **Tracker** = what/who/when + **management and organizational status**
  (backlog/sprint/review/QA/…). For PMs, the org, non-developers.
- **Waymark folders** = design + how + **the agent execution pipeline**
  (draft→approved→in-progress→done). For agents and developers.

Because the axes differ, **no 1:1 mapping exists** — even if the tracker uses a
seven-stage, finer-grained workflow, that is the *management status* axis, while
Waymark's four folders are the *agent start/build/finish* axis. Neither side is "more
fine-grained" than the other; **they measure different things** → no sync compulsion,
just one coarse one-way nudge (Waymark `done` → tracker `Done`).

**Multiple links are fine** (`tracker` is a list, §4): when one unit of work spans
several tickets (backend + frontend tickets, cross-tool), link them all. In that case
the `done` nudge **fans out** to every link. But links piling up can be a smell —
"the issue is too big → split via `supersedes`/`follows`" (§8).

> **Invariant**: Waymark folders and tracker status are **different axes** — they
> never mirror each other. The moment you try to map folders 1:1 onto tracker stages
> (mirroring), dual-source drift is resurrected. No matter how finely the tracker
> slices, Waymark does not grow its folder count (4) to keep up (details go in
> `sub-status`, §10-3).

## 4. frontmatter schema

```yaml
---
id: X-57
title: Party creation · capacity concurrency
summary: Party creation, signup, acceptance + capacity concurrency control   # one line — surfaced by the index (progressive disclosure §8-⑦)
assignee: younjun               # current owner (mutable, ≠ author)
target: [backend, app]          # .waymark.yml repos aliases — the codebases touched (multi-repo OK, §12)
planning: "https://…/notion"    # planning source link — reference only, never duplicated. Omit if none
tracker: ["https://…/JIRA-123", "https://…/LIN-45"]   # tracker issue link(s) — complement, not mirror (§3). Multiple OK; [] or omit if none
---
```

- **`tracker` is a list** — when one unit of work spans several tickets (full-stack =
  backend + frontend tickets, cross-tool), it holds multiple links. For parsing
  stability, write it as an **inline list** (`["a","b"]`). The links are **references
  only, not the id** (the id is one, per §2).

- `status` · `author` · `updated` are **never written by hand** — derived from the
  folder, git, and git respectively.
- `target` is a **list** — for multi-repo/full-stack work, the document defines the
  scope and the work proceeds against it (no co-location needed, §11).
- Headings (the 4 body sections) are verbatim, fixed order (hook/index parsing
  depends on it).

## 5. Assignee vs author

- **`assignee`** = who is responsible right now. **Mutable** (changes on handoff). →
  Explicit in frontmatter. The single answer to "who owns this right now."
- **author** = who created it. **Immutable**. → **Git already records it** (first
  commit author). Not duplicated — derived from git (or stamped once at creation,
  for index display).

## 6. Per-folder `index.md` (auto-generated)

- Each folder has an `index.md`. A script scrapes the frontmatter of the folder's
  files and generates a table of `id · title · summary · assignee · created ·
  updated` (title/summary in the `lang` language). **`created` and `updated` are
  git-derived** — first and last commit dates, `created` via `--follow` so it
  survives status-folder moves. No hand-written date fields (they would drift, §4).
- **Purpose**: AI and humans get a **fast reference from one index** without reading
  every file.
- `in-progress/index.md` = **the current-focus view** (the list of work closest to
  the present).
- **Never edit by hand** (it's a build product). A pre-commit hook or CI regenerates
  it.

## 7. Current state is derived, not maintained (the git model)

> ⚠️ **Unverified hypothesis (v0.1)**: this derivation model is Waymark's most novel
> claim and its **most unfinished part**. It rests on two premises — (a) nearly every
> change to the how goes through an issue document (if hotfixes and workarounds are
> common, coverage breaks and the derivation goes quietly wrong), and (b) humans name
> `supersedes` chains exhaustively (manual in v0.1, see Open Questions). If either
> breaks, the answer to "what does the current system do" degrades to the very **"go
> read the code"** that §0 admits is inadequate. In other words this is still a
> **perspective, not a proven system** — automatic overlap detection and coverage
> instrumentation are v0.2 work.

- `done/` = **frozen history** (immutable like git commits, never touched).
- We **do not maintain** a "current state" document — for the same reason git doesn't
  maintain a current-snapshot document. The live sources are **code (as-built) +
  planning (as-intended) + in-progress**.
- The "current how" per area = **accumulate (union)** the related issues → remove the
  dead ones via `supersedes` → **sort by recency** (like git blame, the most recent
  wins on conflict).
- **The trap**: recency alone is wrong. Old issues that don't overlap are still valid
  → you must **accumulate first**, then let recency win only among issues touching
  the same target. (Automatic overlap detection is v0.2; for now, explicit
  `supersedes`.)

## 8. Weaknesses & mitigations — never fatten; generate/gate

Fatten the document (Spec Kit's 7 files) and drift returns. The mitigation is
**recomputed artifacts + CI gates** — things that cannot drift by construction.

> **How to read this**: many of the "mitigations" below are **v0.2 roadmap**. The
> weaknesses are present tense, but read the mitigations with their timing — what
> actually exists today is 🟢, what doesn't yet is 🟡.

| Weakness | Mitigation | Form | Status |
|---|---|---|---|
| ① No current-state map | Area/thread map **auto-generated** (pointers, not content) | `area-map-gen` | 🟡 v0.2 |
| ② Reference links rot | **ref-integrity gate** (CI resolves links; code refs by symbol/anchor) | `ref-integrity-gate` | 🟡 v0.2 |
| ③ Lost self-containment (agents) | **Dated excerpt** next to the link (date-stamped, never updated, re-fetched on start) | template rule + `/work-new` fetch | 🟢 v0.1 |
| ④ Follow-up fragmentation | `supersedes`/`follows` **threads** + area-map stitching | frontmatter + `area-map-gen` | 🟡 threads = manual (v0.1) / map = v0.2 |
| ⑤ Contract-enforcement paradox | **Reference tests** instead of duplicating schemas; gates execute them (executable spec) | `contract-drift-gate` | 🟡 v0.2 |
| ⑥ Dual-recorded status | **Solved by folder = status** (§2) — single source | — | 🟢 v0.1 |
| ⑦ Doc length → read tokens | **Progressive disclosure** — filter via the index, read only the needed sections | index `summary` + verbatim headings | 🟢 v0.1 |

### ⑦ Doc length / read tokens — progressive disclosure

The single fused document is already a token **saving** versus Spec Kit's 7-file
cascade (§8 intro). The real cost is not "the doc is long" but **"reading everything
you don't need, or reading it repeatedly."** The fix is not splitting — it's
three-tier loading:

1. **index.md (most reads end here)** — the index surfaces the one-line frontmatter
   `summary:`. Most of "what's going on right now" is answered from the index alone,
   without opening a document.
2. **Partial section reads** — the real purpose of the verbatim, fixed-order headings
   (§4). During a build, read only `## How` and skip the entire `## Decisions` log
   (offset/limit). Avoids loading whole files.
3. **The full doc only when asking "why did it end up like this."**

**Hot/Cold structure**: `How` + `Tasks` (hot, thin, near the top) vs `Decisions`
(cold, append-only). The log can grow without touching the hot path, since reads are
per-section. **Multi-file splitting is forbidden** (it resurrects the cascade).

**Length = a split signal**: issue = one feature, so the doc is bounded. If it swells
to 2000 lines, that's not waste — it's the smell of "this issue is too big" → split
into sub-issues via `supersedes`/`follows`. Self-correcting pressure.

**Caching**: re-reads within a session are largely absorbed by prompt caching (the
substance is tiers 1–3 above).

## 9. Enforcement = code (hooks/gates)

Documents persuade; **only code enforces**. Hook roadmap:

- `ref-integrity-gate` — resolves reference links/symbols + **id-uniqueness check**
  (prevents self-collision) (differentiator ①)
- `contract-drift-gate` — runs contract tests; build fails on code–doc mismatch
- `index/area-map generation` — auto-generates per-folder indexes + the area map
- `index merge-driver` — regenerates index.md on merge conflict (§10)

**v0.1 priority**: `ref-integrity-gate` (including id uniqueness) + the `done`
move/freeze first (most differentiating + most needed). The rest is v0.2.

### What code enforces today vs what stays persuasion (honestly)

With "documents persuade, only code enforces" on the sign, we don't hide this
boundary.

- **Enforced by code (today, v0.1)**: id uniqueness · required frontmatter · verbatim
  headings · the `done/` freeze · index regeneration. Pre-commit hooks actually block
  these in the Waymark repo.
- **Still persuasion (agent discipline)**: folder-move judgment, whether a change is
  "material", whether an excerpt is stale, and **the "tests pass" gate on
  `in-progress → done`**.

That last gate has a **structural gap in the default (satellite) mode** — the
pre-commit hook lives in the *Waymark repo*, but the tests that must pass run in the
*target code repo*. No single hook can atomically enforce another repo's tests. So in
v0.1, "tests pass" is **the claim of the agent performing the move**, and the actual
gate is **the human's →done approval confirmation** (rules.md). The cross-repo gate
(reading the target repo's CI status as a condition for the Waymark move) is **v0.2
work** — until then, we state explicitly that this gate is "human confirmation", not
"code enforcement".

## 10. Sharp edges & remedies

1. **`index.md` merge conflicts** (the biggest team-work risk) — it's generated, so
   multiple branches each regenerate it → merge conflicts. **Remedy**: register a
   **merge=regenerate driver** in `.gitattributes` (on conflict, rerun the script =
   the correct answer). Committed, but auto-resolved.
2. **Tracker scale ceiling** — Waymark folders hold only fine-grained execution
   state. Sprint boards, cross-project views, PM views belong to the tracker.
   **Remedy**: the §3 complement model — connect via `tracker:` links but at a
   **different resolution, never mirroring**. (Not-a-replacement was the premise from
   the start.)
3. **Status expansion (blocked · on-hold)** — folder-proliferation risk. **Remedy**:
   the four core folders are fixed (draft · approved · in-progress · done); details
   go in frontmatter `sub-status` (not a folder). Review is a gate, not a folder
   (§2). Folders mark only the liveness boundary.

## 11. Scope / assumptions

- **Audience**: **developers and agents only**. Non-developers (PMs, designers) never
  look at this repo — they use the tracker (Jira/Linear), which Waymark complements
  (§3).
- **Assumption**: agent-driven development — design lives in a document → human
  approval → agent build → review (changes land in the doc) → ship and complete.
  Folder transitions are the gates of this pipeline.
- **Multi-repo agnostic**: the issue document is the unit of work and the `target`
  list defines its scope. The doc lives in one place and references N codebases →
  no co-location needed.
- **Non-goals**: **replacing** the tracker (complement only), a realtime
  collaboration board, external integrations, non-developer UI.
- **Non-goal (important)**: **document content quality/consistency, development and
  design methodology, implementation style** are not Waymark's job — they are
  delegated to dedicated skills (review, TDD, design, doc-writing). What Waymark
  standardizes is only *how units of work are managed and their status* (issue = one
  doc, folder = status, id · headings · freeze). The gates too enforce **structure**
  only and pass no judgment on whether the content is good or bad.

## 12. Deployment model — satellite by default, embedded as an option

Where does the Waymark data (`waymark/` · `index.md` · `.waymark.yml`) live? **The
plugin itself is installed globally and pollutes no repo** — the only question is
data location.

### Default: satellite — Waymark is an independent repo referencing the target repos

```
myteam-backend/     ← managed target (zero Waymark traces)
myteam-app/         ← managed target
~/waymark-yj/       ← the Waymark repo (independent). waymark/ + .waymark.yml
```

- **`repos:`** in `.waymark.yml` references the managed targets (alias → remote).
  **Doesn't have to be just one.**
- Issue `target` and code references use the aliases:
  `backend:src/matching/scorer.ts#MatchScorer`.
- **Zero pollution** (target repos don't know Waymark exists) · **multi-repo
  native** · **solo/team unified** (the only difference is whether the Waymark repo
  is private or shared).

**Local path portability**: `remote` is shareable and portable, but local checkout
paths differ per machine, so they're split out:

```yaml
# .waymark.local.yml  (gitignored, per machine)
paths:
  backend: ~/work/myteam-backend
  app:     ~/work/myteam-app
```

Gates resolve code references by combining `repos.remote` + `paths`.

**Cross-repo linking**: code commits (target repo) and issue-move commits (Waymark
repo) are separate, so the coupling is loose → cross-link them: **the issue id in
the code commit message**, **the code SHA in the issue's `Decisions`**.

### Option: embedded — for single-repo teams that want docs-with-code

Put `waymark/` inside the code repo so code + docs are versioned together in the same
PR. No `repos:` needed (the repo is its own target). Gains co-location and atomic
commits; the cost is being bound to that one repo.

### Choosing

| Situation | Mode |
|---|---|
| Solo (team hasn't adopted) | **Satellite** (private Waymark repo) — zero pollution of targets |
| Multi-repo | **Satellite** — one Waymark repo manages N |
| Single repo + docs-with-code | embedded |
| Shared team tracking | Satellite (shared repo) or embedded |

**Solo→team promotion**: satellite private → make the remote shared, or move to
embedded (`git mv` the `waymark/` folder into the code repo).

---

## Open Questions (unresolved)

- How to define areas/tags — the unit of map generation.
- Automatic overlap (supersede) detection (v0.2). For now, explicit manual
  `supersedes`.
- Concrete implementation of the `index` merge-driver.
