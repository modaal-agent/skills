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
scripts/check-skills.sh              # the nine checks the `skills` job runs
scripts/check-skills.sh --self-test  # each check against a seeded violation
cmp AGENTS.md CLAUDE.md              # what the `rules` job runs
```

Neither needs a toolchain — Markdown and JSON through `grep`, `awk` and `python3` — so both report in
seconds.

## The skills are the product, and this repository is their first consumer

- **A rule a skill teaches is a rule that holds here.** The writing-style rules below govern this
  file, the README and every commit message written here; the spec rules below govern `specs/`. A
  skill whose rules this repository does not follow gives an adopter no reason to adopt it.
- **A rule stated in a skill and stated here is one rule with two audiences.** This file tells a
  contributor what to do in *this* repository; the skill tells an adopter's agent what to do in
  *theirs*. An edit that changes the rule lands in both, in the same commit.

## Writing style: state facts and actions, no aphorisms

**Scope: every character of prose you produce for this project.** Specs, docs, skill bodies, code
comments, commit messages, PR bodies, review findings, and **your replies in chat**. There is no
"informal" channel where this relaxes.

**The test, applied to each sentence:** does it give the reader **a fact they can verify** or **an
action they can take**, with the referent named — the file, the line, the setting, the command, the
number? If it does neither, delete it. A sentence that only characterizes the work, dramatizes a
finding, or summarizes how significant something is carries no information the reader can act on.

Habits to avoid (common LLM-isms):

- **Mannered prose** substitutes metaphor and flourish for direct statement. Instead of "a parameter
  worth varying," the mannered writer produces "a dial worth turning." Instead of "this point still
  matters," they write "this point earns its keep." The phrases exist to display the writer, not to
  convey the idea, and readers can tell. That is why mannered prose irritates: it makes the reader
  work harder so the writer can perform. It is also imprecise — metaphors drag in connotations the
  writer did not choose and cannot control. **The fix is to say what you mean. When a literal phrase
  is available, use it.**
- **Aphoristic juxtapositions** ("Free now, a second migration later"). State the trade-off
  explicitly: what it costs now, what it costs later, which option you recommend.
- **Dramatic reversals and punchlines** ("that direction has reversed"; "upgraded those steps from
  redundant to breaking"). Give the before value, the after value, and the date measured.
- **Negative-space phrasing** ("checked by nobody"; "not cosmetic"; "not the thing to move"). Say
  which check is missing, in which file, what it costs, and when to add it. If the point is that X
  is wrong, name what to do instead — "move the paragraph to `references/troubleshooting.md`", not
  "`SKILL.md` is not the place for it".
- **Metaphor or personification as the load-bearing content** ("a fresh repository has no code to
  fight"; "the gate now has teeth"; "what the spec still owes"). A metaphor may decorate a point
  already stated literally; it may not be the only statement of that point. Documents do not owe,
  want, or know things — name who does the work, in which file, by when.
- **Rhetorical contrast standing in for content** ("verified, not merely committed"; "it is not that
  X, it is that Y"). State both facts separately and drop the contrast.
- **The closing paragraph that generalizes the lesson.** This is where aphorisms concentrate: a
  section ends, and the urge is to extract a portable moral. Either write a concrete rule with a
  named home — the check to add, the file to add it to — or write nothing.

## Git state — confirm every commit

- **Never commit, amend, push or rewrite history without confirmation in the current turn.**
  "Write the skill", or approval of a *previous* commit, is not authorization for the next one. When
  work is ready: stop, summarize what changed, ask.
- **Never touch the index or restore the tree.** `git add`, `git reset`, `git stash`,
  `git checkout -- <path>`: off-limits unless asked for in this turn. Staged versus unstaged is the
  reviewer's record of how far they have read, and reverting your own edits to "recover" discards
  work they have not seen. If a commit is authorized and the index is partly staged, ask which scope
  before running anything.
- **Subject line:** imperative, naming the change — "Fail S5 on a reference over 250 lines". Work
  backed by a spec carries the slug, **and the commit that writes the spec is the first such
  commit**. So a spec numbered 002 produces:

  ```
  [002-writing-style-skill] Specify the rules the skill teaches and the reference split
  [002-writing-style-skill] Write SKILL.md and the two reference files
  [002-writing-style-skill] List the skill in README and mention it in CONTRIBUTING
  ```

  The slug names the feature and the rest names what that commit does, so the subject after the
  bracket does not repeat the slug. No spec in play, no prefix — do not invent one.

## Changes reach `main` through a pull request

- Code goes on a branch and through a PR, so [`ci.yml`](.github/workflows/ci.yml)'s two jobs run
  before it lands. They trigger on `pull_request` and on push to `main`: a push to a branch with no
  PR open runs nothing, so open the PR to get a build.
- Any merge strategy — merge, rebase or squash — chosen for the nature of the PR.
- A change touching no code may go straight to `main`: a spec, README, CONTRIBUTING or SECURITY
  wording, `AGENTS.md`/`CLAUDE.md`. `skills/`, `scripts/`, `.github/` and `.claude-plugin/` are
  code — **a skill is code here.** No tag gates it and no release carries it: the install channels
  read this repository, so an edit under `skills/` reaches adopters the moment it lands on `main`.
- Branch when the work starts. If code is ready and the checkout is `main`, ask which branch.
- Pushing, opening a PR and merging one each need their own go-ahead.

## Specs are a decision record

- **While the feature is being worked on, a spec may be edited in place** to keep the plan current.
  Where later work overturns an important earlier decision, leave a short note saying what it
  replaced and why.
- **Once the feature is done, a spec is amended by addition.** A feature is done when the commit
  that lands its last planned phase reaches `main`. An addition that supersedes an existing claim
  names it by section, and the superseded section takes a line pointing forward to the addition.
- **A closed spec may take a follow-up file beside it** instead of an appended section —
  `specs/001-<slug>/followup-<topic>.md`. The rule inside it is the same: additions only, and it
  names by section what it supersedes.
- **A new spec names what it obsoletes**, by number and section ("obsoletes 001 §4.6").
- **Writing a spec is not authorization to implement it.** When the task is a spec, produce only the
  spec document — no skill, script or workflow edit, not even the one line that looks ready. When it
  is written, stop and ask.

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

## Scope

- A skill that duplicates one already published beside the code it documents belongs in that
  repository, not this one. README.md lists the two that live elsewhere and why.
- There are no release tags and no release assets. A change reaches adopters by landing on `main`;
  there is nothing to version and nothing to publish.
