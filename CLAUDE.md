# Agent rules

Rules for working in this repository. They are the additions to [CONTRIBUTING.md](CONTRIBUTING.md),
not a summary of it.

`AGENTS.md` and `CLAUDE.md` are one file kept in two places, byte for byte. Edit `AGENTS.md`, then
`cp AGENTS.md CLAUDE.md`; [`ci.yml`](.github/workflows/ci.yml)'s `rules` job runs `cmp` on the two
and fails if they differ.

**Read first, by question:**

| you need | read |
| --- | --- |
| what this repository publishes and how an adopter installs it | [README.md](README.md) |
| how a skill is added, what the checks hold it to, how it reaches adopters | [CONTRIBUTING.md](CONTRIBUTING.md) |
| how a vulnerability is reported and what counts as one here | [SECURITY.md](SECURITY.md) |
| what an adopter's agent is told to do | `skills/<name>/SKILL.md` |
| the plan for a change too big to carry in a commit message | `specs/` |

Run from the repository root:

```bash
scripts/check-skills.sh              # the checks the `skills` job runs
scripts/check-skills.sh --self-test  # each check against a seeded violation
cmp AGENTS.md CLAUDE.md              # what the `rules` job runs
```

Neither needs a build: `grep`, `awk`, `python3`, and `pwsh` for S12 and S13, so both report in
seconds. Without `pwsh` on the PATH, S12 and S13's PowerShell half report skipped; CI runs them.

## The skills are the product, and this repository is their first consumer

- **A rule a skill teaches is a rule that holds here.** The writing-style rules below govern this
  file, the README and every commit message written here; the spec rules below govern `specs/`. A
  skill whose rules this repository does not follow gives an adopter no reason to adopt it.
- **A rule stated in a skill and stated here is one rule with two audiences.** This file tells a
  contributor what to do in *this* repository; the skill tells an adopter's agent what to do in
  *theirs*. An edit that changes the rule lands in both, in the same commit.

## Writing style

**Scope: every piece of prose an agent writes here**: documents, code comments, commit messages,
pull-request descriptions, review comments, and replies in chat.

1. **Every sentence gives the reader a fact they can check or an action they can take**, with the
   referent named: the file, the line, the command, the number, the date. Delete a sentence that
   does neither.
2. **Write the way you would say it to a colleague.** Reread each sentence, and rewrite any you
   would not say aloud.
3. **Use short words, short sentences and short paragraphs.** Split a sentence over 25 words, and
   keep a paragraph to five sentences.
4. **Cut needless words**: "in order to", "just", "simply", "please note", "it is important to
   note", and "additionally" at the start of a sentence.
5. **Use the active voice, and start a statement with its verb.** Write "is" where "serves as" or
   "stands as" appears, and rewrite "there is" and "there are" around the subject.
6. **Say what is.** Replace "it's not X, it's Y", "not just X but Y", and any phrasing that names
   only what is absent, with a statement of what is there.
7. **Be definite, specific and concrete**: the number instead of the adjective, the path instead of
   "the config", the date instead of "recently".
8. **Use no figure of speech you have seen in print, and no metaphor as the only statement of a
   point.** Documents do not owe, want or know things: name who does the work, and where.
9. **Use no jargon, buzzwords or extravagant adjectives**, such as leverage, robust, streamline,
   empower, tackle, facilitate, vibrant, groundbreaking and pivotal.
10. **Do not inflate significance.** Nothing "underscores", "highlights" or "marks a turning
    point". Give the value before, the value after, and the date it was measured.
11. **Write no rhythm devices**: no list of three kept for its cadence, no aphoristic pairing, no
    dramatic reversal, no contrast standing in for content, no closing line that draws a moral.
    End when the content ends.
12. **Say what the reader is to do, and where**: the command to run, the file to edit, the person
    to ask.

Break any of these rules sooner than write something unclear.

*Maintained by the `writing-style` skill down to this line. This repository's own lines go below.*

In this repository the scope also covers skill bodies and their reference files under `skills/`.
Before-and-after pairs for the habits the rules remove are in
[skills/writing-style/references/habits.md](skills/writing-style/references/habits.md).

