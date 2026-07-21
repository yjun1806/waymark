# Docat

**Spec-driven development for teams whose truth already lives somewhere else.**
*Leave a marker, not a monument.*

## The problem

Spec-Kit-style SDD assumes the repo is the center of the universe: it
materializes what/why (spec), how (plan), data (data-model), contracts,
and tasks as 6–7 markdown files per feature. That works in a greenfield
with no other source of truth.

But most teams already have one:

- **Planning** lives in Confluence / Notion / Linear.
- **The data contract** lives in the code (schema, types, OpenAPI).
- **Progress** lives in the issue tracker.

Bolt full SDD onto that and 5 of its 7 files are *copies* of truth that
already exists elsewhere. The moment planning changes, the spec drifts,
and the plan / data-model / contracts / tasks cascade-drift under it.
Regenerating them wipes your hand edits; hand-syncing makes a human
responsible for reconciling 6 files. This is the single most-reported
SDD failure mode — acknowledged in Spec Kit's own issue tracker.

## Three principles

### 1. Reference, don't duplicate
Truth that already lives in an authoritative place is **linked, never
copied**. Planning → link to Confluence/Notion. Contract → the code is
the source; the doc only references it. If you copied it, you now own a
drift liability.

### 2. Own only the HOW
A Docat doc owns exactly one layer: **the implementation intent and
decisions** — the "how" and "why we did it this way" that exists nowhere
else. Everything a developer actually adds. It delegates the rest:
why → planning source, contract → code, status → the folder it lives in.

### 3. Time-box authority
A doc is authoritative only while its work is live. When done, it's
**frozen** — a dated record of "what we decided then," explicitly not
maintained. A frozen doc can't lie about the present, because it never
claims to describe it. Drift becomes structurally impossible instead of
a discipline you must sustain.

## The one enforcement rule

Documents are persuasion; only code is enforcement. Docat puts its
teeth in **the contract-drift gate**: the data contract is validated
against the code in CI. If the doc's claimed contract and the code
disagree, the build fails. Everything else (freezing on done, index
generation, reference integrity) is a hook, not a hope.

## The shape

**One issue = one thin doc**, four fixed sections:

    WHY       → intent + link to planning source (never restated)
    HOW       → design, decisions, contract *reference* (code is SSOT)
    TASKS     → checklist (fine-grained progress)
    DECISIONS → why-it-went-this-way, deviations logged

A doc is **live while in progress and frozen when done** — the folder it
sits in is its status (the concrete lifecycle lives in DESIGN.md).
Per-folder index auto-generated.

## When to use Docat — and when NOT

**Use it when** an external planning SSOT already exists and your
contract lives in code. Brownfield. Real services. Teams that already
run design-doc culture.

**Don't use it when** there is no external source of truth — a
greenfield with nothing written down yet. Then you *need* the document
to be the source, and Spec Kit / OpenSpec is the right tool. Docat's
whole advantage is delegation; with nothing to delegate to, it has none.

## Lineage

Docat isn't new — it's three proven ideas made to agree: OpenSpec's
change→archive lifecycle, the ADR / design-doc tradition of a single
narrative doc that references rather than restates, and a
folder-as-status workflow that **complements** (never mirrors) the
tracker. Docat is the convention that binds them for the external-SSOT
case no framework targets directly.
