# The spec skeleton, section by section

Copy the skeleton into `specs/NNN-slug/spec.md` and replace each `<placeholder>`. The sections after
it say what each part holds, give one example, and name what to leave out. The examples describe an
invented change, an offline sync feature, to show the form; write what your repository has.

````markdown
# NNN — <title naming the change>

**Status:** Written <date>, not implemented. **Baseline:** `<default branch>` at `<short commit>`.
**Obsoletes:** <nothing, or "spec NNN §N">.

**Relates to:**

- `<file>` §"<heading>" — <why this change depends on it>.
- §<N> — every external reference this spec makes.

---

## 0. TL;DR

1. **<The measured fact that makes the change necessary.>** <One sentence of detail> (§1.1).
2. **<What changes.>** (§2)
3. **<How many phases, in what order.>** (§<N>)

---

## 1. Current state (measured <date>)

### 1.1 <What was measured>

<The fact, its source, the command or file and line, at the baseline commit.>

### 1.<n> Not measured

- <What the plan assumes without a measurement, and which question carries it.>

---

## 2. <The design, in as many sections as it needs>

---

## <N>. Phasing

| phase | what lands | why here |
| --- | --- | --- |
| 1 | <files> | <what it unblocks> |

### <N>.1 What each phase landed

| phase | landed | departures from the plan |
| --- | --- | --- |

---

## <N+1>. Decisions

**D1 — <The decision, as a statement.>** <The alternative, what each costs, and the choice.>

---

## <N+2>. Non-goals

- <What this spec does not do, and where that work would go.>

---

## <N+3>. Open questions

**<N+3>.1 — <The question?>** <Why it is asked.> Needs an answer before phase <n>.

---

## <N+4>. External references

| id | reference | public | URL and pin | cited in |
| --- | --- | --- | --- | --- |
| E1 | <what it is> | yes | <URL>; <pin> | §<n> |
````

## The header

**Holds:** the status, which each phase updates; the baseline commit the measurements were read at;
and what the spec obsoletes.

**Example:** `` **Status:** Written 2026-03-01, revised in place 2026-03-09. Phases 1–2 landed
2026-03-09; phase 3 not implemented. **Baseline:** `main` at `4f2e91c`. **Obsoletes:** spec 003 §5. ``

**Leave out:** an author list, which `git log` holds.

## Relates to

**Holds:** each file, section or external reference the change depends on, with one clause saying
why.

**Example:** `` `src/sync/queue.ts` §"Retry" — the retry loop phase 2 replaces. ``

**Leave out:** files the change merely touches. The phasing table lists those.

## §0 TL;DR

**Holds:** three to ten numbered items a reader can stop after. Each leads with a bold statement and
points at the section that carries it.

**Example:** `1. **Offline edits are lost on 1 in 40 app restarts.** Measured over 2,000 restarts
on the staging build (§1.2).`

**Leave out:** a summary of the spec's structure, and any claim the body does not support.

## §1 Current state

**Holds:** what is true before the change, each fact with its source and date. End with "Not
measured": what the plan assumes without a measurement, and the open question that carries it.

**Example:** `` The queue is flushed in `queue.ts:88-104` at `4f2e91c`; a restart between `persist()`
and `flush()` drops the batch. Reproduced with `scripts/restart-loop.sh 2000`: 51 losses. ``

**Leave out:** what the author remembers. A fact without a source goes under "Not measured".

## The design sections

**Holds:** what changes, section by section: the rule, the interface, the file layout, the check
that holds it.

**Leave out:** the reasoning already stated in a decision. Point at the decision instead.

## Phasing

**Holds:** one row per commit, in order, with what lands and why it comes there. The "What each
phase landed" table below it is filled in as each phase lands, with its departures from the plan.

**Example row:** `` | 2 | the durable queue in `src/sync/queue.ts`, and its tests | phase 3's UI
reads the queue's state | ``

**Leave out:** dates promised for future phases.

## Decisions

**Holds:** one entry per choice between alternatives, each numbered D1, D2 … with the alternative
rejected, what each option costs, and the choice.

**Example:** `**D2 — The queue persists to SQLite, not to a JSON file.** A JSON file is rewritten
whole on every edit, 40 ms at 5,000 queued edits; SQLite appends a row in under 1 ms. The cost is a
schema migration in phase 1.`

**Leave out:** choices with no alternative anyone would take.

## Non-goals

**Holds:** work a reader might expect here that the spec leaves out, and where it would go.

**Example:** `- Conflict resolution between two devices. Spec 008, once phase 3 has measured how
often conflicts occur.`

## Open questions

**Holds:** each question, why it is asked, and the phase that needs its answer. When a question is
answered, write the answer and the date after it, in place.

**Example:** `**9.2 — Does the queue need a size limit?** Phase 2 stores every edit; a device offline
for a week queued 12,000 in testing. Needs an answer before phase 2.`

## External references

**Holds:** one row per reference outside the repository: an id, what it is, whether it is public,
the URL with its pin or the redaction text, and the sections citing it. The body cites the id.

**Example rows:**

```markdown
| E1 | SQLite documentation, "Write-Ahead Logging" | yes | https://www.sqlite.org/wal.html; unversioned, read 2026-03-01 | §2.1, D2 |
| E2 | *Redacted:* crash reports from the staging build's error tracker, read 2026-03-01 | no | — | §1.2 |
```

**Leave out:** the name or location of a private source in a row marked `no`, once the commit
carrying it is about to be pushed to a public repository. The redaction text says what the source
was and when it was read.