## Git and pull requests

- **Commit, amend, push or rewrite history only when the user confirms it in the current turn.**
  A request to write the code, or approval of an earlier commit, does not cover the next commit.
  When the work is ready, stop, summarize what changed, and ask.
- **Leave the index and the working tree as the user left them.** Run `git add`, `git reset`,
  `git stash` or `git checkout -- <path>` only when the user asks for it in this turn. What is
  staged is the reviewer's record of how far they have read. When a commit is confirmed and the
  index is partly staged, ask which scope to commit before running anything.
- **Write the subject line in the imperative, naming the change**: "Fail the build on a missing
  license header". Work that follows a spec carries the spec's directory name as a prefix,
  `[NNN-slug]`, starting with the commit that writes the spec. Work without a spec carries no prefix.
- **A change reaches the default branch through a pull request**, so CI runs before it lands.
  Create a branch when the work starts; when finished work sits on the default branch, ask which
  branch to move it to. Pushing, opening a pull request and merging each need their own go-ahead.

Decisions for this repository:

- **Default branch:** `main`.
- **Merge strategy:** Merge, rebase or squash, chosen per pull request.

*Maintained by the `git-discipline` skill down to this line. This repository's own lines go below.*

In this repository:

- **A spec's commit series**, for a spec numbered 002, reads:

  ```
  [002-skill-evals] Specify the eval cases and how they run
  [002-skill-evals] Add the eval cases for writing-style
  [002-skill-evals] Run the evals in CI and record the first results
  ```

- **CI runs on a pull request.** [`ci.yml`](.github/workflows/ci.yml)'s two jobs trigger on
  `pull_request` and on push to `main`, so a push to a branch with no pull request open runs nothing.
- **A change touching no code may go straight to `main`**: a spec, README, CONTRIBUTING or SECURITY
  wording, `AGENTS.md`/`CLAUDE.md`. `skills/`, `scripts/`, `.github/` and `.claude-plugin/` are
  code, and a skill is code here. No tag gates it and no release carries it: the install channels
  read this repository, so an edit under `skills/` reaches adopters the moment it lands on `main`.

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

In this repository:

- **The default branch is `main`**, so a feature is done when the commit landing its last planned
  phase reaches `main`.
- **When the task is a spec, the spec document is the whole change**: no skill, script or workflow
  edit, not even the one line that looks ready.
- **§"Public-facing text is hermetic" below applies the reference rules** to every file and commit
  message here, not only to specs.

## A skill is written for an agent in someone else's repository

- **The audience is an agent working in a repository that is not this one**, on a task the skill
  names. How this repository is built, `scripts/check-skills.sh`, the `--self-test` and the install
  channels are CONTRIBUTING.md's subject and this file's; none of it goes in a skill.
- **A skill says what to do and does not re-derive why.** The measurement behind a rule stays in the
  spec that measured it, and the reference material in README and CONTRIBUTING.
- **`name:` is the directory name.** A skill is invoked by its directory, so the two cannot differ,
  and `synced` is reserved under `~/.claude/skills/`. Check S2.
- **Frontmatter carries the Agent Skills standard's six keys only** — `name`, `description`,
  `license`, `compatibility`, `metadata`, `allowed-tools` — one key per line, with no unquoted value
  carrying `: `. Claude Code accepts fourteen more; packaging the directory for the Skills API or
  claude.ai rejects each of them by name, and the cross-agent `skills` CLI refuses a file whose
  value carries an unquoted `: ` at all. Checks S1 and S3 name the offending key.
- **`description` is what auto-invocation is decided from**, and it is resident in every session
  whether the skill is used or not. Name the triggers — the task, the file, the command, the error
  text — not the topic. S4 requires it and holds it to 1024 characters.
- **`SKILL.md` stays under 400 lines and each `references/*.md` under 250.** The body is resident for
  every turn after the skill is invoked; a reference costs nothing until the agent opens it. A new
  fact goes in the body while it fits, and in the reference file for its subject once it does not.
  S5 holds both budgets, S6 every link between the files.
