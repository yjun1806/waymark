---
name: waymark-work
description: Create a new Waymark issue doc (Why/How/Tasks/Decisions) in waymark/draft/ — gathers the planning source and tracker issue links (multiple / cross-tool OK), allocates exactly one id, and scaffolds from the template. Use when starting substantive new work, or when the user asks to create/open a new issue, task, ticket, or work item ("new issue", "start working on X", "open a task", "work-new", "새 이슈 만들어", "새 작업 시작", "이 기능 개발 시작").
---

# Waymark work — new issue doc

Create one thin issue doc (one issue = one file) in `waymark/draft/`. Reference external truth,
never copy it. Only run this where Waymark is set up (a `waymark/` folder exists); if not, suggest
`waymark init` first. Speak in the repo's `lang`.

## Step 1 — Read config
Read `.waymark.yml` (and `.waymark.local.yml` if present) for `lang`, `repos` (alias → remote),
`assignees` (github-id → prefix), and whether a `tracker_type` is configured (the tracker tool,
used for id allocation). Note: `tracker_type` (config, the tool) is distinct from a doc's
`tracker` frontmatter (the issue links).

## Step 2 — Basics
Gather the issue title and which repos it targets (MUST be aliases declared in `repos:`).

## Step 3 — Ask EXPLICITLY what to link (don't assume none)
- **Planning source** (the why/what): a Confluence / Notion / PDF / doc link. "None — verbal
  discussion or pure infra" is a valid answer; record it as such, don't invent one.
- **Tracker issues** (Jira / Linear / GitHub Issues / any tool): the issue(s) this work syncs
  with. **Multiple allowed** when one work unit spans several tickets (backend + frontend, or a
  cross-tool link). "None" is valid.

These are references, not copies — link them, never mirror their contents. If the tracker list
keeps growing large, that's a smell the issue is too big — suggest splitting it.

## Step 4 — Allocate the id (always exactly ONE)
- If a `tracker_type` is configured AND the user designates one tracker issue as primary → id =
  that primary tracker id (e.g. JIRA-123). Central, atomic, unique.
- Else (no tracker, or none/multiple with no single primary) → prefix-seq: resolve the user's
  prefix from `assignees` (`gh api user`, fallback git email), scan `waymark/**` for existing
  `<prefix>-<n>` ids, use `<prefix>-<max+1>`. Never a shared global counter.

Additional tracker links are entries in the `tracker` list — never the id.

## Step 5 — Scaffold from the template
Create `waymark/draft/<id>-<slug>.md` from `${CLAUDE_PLUGIN_ROOT}/templates/work.template.md` (or
under `~/.claude/plugins/*waymark*/templates/`; else reproduce the Why/How/Tasks/Decisions structure):
- `<slug>` = ASCII kebab of the title (transliterate if non-ASCII). The filename is always ASCII.
- Fill frontmatter: `id`, `title` (in `lang`), `summary` (one line, `lang`), `assignee` (current
  github-id), `target` (repo aliases), `planning` (link or omit if none), `tracker` (inline list
  `["url", ...]`, or omit / `[]` if none). No `status` field — the folder is the status.
- Author Why/How/Tasks/Decisions in `lang`. At draft: fill `Why` (+ a rough `How`); leave the rest
  as headings.
- Reference planning/tracker by link only; a short DATED excerpt marked "non-authoritative, see
  link" is allowed. Delete the template's comments and <bracketed guidance>.

## Step 6 — Confirm
Confirm the created path. It's in `draft/`. Status moves happen automatically as work progresses
(Claude `git mv`s per the rules in CLAUDE.md: draft → approved after human approval → in-progress →
done after the gate passes; done is frozen). Don't hand-edit any index.md.
