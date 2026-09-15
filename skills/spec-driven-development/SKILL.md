---
name: spec-driven-development
description: Write the spec rules into a repository's agent rules file, AGENTS.md and CLAUDE.md, and write, review or amend a spec by hand in specs/NNN-slug/spec.md. Covers measuring the current state before planning, phasing the work into one commit per phase under the spec's slug, editing the spec in place while its feature is in progress and by addition once it is done, and listing every external reference so a public repository names nothing private. Use when asked to add or update spec rules in AGENTS.md or CLAUDE.md; when asked to write, review, update or amend a spec, design document or implementation plan in the spec directory; when a change is too big to describe in a commit message; or when a spec cites a private repository, a section that does not resolve, or an unpinned source.
license: MIT
---

# Spec-driven development

This skill does two jobs.

- **Write the section.** Put the block below into the repository's agent rules file. Every session
  reads that file from its first turn, so "writing a spec is not authorization to implement it" is
  read before the work starts, which a skill's own text cannot arrange.
- **Run the flow.** Write, review or amend a spec in the spec directory, `specs/NNN-slug/spec.md`.

## The section

Write this block verbatim, from its heading to its last line:

```markdown
## Specs

- **Write a spec for a change too big to describe in a commit message**, in
  `specs/NNN-slug/spec.md`: `NNN` counts up from `001`, and the slug names the feature.
- **Writing a spec is not authorization to implement it.** When the task is a spec, write the
  document alone, then stop and ask.
- **While the feature is in progress, edit the spec in place** to keep the plan current. Where later
  work overturns an important decision, leave a short note saying what it replaced and why.
- **Once the feature is done, amend the spec by addition.** A feature is done when the commit that
  lands its last planned phase reaches the default branch. An addition that supersedes a claim names
  that claim's section, and the section takes a line pointing to the addition. A closed spec may
  take a follow-up file beside it instead, `followup-<topic>.md`, under the same rule.
- **A new spec names what it obsoletes**, by number and section: "obsoletes 001 §4.6".
- **Every reference in a spec resolves for its reader.** A section reference points at a heading in
  the same file. An external reference is to a public source, pinned where the spec cites a line, a
  count or a quotation, and has a row in the spec's `External references` section. In a public
  repository, a private reference is named only in that section, and redacted before the commit
  carrying it is pushed.

*Maintained by the `spec-driven-development` skill down to this line. This repository's own lines go below.*
```

## Write the section

**The agent rules file** is `AGENTS.md`, and every byte-identical per-agent copy the repository
carries, `CLAUDE.md` among them.

1. **List which of `AGENTS.md` and `CLAUDE.md` the repository has.** With neither, stop: say so, and
   name the `repository-init` skill, which writes both. With both, run `cmp AGENTS.md CLAUDE.md`
   before editing; a `CLAUDE.md` that matches is a copy.
2. **Find `## Specs`** in `AGENTS.md` when it exists, otherwise in the one file present, and make
   every edit below in that file. Also list any other section that states spec rules, such as a
   heading naming specs, design documents or plans, to show the user in step 4.
3. **When the heading is absent**, insert the block after the last section that ends at a line
   naming the `writing-style` or `git-discipline` skill, and after any lines the repository added
   below that line. With neither section present, append the block at the end of the file.
4. **When the heading is present, or step 2 found other spec sections**, compare the block with that
   text: from the heading to the line naming this skill, or to the next `##` heading when there is
   no such line. Show the user the difference, and replace the text only when the user confirms.
   Offer to move the repository's own examples and exceptions below the skill's line; lines already
   below it are the repository's own, so leave them.
5. **Copy the edited file over each file that was a copy in step 1**: `cp AGENTS.md CLAUDE.md`.
   Leave a symlink or an `@AGENTS.md` import as it is. Report a `CLAUDE.md` that differed before
   the edit as drift, and ask the user which file holds the rules they want.
6. **Stage nothing and commit nothing.** Report the files changed and the section's line range, and
   propose a commit subject, such as "Add the spec rules to the agent rules file". When the
   `git-discipline` skill is installed, its confirmation rule covers this commit.

## The flow

1. **Decide whether the change needs a spec.** Write one when the change is too big to describe in a
   commit message: several commits, a decision between alternatives with different costs, or a
   measurement that decides the plan. A fix with one cause, a rename or a dependency bump goes in a
   commit message instead.