- **No version literal in a skill.** A pinned version is wrong the day after the next release of
  whatever it names, and no check in the adopter's repository reads it. Write the command that
  resolves the current version instead.
- **A skill states a practice that transfers.** If a rule only works with Modaal's internal tooling,
  leave it out and say so; do not generalize it into a claim that is untrue elsewhere.

## State a rule once

- The frontmatter key list and the two line budgets are written in `scripts/check-skills.sh` —
  `STANDARD_KEYS`, `SKILL_BODY_MAX`, `REFERENCE_MAX`. Restating a number in a third place is how the
  gate and the documents come to disagree; this file and CONTRIBUTING.md name the check that holds
  each one.
- README.md's skill table is the index, maintained by hand. S9 fails when a directory under
  `skills/` is missing from it, so a new skill lands with its README row in the same commit.
- The plugin name is `.claude-plugin/plugin.json`'s `name`, and `marketplace.json` carries an entry
  with that name whose `source` resolves to a directory holding `skills/`. S8 compares the two.

## What goes in which document

- **README.md** — what this repository publishes: the skill index, the install channels, the layout.
- **CONTRIBUTING.md** — how a skill is added, what the checks hold it to, how it reaches adopters,
  licensing.
- **SECURITY.md** — how a vulnerability is reported and what counts as one for a repository whose
  product is instructions an agent executes.
- **AGENTS.md / CLAUDE.md** — rules only, and one file in two places. If you are about to write a
  paragraph explaining what something *is*, it belongs in one of the other two.
- **skills/`<name>`/** — what an agent does in an adopting repository, and nothing about how this
  repository is built. Everything longer than the body's budget goes in `references/`.
- **specs/`NNN-slug`/spec.md** — the plan for a change too big to carry in a commit message: what is
  true now (measured, with file and line references), what the rule becomes, the phasing, the
  decisions and what stays open. Written before the change and left in place after it, as the record
  of why. It never becomes the place a *rule* is stated — that is here.

## Public-facing text is hermetic

The origin is public. Everything pushed to it — files on every branch, commit messages, pull-request
titles, bodies and review comments — is readable by anyone, and stays readable through forks, clones,
cached commit views and pull requests after a history rewrite. A reader holding this repository and
the public internet must be able to resolve every reference in it.

- **No reference to a private repository or private work**, in any file or commit message: no
  private repository or project name, internal path, internal document or internal numbering. State
  a finding from private work by what was measured and when, without naming where. A skill is read
  by strangers on their own codebases, so `skills/` is where a leak costs most.
- **Every internal cross-reference resolves at the same commit.** A `§N.M` resolves to a heading or
  a numbered definition in the same document, `file:line` to that line, and "spec NNN §N" to a
  heading in `specs/NNN-<slug>/spec.md`. "§5.4 from spec-24" fails in a repository with no
  `specs/024-*`, and so does a commit message citing a spec section its commit's tree lacks.
- **Every external reference is to a public source**: a URL or an `owner/repository` path a reader
  can open, pinned to a commit, page revision or version where the text cites a line, a count or a
  quotation from it.
- **Every spec lists its external references in an `External references` section**, one row per
  reference: an id (`E1`, `E2` …), what it is, whether it is public, the URL with its pin or the
  redaction text, and the sections citing it. A section of an external document is cited after its
  id: `E16 §11`.
- **A private reference is named only in that section, and the rest of the spec cites its id.**
  Before the commit carrying it is pushed, replace the row's name and location with a redaction text
  that starts `*Redacted:*` and says what the reference is and when it was read. Redacting at merge
  is too late: the branch's commits are already public.
- **Run `scripts/check-skills.sh` before a push that carries a spec.** S15 fails a section
  reference with no heading to resolve to, and S16 fails an external id with no row or a private row
  without its redaction.

## Scope

- A skill that duplicates one already published beside the code it documents belongs in that
  repository, not this one. README.md lists the two that live elsewhere and why.
- There are no release tags and no release assets. A change reaches adopters by landing on `main`;
  there is nothing to version and nothing to publish.
