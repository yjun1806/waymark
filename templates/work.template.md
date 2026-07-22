<!--
  Waymark issue doc — ONE ISSUE = ONE THIN FILE.
  Principles:
   1. Reference, don't duplicate — link truth that lives elsewhere, never copy it.
   2. Own only the HOW — this file owns implementation intent + decisions. Nothing else.
   3. Time-box authority — the FOLDER is the status. When done, git mv to done/ and freeze.

  Setup:
   - Copy to waymark/draft/<id>-<slug>.md, then git mv between status folders as it moves:
       draft/ → approved/ (👤 human approves) → in-progress/ → done/ (frozen)
     Review/tests are a GATE on in-progress → done, not a folder.
   - id: tracker id (JIRA-123) if you have a tracker; else <PREFIX>-<seq> from the
     .waymark.yml roster (e.g. YJ-6). Never a shared global counter.
   - slug: ALWAYS ASCII kebab (party-signup) for cross-OS git safety.
   - Language: title / summary / body are authored in your team's language
     (.waymark.yml `lang`: en for English teams, ko for Korean, …). Only the slug is ASCII.
   - There is NO `status` field — the folder is the single source of status.
   - The 4 headings are VERBATIM and FIXED ORDER (hooks/index parsing depend on it).
     Empty section? Keep the heading, write "_n/a_".
   - Delete this comment and all <bracketed guidance> once filled.
   - Each folder's index.md is auto-generated — never hand-edit it.
-->
---
id: <id>                    # JIRA-123 (tracker) or YJ-6 (.waymark.yml roster: <prefix>-<seq>)
title: <one-line title — the human name, in your team's language>
summary: <one line — surfaced by the index (progressive disclosure)>
assignee: <github-id — current owner, mutable, ≠ author>
target: [<repo/app>, ...]   # codebases this touches (list, multi-repo OK)
planning: "<link to planning source (Confluence/Notion). Reference only, never copy. Omit if infra.>"
tracker: "<link to the tracker issue. Complement, not mirror. Omit if none.>"
---

# <id> · <title>

## Why
<!-- Intent + scope, 1–3 lines, then LINK the planning source. Do NOT restate the PRD.
     Infra with no planning source? Say "Infra — no planning source." -->

## How
<!-- THE ONE SECTION YOU TRULY OWN. Design, approach, key decisions — enough to reproduce
     the implementation from this alone. Data contract (schema / types / API shape):
     REFERENCE the code — the code is the SSOT. Don't paste the schema here; copying = drift debt. -->

## Tasks
<!-- Fine-grained progress. Checkboxes. -->
- [ ] T1 …

## Decisions
<!-- Why it went this way. Open questions, planning TBDs, and any deviation from planning
     (log it — don't silently diverge). Survives into done/ (frozen) as the durable "why".
     Append-only. -->