2. **Pick the directory.** `ls specs/` lists the specs; the new one takes the next number, and a slug
   of two to five words naming the feature: `specs/007-offline-sync/spec.md`.
3. **Measure before specifying.** Read every fact the plan depends on from the repository, and write
   it down with its source: the file and line, or the command and its output, with the date and
   `git rev-parse --short HEAD`. A plan written from memory plans against a repository that may not
   exist.
4. **Write the document** from [references/spec-skeleton.md](references/spec-skeleton.md): the
   header, "Relates to", §0 TL;DR, §1 Current state, the design sections, phasing, decisions,
   non-goals, open questions, and external references. Keep each open question tied to the phase
   that needs its answer.
5. **Stop and ask.** Writing a spec is not authorization to implement it. Report the path, the
   TL;DR, and the open questions that block phase 1.
6. **Implement by phase, once asked.** One phase per commit. Each commit subject carries the spec's
   directory name as a prefix, `[007-offline-sync]`, and the commit that writes the spec is the
   first of the series. When the `git-discipline` skill is installed, it owns the subject-line
   format and the confirmation before each commit.
7. **Keep the spec a decision record.**
   - While the feature is in progress, each phase edits the spec in place: the status line names the
     phases landed, and the plan is corrected where the work departed from it. Where a phase
     overturns an important decision, leave a note in place, such as "*Revised 2026-03-02, phase 2:*
     the cache was per-user; a shared cache halved memory, so ...".
   - The feature is done when the commit that lands its last planned phase reaches the default
     branch. From then on, change the spec by addition only: a new section, or a
     `followup-<topic>.md` beside it, naming by section each claim it supersedes, and a line in each
     superseded section pointing forward.
8. **Keep every reference resolvable**, as the next section describes.

## References a reader can follow

A reader holds the repository and the public internet. Every reference in the spec has to resolve
for that reader.

- **Section references** point at a heading in the same file: `§4.2`. List the headings with
  `grep -n '^#' specs/007-offline-sync/spec.md` and check each `§` against them. A decision or
  question number, such as D3 or Q2, points at its definition in the same file.
- **Line references** into this repository name the commit they were read at, because a later edit
  moves the line: "`src/sync.ts:40-52` at `a1b2c3d`". Where a section heading will do, name the
  heading instead.
- **References to another spec** name its number and a heading that exists: "spec 004 §3".
- **External references** each take a row in the `External references` section: an id (`E1`,
  `E2` …), what the reference is, whether it is public, the URL with its pin or the redaction text,
  and the sections citing it. The body cites the id, and a section of an external document is cited
  after its id: `E3 §4`. Pin a reference the spec quotes, or cites a line or a count from: a commit
  hash, a page revision, a package version, an arXiv version.
- **Private references in a public repository.** Check the repository's visibility with
  `gh repo view --json visibility --jq .visibility` on GitHub, or ask the user. When it is public,
  name a private repository, document or path only in its row, and cite the id everywhere else.
  Before the commit carrying the row is pushed, replace the row's name and location with a redaction
  text that starts `*Redacted:*` and says what the reference was and when it was read. A pushed
  commit stays readable in clones, forks and pull requests after a history rewrite, so redacting at
  merge is too late. In a private repository, redact before the merge into any published branch.

Before a push, check the spec's ids against its rows:

```bash
grep -o 'E[0-9][0-9]*' specs/007-offline-sync/spec.md | sort -u   # every id the spec mentions
grep -n '^| E[0-9]' specs/007-offline-sync/spec.md                # every row
```

## Reviewing a spec

Read the spec against these, and report each gap with its section:

- Every fact in §1 has a source and a date, and the baseline commit is in the header.
- Every `§`, decision and question reference resolves to a heading or definition in the file.
- Every external reference has a row, every quotation and count cites a pinned source, and in a
  public repository every private row is redacted.
- Every decision states the alternative it rejected and what each costs.
- Every phase is one commit's worth of work, and says why it comes in that order.
- Every open question says which phase needs its answer.

## What stays manual

No tool in this flow generates a spec, assigns its number or checks that §1 was measured. The
commit-subject prefix is the only part a reviewer can check mechanically, by reading the log. The
review in the previous section is where the rest is caught.
