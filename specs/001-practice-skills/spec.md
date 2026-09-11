# 001 — Four practice skills: writing style, spec-driven development, repository initialization, git discipline

**Status:** Written 2026-09-11, not implemented. **Baseline:** `main` at `1753a20`. **Obsoletes:**
nothing.

**Relates to:**

- [AGENTS.md](../../AGENTS.md) — §"Writing style" (`:40-77`), §"Git state" (`:78-100`), §"Changes
  reach `main`" (`:101-113`), §"Specs are an append-only decision ledger" (`:114-130`), §"A skill is
  written for an agent in someone else's repository" (`:131-157`). These four sections are the
  source material for the four skills; §5 of this spec is the rule that keeps a skill and the
  section it came from from becoming two answers to one question.
- [README.md](../../README.md) `:19-22` — the four planned rows, which name the four skills this
  spec plans.
- [CONTRIBUTING.md](../../CONTRIBUTING.md) §"Adding a skill" (`:34-50`) and §"Running the checks"
  (`:52-81`) — the procedure and the nine checks each of the four passes.
- [scripts/check-skills.sh](../../scripts/check-skills.sh) `:38` (`STANDARD_KEYS`), `:43-45`
  (`SKILL_BODY_MAX`, `REFERENCE_MAX`, `DESCRIPTION_MAX`) — the budgets §3–§6 size against.
- [kotlin-ksp-mocks](https://github.com/modaal-agent/kotlin-ksp-mocks) spec `001-agent-skill` and
  [swift-sourcery-templates](https://github.com/modaal-agent/swift-sourcery-templates) spec
  `002-annotation-registry-and-agent-skill` — the two skills already published, and the two spec
  documents §1.3 measures the flow from.

Every fact in §1 was read from the three checkouts on 2026-09-11: this repository at `1753a20`,
`modaal-agent/kotlin-ksp-mocks` and `modaal-agent/swift-sourcery-templates` at their working `main`
and `master`, and `modaal-agent/duet-tutorials` at its working `main`.

---

## 0. TL;DR

1. **The four skills' source material already exists, three times over.** The writing-style section
   is 38 lines and is byte-identical across `kotlin-ksp-mocks/AGENTS.md:27-64`,
   `swift-sourcery-templates/AGENTS.md:29-66` and `AGENTS.md:40-77` here, except for three hunks
   that swap a repository-specific example (§1.2). The skill is the fourth copy, and the one a
   fifth repository installs instead of copying.
2. **Four directories under `skills/`:** `writing-style`, `spec-driven-development`,
   `repository-init`, `git-discipline` (§2.1). Names are unprefixed, which is a decision with a
   known cost (§10, D1).
3. **What each teaches** is in §3–§6: the sentence test and the LLM-isms to delete; the manual spec
   flow measured from a run that produced eight commits (§1.3); the eight files and one CI job a
   repository carries on day one (§1.4); the confirmation, index and subject-line rules, and the
   three things three repositories do differently (§1.5).
4. **The four compose by naming each other, never by restating each other** (§2.3), and share three
   terms each owned by one skill (§2.4). The agent rules file is one of them: `AGENTS.md` plus every
   byte-identical copy the repository carries. Three of the four edit it, and all three write the
   same four steps, so none can leave `CLAUDE.md` behind (D6).
5. **The writing-style skill cannot enforce itself.** A skill's body is resident only after the
   skill is invoked, and prose is produced in every turn. Its instruction is therefore to copy its
   rules into the agent rules file, which is resident from turn one; the skill is the source text
   and the review checklist (§3.1, D3). `spec-driven-development` copies two of its rules the same
   way, for the same reason (§4.1 step 8).
6. **The gate is the nine checks that already run** (`scripts/check-skills.sh`), plus two: S10, a
   skill that names another skill names one that exists (§8.2), and S11, a skill that names
   `AGENTS.md` also names `CLAUDE.md` (§8.3).
7. **Six phases, six commits**, ordered by which skill owns a shared term — `repository-init`, its
   two scripts, `writing-style`, `git-discipline`, `spec-driven-development`, then the README,
   CONTRIBUTING and the cross-skill checks (§9).
8. **`repository-init` ships a script**, in bash and PowerShell, bundled in the skill and called as
   `${CLAUDE_SKILL_DIR}/scripts/init-repo.sh` — never fetched over the network, which this
   repository's own SECURITY.md would report (§5.5, D10). Its flags follow `specify init` from
   github/spec-kit: `--agent`, `--script sh|ps`, `--force`, `--dry-run`, `--non-interactive`. S12
   diffs the trees the two variants write, so neither can fall behind (§8.4, D11).
9. **No eval suite in this spec.** Both published skills have one; this repository has no runner
   wired and the cases cost model calls. Deferred to spec 002 (§11, §12.4).

---

## 1. Current state (measured 2026-09-11)

### 1.1 What this repository holds at the baseline

`1753a20` is the root commit: 11 files, 1107 insertions. `skills/` does not exist. `specs/` does not
exist before this document. The two jobs in `.github/workflows/ci.yml` are `rules` (`:13`, running
`cmp AGENTS.md CLAUDE.md` at `:22`) and `skills` (`:29`, running `scripts/check-skills.sh` at
`:39`). The script reports `S1–S7, S9 — no skill directory under skills/ yet` and runs S8 alone.

`AGENTS.md` is 193 lines in nine sections. Four of them are the source material named above. The
remaining five are about this repository and do not become skill text: §"The skills are the product"
(`:31-39`), §"A skill is written for an agent in someone else's repository" (`:131-157`), §"State a
rule once" (`:158-168`), §"What goes in which document" (`:169-184`), §"Scope" (`:185-193`).

### 1.2 The writing-style rules are three copies of one text

Measured with `diff` over the section between `## Writing style` and `## Git state`:

| pair | hunks that differ |
| --- | --- |
| kotlin-ksp-mocks vs swift-sourcery-templates | 3 |
| kotlin-ksp-mocks vs this repository | 3 |

Every hunk is an example swapped for a local one: the negative-space example is
`jvmToolchain(25)`/`compilerOptions.jvmTarget` in the Kotlin repository, the Xcode pin and `runs-on`
in the Swift one, and `references/troubleshooting.md` here; the metaphor example says "module",
"package" and "repository" respectively; this repository's scope sentence adds "skill bodies" to the
list. The rules themselves — the sentence test and the seven habits — are the same 38 lines in all
three.

This is the measurement the writing-style skill exists for: a fourth repository that wants these
rules today has to copy 38 lines out of a repository it may not have, and then no check anywhere
notices when one copy is edited and the others are not.

### 1.3 The spec flow, as the two publishing repositories ran it

`kotlin-ksp-mocks` has 13 commits, 8 of them carrying the prefix `[001-agent-skill]`. Read oldest to
newest, the eight are:

```
[001-agent-skill] Specify the agent skill, its gate and its eval suite
[001-agent-skill] Record what phase 0 measured about the wiring shapes
[001-agent-skill] Write the skill, its references and the two plugin manifests
[001-agent-skill] Gate the skill with scripts/check-skill.sh and the skill job
[001-agent-skill] Document the skill in README, CONTRIBUTING and the agent rules
[001-agent-skill] Add the six eval cases and record what the twelve runs measured
[001-agent-skill] Record the eval round in evals/README.md
[001-agent-skill] Open the skill with the module table, and record the twin comparison
```

The spec document is written first, in its own commit. Each phase after it is one commit. Two of the
eight commits add nothing but a record of what a phase measured or landed.

`swift-sourcery-templates` has 191 commits, 35 carrying a slug across three specs. Its
`002-annotation-registry-and-agent-skill` produced 23 of them, in the same shape.

The spec documents themselves: `kotlin-ksp-mocks/specs/001-agent-skill/spec.md` is 1303 lines, with
§0 TL;DR at `:28`, §1 "Current state (verified 2026-09-10)" at `:53`, and six amendment sections
(§11–§16) appended at `:608`, `:789`, `:855`, `:927`, `:1011` and `:1207` — one per phase, plus a
cross-repository comparison. `swift-sourcery-templates/specs/` holds 877, 1659 and 243 lines in
three specs and an 824-line follow-up file beside the first. All four open with §0 TL;DR and §1
Current state, both numbered, both dated.

### 1.4 What an initialized repository carries, measured across three

| file | kotlin-ksp-mocks | swift-sourcery-templates | duet-tutorials | here |
| --- | --- | --- | --- | --- |
| `AGENTS.md` | yes | yes | **no** | yes |
| `CLAUDE.md` | yes | yes | **no** | yes |
| `cmp` job in CI | yes (`ci.yml:14-23`) | yes (`ci.yml:45-53`) | **no** | yes (`ci.yml:13-22`) |
| `CONTRIBUTING.md` | yes | yes | yes | yes |
| `SECURITY.md` | **no** | **no** | yes | yes |
| `CHANGELOG.md` | yes | yes | **no** | no — nothing is released |
| license file | `LICENSE` | `LICENSE.txt` | `LICENSE` | `LICENSE` |
| `.gitignore` | yes | yes | yes | yes |
| `README.md` | yes | yes | yes | yes |

No repository before this one carries the whole set. `duet-tutorials` has no agent rules file at
all, and is the repository where an agent has the least to go on.

Two facts about the license, both from `swift-sourcery-templates`: it is Apache-2.0, and it is
written in three places that agree — `LICENSE.txt:1`, `.claude-plugin/plugin.json`'s `license`, and
`skills/swift-sourcery-mocks/SKILL.md`'s frontmatter `license:`. `kotlin-ksp-mocks` is MIT in the
same three places. A skill's frontmatter carries a license because the directory travels out of the
repository through four install channels.

None of the three repositories has a `.claude/` directory: there is no local slash command or
project skill encoding any of this today.

### 1.5 The git rules three repositories agree on, and the three they do not

Agreed, word for word, in `kotlin-ksp-mocks/AGENTS.md:65-87` and
`swift-sourcery-templates/AGENTS.md:67-89` and here at `:78-100`: never commit, amend, push or
rewrite history without confirmation in the current turn; never touch the index or restore the tree;
an imperative subject line naming the change; a `[NNN-slug]` prefix when a spec is in play, starting
with the commit that writes the spec.

Not agreed:

| decision | kotlin-ksp-mocks | swift-sourcery-templates | duet-tutorials |
| --- | --- | --- | --- |
| default branch | `main` | `master` | `main` |
| merge strategy | any, chosen per PR | any, chosen per PR | rebase only (`CONTRIBUTING.md:52`) |
| branch naming | unstated | unstated | `s<N>/<topic>` (`CONTRIBUTING.md:49-50`) |

The skill states the four agreed rules as rules, and the three others as decisions the adopting
repository records in its own `AGENTS.md` — with the cost of each option, not a house answer.

### 1.6 The gate that already exists

`scripts/check-skills.sh` runs nine checks (S1–S9) and `--self-test` reds each against a seeded
violation, building its own fixture skill so it works on a tree with no skills in it. Sizes each of
the four is held to: `SKILL_BODY_MAX=400` (`:43`), `REFERENCE_MAX=250` (`:44`),
`DESCRIPTION_MAX=1024` (`:45`), and the six frontmatter keys at `:38`.

For scale, the two published skills sit well inside those budgets:

| skill | `SKILL.md` | references |
| --- | --- | --- |
| `kotlin-ksp-mocks` | 190 | 217, 236, 201 |
| `swift-sourcery-mocks` | 273 | 136, 224, 163, 135, 119 |

### 1.7 Not measured

- What an agent produces for these four tasks **without** the skills. No baseline session was run,
  so no claim in this spec about what a skill improves is measured. §12.4 carries the question.
- Whether a skill directory name collides in practice in `~/.claude/skills/`. No survey of published
  skill names was made (§10, D1).
- Whether Claude Code namespaces a plugin's skills by plugin name at invocation. D1 does not depend
  on the answer, because three of the four install channels copy the directory flat.

---

## 2. The four skills

### 2.1 Names

| directory | `name:` | subject |
| --- | --- | --- |
| `writing-style` | `writing-style` | prose that states facts and actions |
| `spec-driven-development` | `spec-driven-development` | the manual spec flow |
| `repository-init` | `repository-init` | what a repository carries on day one |
| `git-discipline` | `git-discipline` | confirmation, the index, subject lines, branches |

S2 requires `name:` to equal the directory, so each pair moves together. The names are unprefixed;
D1 records the cost and the alternative.

### 2.2 The audience

An agent working in a repository that is not this one, on a task the description names. It has the
adopting repository's `AGENTS.md` (or does not — that is what `repository-init` is for), a task from
its user, and the skill body. It does not have this repository, so no skill refers to
`scripts/check-skills.sh`, the nine checks, this spec, or the three repositories §1 measured.

### 2.3 The four compose by naming, not by restating

A rule belongs to exactly one of the four. Where another needs it, it names the skill and states
what that skill decides — it does not copy the rule's text:

| rule | owned by | named by |
| --- | --- | --- |
| the sentence test and the seven habits | `writing-style` | `spec-driven-development` (a spec is prose), `repository-init` (the agent rules file it writes carries them) |
| confirmation, the index, subject lines, branch and PR flow | `git-discipline` | `spec-driven-development` (which commits carry a slug), `repository-init` |
| spec numbering, sections, the append-only rule | `spec-driven-development` | `repository-init` (the `specs/` directory it creates) |
| the file set, the agent rules file and the `cmp` job | `repository-init` | `writing-style`, `git-discipline` and `spec-driven-development`, each of which edits that file |

The subject-line format, including the optional `[NNN-slug]` prefix, is `git-discipline`'s.
`spec-driven-development` states which commits in a spec's series carry the prefix and in what order,
and does not restate the format.

A reference to another skill is its name plus a one-line statement of what it decides. It is never
a copy of that skill's text, and never an instruction to go and read it before continuing. Two
things follow: an adopter may install one skill and not the others, so each is complete on its own
subject and names the others as "if you also have X" rather than as a prerequisite; and the four can
be written in any order, because no skill's text is blocked on another skill's text existing.

### 2.4 Shared vocabulary

Three terms appear in more than one of the four. Each is owned by one skill, and every other skill
writes it in the form below — not in a form of its own, and never with a literal filled in:

| term | what it names | owned by | the form the others write |
| --- | --- | --- | --- |
| the agent rules file | `AGENTS.md` as the canonical file, plus every byte-identical per-agent copy the repository carries; `CLAUDE.md` is the copy §1.4 measured, and every repository there that has a rules file at all carries both | `repository-init` | "the agent rules file — `AGENTS.md`, and every byte-identical per-agent copy the repository carries, `CLAUDE.md` among them" |
| the default branch | whatever the repository's is: `main` in two of the three measured, `master` in the third (§1.5) | `git-discipline` | "the default branch", never a literal name |
| the spec directory | `specs/NNN-slug/spec.md` | `spec-driven-development` | "the spec directory" |

**The rules-file edit, stated once and performed by three skills.** `writing-style` (§3.1),
`git-discipline` (§6.1) and `spec-driven-development` (§4.1 step 8) each instruct a change to the
agent rules file, and an adopting repository may carry `AGENTS.md`, `CLAUDE.md`, both, or neither.
All three write the same four steps:

1. List which of the two the repository has.
2. Make the edit in `AGENTS.md` when it exists, otherwise in the one that does.
3. Copy it over every per-agent copy the repository carries — `cp AGENTS.md CLAUDE.md` for the
   pair §1.4 measured — so they stay byte-identical. Which files those are is D9's list.
4. If the repository has neither, say so and name `repository-init` as the skill that creates them.
   Do not create half the set as a side effect of a rules edit.

`repository-init` states why the files are byte-identical, writes both, and adds the CI job that
runs `cmp AGENTS.md CLAUDE.md`. The other three state the four steps and nothing more, which is
§2.3's rule applied: the procedure is the part they need, and the reasoning stays with the owner.

That CI job is also the mechanical catch — a skill that edits one file and not the other reds the
adopter's next pull request. A repository that has not run `repository-init` has no such job, which
is why step 3 is written into all three skills rather than assumed.

---

## 3. `writing-style`

### 3.1 What it teaches, and the enforcement problem

The rules are `AGENTS.md:40-77`, rewritten for an adopter: the scope sentence, the one-sentence test
(a fact the reader can verify, or an action they can take, with the referent named), and the seven
habits — mannered prose, aphoristic juxtaposition, dramatic reversal, negative-space phrasing,
metaphor as load-bearing content, rhetorical contrast, and the closing paragraph that generalizes
the lesson.

A skill body is resident only after the skill is invoked, and prose is produced in every turn of
every session. So the skill cannot be the thing that holds an agent to these rules, and must not
claim to be. Its first instruction is the one that makes it work: **copy the rules into the agent
rules file**, which every session reads from turn one. That copy is §2.4's four-step edit — into
`AGENTS.md`, then over every byte-identical copy the repository carries — and the skill writes those
four steps rather than naming one file. What the skill is, after the copy: the source text, and the
checklist for reviewing prose already written, its own or a reviewer's.

### 3.2 Files

- `SKILL.md`, estimated 150–200 lines: the scope, the test, the seven habits with one before/after
  pair each, §2.4's four-step edit into the agent rules file, and the review procedure.
- `references/rewrites.md`, estimated 120–200 lines: longer worked rewrites — a paragraph as first
  produced and as it should read, with the deletion named. Sources for these are real: the diffs in
  §1.2 and the commit messages in §1.3 are prose written under these rules.

### 3.3 What should invoke it

`description` names the trigger, not the topic: writing or reviewing a README, a spec, a commit
message, a PR body, a design document, a code comment or a review comment; being asked to remove
LLM-isms, to make prose concrete, or to cut a document down. It is the description most at risk of
being written as a topic ("writing style guidance"), which invokes on nothing.

---

## 4. `spec-driven-development`

### 4.1 What it teaches

The flow measured in §1.3, stated as steps an agent performs:

1. **When a spec is warranted:** a change too big to carry in a commit message. Not every change.
2. **Where it goes:** `specs/NNN-slug/spec.md`, `NNN` sequential from `001`, the slug naming the
   feature.
3. **What it contains:** the status/baseline/obsoletes header, "relates to" with file and line
   references, §0 TL;DR, §1 Current state — measured, dated, with file and line references — then
   the design sections, phasing, decisions, non-goals and open questions.
4. **Measure before specifying.** §1 of a spec states what is true now and how it was read. A spec
   whose §1 is recalled rather than measured plans against a repository that does not exist.
5. **Writing a spec is not authorization to implement it.** Produce the document, stop, ask.
6. **Review, then implement by phase.** One phase, one commit, each prefixed with the slug, the
   first being the commit that writes the spec.
7. **Amend by addition, never by revision.** What a phase actually landed, and where it departed
   from the plan, is appended as a new section that names by section what it supersedes; the
   superseded section takes a line pointing forward.
8. **Put steps 5 and 7 in the agent rules file**, through §2.4's four-step edit. "Writing a spec is
   not authorization to implement it" and the append-only rule only work if they are read before
   the work starts, and a skill body is not — the same argument as D3.

### 4.2 Files

- `SKILL.md`, estimated 180–230 lines: the seven steps, when not to write a spec, and the
  commit series.
- `references/spec-skeleton.md`, estimated 120–180 lines: the section skeleton with what each
  section holds and one real example line per section, taken from the four specs §1.3 measured.

### 4.3 The honest limit

This flow is manual. Nothing in it is enforced by a tool: no template generator, no numbering check,
no gate that fails a spec whose §1 was not measured. The skill says so rather than implying a
machinery that does not exist. The only mechanical part is the commit-subject prefix, which a
reviewer reads.

---

## 5. `repository-init`

### 5.1 What it teaches

The file set from §1.4, as instructions to write in a repository that does not have them:

- The agent rules file: `AGENTS.md`, and `CLAUDE.md` as its byte-identical copy, edited in one
  place and copied to the other. This skill is where that rule is stated and why — §2.4 — and the
  other three consume the term without restating it.
- The CI job that runs `cmp AGENTS.md CLAUDE.md` — the whole of it is a checkout and one command,
  which is why the job takes seconds and why a repository with no other CI still gets one. It is
  also what catches a skill, or a person, that edits one of the pair and not the other.
- `CONTRIBUTING.md`, `SECURITY.md`, `README.md`, a license file, `.gitignore`.
- `specs/` when the repository will use `spec-driven-development`.

And the division of labour that keeps them from becoming four copies of one document: rules in
`AGENTS.md`, procedure in `CONTRIBUTING.md`, what the thing *is* in `README.md`, what a release
changes in `CHANGELOG.md` if the repository releases anything.

### 5.2 What goes in the agent rules file it writes

A skeleton with named sections and the instruction for filling each, not a filled-in file: the
"read first, by question" table, the commands to run from the root, the writing-style rules (copied
from `writing-style` when installed), the git rules (from `git-discipline`), the spec rules (from
`spec-driven-development`), "state a rule once", and "what goes in which document".

### 5.3 Files

- `SKILL.md`, estimated 170–220 lines: the file set, what each file owns, the rules-equality job,
  the order to write them in, and how to run the script in §5.5.
- `references/agents-md-skeleton.md`, estimated 150–220 lines: the section skeleton.
- `references/ci-and-ignore.md`, estimated 80–140 lines: the rules-equality job as YAML, and what a
  `.gitignore` carries for a repository an agent works in — build products, OS files, local agent
  state.
- `scripts/init-repo.sh` and `scripts/init-repo.ps1` — §5.5.

Three Markdown files rather than two because §5.2's skeleton alone would push `SKILL.md` past the
400-line budget S5 enforces. S5 reads `*.md` only, so the two scripts are outside every budget the
gate holds today; §8.5 is what covers them instead.

### 5.5 The init script

The skill body stays the instruction an agent follows. The script is what removes the typing, and
it is the first executable thing this repository ships: until now `skills/` has been Markdown, and
`scripts/check-skills.sh` has been able to say it reads Markdown and JSON only.

**Where it lives, and how the body calls it.** `skills/repository-init/scripts/init-repo.sh` and
`init-repo.ps1`. Claude Code resolves a skill's own directory as `${CLAUDE_SKILL_DIR}`, so the body
writes the call as:

```bash
${CLAUDE_SKILL_DIR}/scripts/init-repo.sh --here --agent claude
```

and the frontmatter pre-approves it with `allowed-tools: Bash(${CLAUDE_SKILL_DIR}/scripts/* *)`.
`allowed-tools` is one of the six standard keys S3 permits, so this costs nothing at the other
channels. `shell: powershell` is **not** one of the six: a skill cannot select its own shell and
stay uploadable, which is why the choice between the two variants is the agent's, made from the host
it is on, and why the body states both paths rather than one.

The other three channels copy the directory whole, so the scripts arrive. What they do not all
provide is a variable naming that directory, so the body also states the fallback in one line: the
scripts are in `scripts/` beside the `SKILL.md` being read.

**Not `curl … | bash`.** [SECURITY.md](../../SECURITY.md) names "a skill that tells an agent to
fetch and execute code from a URL" as a reportable vulnerability in this repository. Every install
channel already puts the script on disk, so fetching it again adds a network dependency, a
supply-chain step and a version skew between the body and the code it calls, and buys nothing. D10.

**Flags**, modelled on `specify init` from [github/spec-kit](https://github.com/github/spec-kit),
which takes `--integration <agent>` to pick the assistant, `--script sh|ps|py` to pick a script
variant, and `--here`, `--force` and `--non-interactive`:

| flag | values | default | what it decides |
| --- | --- | --- | --- |
| `--path <dir>` | a path | `.` | where to write |
| `--agent <name>` | repeatable | `claude` | which per-agent copies of the rules file to write (§12.6, D9) |
| `--script sh\|ps` | | the host's | which variant of the *generated* check the target repository gets |
| `--license <id>` | `mit`, `apache-2.0`, `none` | `mit` | which license text, and the `license:` the skill frontmatter carries |
| `--contributing` / `--no-contributing` | | on | |
| `--security` / `--no-security` | | on | |
| `--changelog` / `--no-changelog` | | **off** | D8 |
| `--specs` / `--no-specs` | | on | `specs/`, and the spec rules section in the rules file |
| `--ci github\|none` | | `github` | who gets the rules-equality job |
| `--default-branch <name>` | | read from the repository, else ask | recorded in the rules file, never assumed (§2.4) |
| `--dry-run` | | off | print the file list, write nothing |
| `--force` | | off | overwrite existing files |
| `--non-interactive` | | off | never prompt — fail with what is missing instead |

**What it writes.** `AGENTS.md`, plus one byte-identical copy per `--agent`; `README.md`,
`CONTRIBUTING.md`, `SECURITY.md`, the license file, `.gitignore`, `specs/`; the rules-equality check
as `scripts/check-agent-rules.sh` or `.ps1` per `--script`, and the CI job that calls it.

That check is a generated script rather than the inline `cmp AGENTS.md CLAUDE.md` §5.1 describes,
for two reasons: with more than one per-agent copy the job is a loop, and `cmp` is not on a
PowerShell host. §5.1's one-line job is the `--agent claude --script sh` case of it.

**What it refuses.** Any existing file, unless `--force`: it lists every collision and exits
non-zero having written nothing. The common case is not a greenfield directory — it is a repository
that already has a `README.md` and wants the rest.

**What it does not do.** `git init`, `git add`, `git commit`, `git push`, or create a branch. It
writes files and prints the commit subject the adopter may use. `git-discipline`'s confirmation rule
is the reason, and it binds a script the agent runs exactly as it binds the agent.

**Two variants, one behaviour.** `init-repo.sh` and `init-repo.ps1` are not a hand-maintained
translation that drifts: S12 (§8.5) runs both into empty directories and diffs the trees.

### 5.4 What it must not assume

A hosting provider beyond "a CI system that can run a shell command", a language, a build tool, or
that the repository is public. The `cmp` job is written as GitHub Actions YAML because that is what
was measured; the skill states the job's content in one sentence so a reader on another CI can write
it.

---

## 6. `git-discipline`

### 6.1 What it teaches

The four agreed rules from §1.5, each with the reason it exists, which is what makes it followable:

- **Confirm every commit in the current turn.** Approval of a previous commit is not approval of
  the next.
- **Never touch the index or restore the tree.** Staged versus unstaged is the reviewer's record of
  how far they have read; `git checkout -- <path>` to "recover" discards work the reviewer has not
  seen.
- **The subject line is imperative and names the change**, with the `[NNN-slug]` prefix when a spec
  is in play.
- **A change reaches the default branch through a pull request**, and pushing, opening and merging
  each need their own go-ahead.

Then the three decisions §1.5 measured as unsettled — default branch name, merge strategy, branch
naming — stated as decisions with the cost of each option, to be recorded in the agent rules file
through §2.4's four-step edit. The skill writes "the default branch" throughout and never a literal
name: two of the three repositories §1.5 measured use `main` and the third uses `master`.

### 6.2 Files

`SKILL.md` alone, estimated 120–160 lines. No reference file: the subject is four rules and three
decisions, and splitting it would put the reader one file-open away from half of a short document.

---

## 7. What none of the four may contain

- A reference to this repository: `scripts/check-skills.sh`, the S-numbered checks, this spec, the
  install channels, `.claude-plugin/`.
- A private repository name, an internal path, or an internal planning reference.
- A version literal for any tool. Where a version matters, write the command that resolves the
  current one.
- Another of the four's rules, restated (§2.3).
- A literal default-branch name where "the default branch" is meant, or `AGENTS.md` alone where the
  agent rules file is meant (§2.4). S11 catches the second; the first is the review's.
- A claim about what an agent does better with the skill loaded. Nothing here is measured (§1.7).

---

## 8. The gate

### 8.1 What already holds

S1–S9 in `scripts/check-skills.sh` cover every structural rule the four have to satisfy: frontmatter
that parses for each install channel, `name:` equal to the directory, the six standard keys, a
description within 1024 characters, the 400/250 line budgets, links that resolve, a `SKILL.md` in
every directory, manifests that agree, and a README row per skill. No change to the script is needed
to land a skill.

### 8.2 S10 — a skill that names another names one that exists

§2.3 has the four referring to each other by name. A rename or a deletion then leaves a body
pointing at a skill nobody installs, and S6 does not catch it: S6 checks Markdown links, and a
cross-skill reference is a name in prose, not a link.

S10: for each `skills/*/SKILL.md` and reference file, every occurrence of a backticked name matching
another skill's directory-name shape must be a directory that exists under `skills/`. The
implementation reads the set of directory names first and looks for a fixed list, so it does not
guess at what is a skill name and what is an ordinary backticked word.

Landed in phase 5, after all four exist, with a seeded violation in `--self-test`.

### 8.3 S11 — a skill that names one of the pair names both

§2.4 has three skills instructing an edit to the agent rules file. The failure this spec was
revised to fix is a skill that names `AGENTS.md` alone: an adopter following it edits one file, and
the `cmp` job `repository-init` installed reds their next pull request — or, in a repository without
that job, the two copies drift and nothing says so.

S11: in every file under `skills/`, a mention of `AGENTS.md` and a mention of `CLAUDE.md` come
together — either both appear or neither does. It is two `grep -l` runs and a set comparison, and it
is exact: it cannot tell a correct four-step edit from a sentence that names both files and
instructs neither. What it does catch is the whole of the class found here, which is a skill naming
one file and forgetting the other.

Landed in phase 5 with S10, with its own seeded violation — delete the `CLAUDE.md` mention from the
fixture — in `--self-test`.

### 8.4 S12 — the two script variants write the same tree

§5.5 ships `init-repo.sh` and `init-repo.ps1`, and a hand-maintained pair diverges. S12 runs both
into empty temporary directories with the same flags and diffs the results: same file list, same
bytes. It runs the matrix that matters rather than every flag combination — `--agent claude`,
`--agent agents`, `--no-contributing`, `--changelog`, `--script sh`, `--script ps`.

This is the first check that executes what it is checking, so it needs `bash` and `pwsh` on the
runner. Whether GitHub's `ubuntu-latest` image ships `pwsh` is §12.9; if it does not, S12 runs on a
second runner and the `skills` job keeps its "no toolchain" property.

### 8.5 S13 — both scripts parse

`bash -n` on the `.sh` and a parse-only load of the `.ps1`, on every push. It costs milliseconds and
catches the edit that was never run on the other host. S12 subsumes it when both interpreters are
present; S13 is what still reports when only one is.

### 8.6 What no check can hold

That a skill's text and the `AGENTS.md` section it came from still say the same thing. The two are
written for different audiences and will not match textually, so there is nothing to `cmp` and no
set of names to compare — unlike `kotlin-ksp-mocks`, where checks K6 and K7 compare the skill's
member names against the renderer that emits them. Here the pull-request review is the only gate,
and §2.3's one-owner rule is what keeps the review small.

---

## 9. Phasing

One commit per phase, each prefixed `[001-practice-skills]`. The order follows §2.4: the skill that
owns a shared term is written before the skills that write that term.

| phase | what lands | why here |
| --- | --- | --- |
| 1 | `skills/repository-init/` — the body and the two reference files | It owns the agent rules file, the term the other three edit. Writing it first means no later skill invents its own spelling for that file. |
| 2 | `skills/repository-init/scripts/` — both variants, S12 and S13 | The body written in phase 1 is the specification the two scripts are measured against. Splitting it out keeps the Markdown review and the code review in separate commits. |
| 3 | `skills/writing-style/` | The first consumer of §2.4's four-step edit, and the rules the remaining two are written under. |
| 4 | `skills/git-discipline/` | The shortest; consumes the agent rules file and owns "the default branch". |
| 5 | `skills/spec-driven-development/` | Consumes both terms above and owns the spec directory. |
| 6 | README rows, CONTRIBUTING mention, S10, S11 and their self-test cases | The index and the two cross-skill checks, once there are four names to check. |

§5.2 has `repository-init` naming the other three inside the skeleton it writes, which looks like a
cycle against this order and is not: that reference is a name and a one-line statement of what each
decides (§2.3), so phase 1 needs no text from phases 2–4.

Each phase appends a section to this spec recording what it landed and where it departed from the
plan, per §4.1 step 7 — and per `AGENTS.md:114-130`, which is the rule this spec is itself written
under.

After phase 6, `AGENTS.md:40-77` and `:78-100` here — and their `CLAUDE.md` copies — are text a
skill now owns. What to do about that is D5.

---

## 10. Decisions

**D1 — Unprefixed directory names.** `writing-style`, not `modaal-writing-style`. Three of the four
install channels copy the directory into a flat `~/.claude/skills/`, where a generic name can
collide with another publisher's. The prefix would prevent that, at the cost of putting a company
name the adopter does not work for into every invocation of a skill about English prose. Chosen:
unprefixed, with the collision recorded in the README as the adopter's to resolve by renaming the
directory — one edit, in the directory name and in `name:`, which S2 holds together. Reversible
before the first install; expensive after. §12.1 asks for confirmation.

**D2 — One spec for four skills, not four specs.** The four share the composition rule in §2.3, the
budgets, the gate and the phasing; four specs would restate all of it and then diverge. The cost:
this spec's §1 measurement is dated once, and phase 4 will be implemented against a §1 written
weeks earlier. Amendments per phase (§9) are what keeps that honest.

**D3 — The writing-style skill instructs a copy into the agent rules file.** The alternative is to
claim the skill governs prose whenever it is loaded, which is false for every turn before it is
invoked (§3.1). The cost of the copy is drift between the skill and each adopter's copy, which no
check can see. Accepted: a copy that is read every turn beats a source of truth that is read after
the prose is written.

**D4 — `git-discipline` states the three unsettled decisions rather than picking one.** §1.5
measures three repositories under one set of rules disagreeing on default branch, merge strategy and
branch naming. A skill that picks one is wrong in two of the three repositories that already exist.

**D5 — This repository's agent rules file keeps its own copy of the rules, and does not shrink to a
pointer.** After phase 3, `AGENTS.md:40-77` and `:78-100`, and the `CLAUDE.md` copies of both,
duplicate two skills. Replacing them with "see the `writing-style` skill" would leave an agent whose
session has not invoked that skill with no rules at all — the same failure §3.1 describes. The
duplication is the cost of the rules being resident. Recorded here so a later reader does not "fix"
it.

**D6 — The agent rules file is one term, owned by `repository-init`, and the other three write it
whole.** The alternative, and the shape this spec had before review, is each skill naming
`AGENTS.md` where it needs to. Measured against §1.4, that is wrong three ways: `duet-tutorials`
carries neither file, so an instruction to "edit `AGENTS.md`" names nothing there; the two
publishing repositories carry both, so an edit to one alone reds their `cmp` job; and no skill but
`repository-init` would have told the adopter which case they are in. The cost of the term is that
§2.4's four steps are written out in three skill bodies — roughly six lines each. That is the
smallest thing that can be repeated: the procedure, not the reasoning.

**D7 — Phase order follows vocabulary ownership, not size or importance.** §9's table. The rejected
order was writing-style first, on the grounds that its rules govern the other three documents. They
do, but as rules this agent already reads from `AGENTS.md` — not as text any skill has to quote —
so it is not an ordering constraint.

**D8 — A `CHANGELOG.md` is written only for a repository that publishes something a consumer pins.**
Resolves §12.2 as proposed. §1.4 measured two of four repositories carrying one, and both publish an
artifact someone else depends on by version; this repository publishes skills that adopters read
from `main`, and carries none. The script's flag is `--changelog`, default off, and the skill states
the rule rather than the flag — an adopter who publishes nothing should not be told to keep a file
nobody reads.

**D9 — `--agent` accepts only agent files this project has measured, and grows by measurement.**
Resolves §12.6 in the conservative direction it proposed. Today that is two values: `agents`
(`AGENTS.md` alone) and `claude` (`AGENTS.md` + `CLAUDE.md`), both read from §1.4. `GEMINI.md`,
`.github/copilot-instructions.md` and `.cursor/rules/` are real and unmeasured — a guessed filename
writes a file the agent never reads, which is worse than writing nothing. Adding a value means
reading that agent's documentation for the filename it loads and recording it in an amendment. §2.4
step 3 still says "every per-agent copy the repository carries", which correctly copies over a
`GEMINI.md` that is already there without this project claiming to know how it got there.

**D10 — The script ships in the skill directory and is never fetched over the network.**
[SECURITY.md](../../SECURITY.md) names fetch-and-execute as a reportable vulnerability here, and
`curl … | bash` would make this repository the first thing its own security policy reports. Every
install channel copies the directory, so the script is already on disk; Claude Code names that
directory `${CLAUDE_SKILL_DIR}`, and for a channel that does not, the body says the scripts sit
beside the `SKILL.md`. The cost is that a skill installed once is not updated when this repository
changes — the same cost every skill body already has.

**D11 — Two variants, bash and PowerShell, held identical by a check rather than by care.** The
requirement is both hosts. The failure mode of a hand-maintained pair is that the second variant
silently falls behind, so S12 (§8.4) runs both and diffs the trees. No `py` variant: `specify init`
offers `sh|ps|py`, but Python is a third runtime to require of an adopter who wanted a README and a
rules file, and §12.8 keeps the question open rather than closing it by omission.


---

## 11. Non-goals

- An eval suite. Both published skills have one; this repository has no runner wired, the cases cost
  model calls, and no CI job would run them. Spec 002 (§12.4).
- A skill about code review, testing practice, or mock generation. The two mock-generation skills
  are published from the repositories whose generators they document, for the reason
  `README.md:29-31` states.
- A generator that scaffolds a **spec**. `spec-driven-development` stays manual (§4.3): a spec's
  value is the measuring and the deciding, and a template that produces the section headings without
  them produces a document that looks finished and says nothing. `repository-init`'s files are the
  opposite case — a known set with a known shape — which is why §5.5 scripts those and this bullet
  no longer rules it out. Before review this non-goal covered both; it now covers the spec only.
- Changing `scripts/check-skills.sh`'s budgets. The two published skills fit inside them with room
  (§1.6).

---

## 12. Open questions

**12.1 — Are the four names right, and unprefixed?** D1 chose unprefixed and the four names in
§2.1. Both are cheap to change now and expensive after the first adopter installs. Needs an answer
before phase 1.

**12.2 — Does `repository-init` write a `CHANGELOG.md`?** Asked because §1.4 measures two of four
repositories carrying one, and both of those publish an artifact. **Resolved 2026-09-11 as proposed
— D8:** the skill states the rule, a repository that publishes something a consumer pins carries a
`CHANGELOG.md` and one that does not carries none, and the script's `--changelog` defaults to off.

**12.3 — How much of the `AGENTS.md` skeleton does `repository-init` supply verbatim?** A skeleton
with fill-in instructions is small and vague; a filled example is long and gets copied unread. §5.3
budgets 150–220 lines for the reference file either way. Needs an answer before phase 4.

**12.4 — Is a baseline measurement worth a phase?** §1.7 records that nothing here is measured
against a session without the skills. The two published skills each ran such a comparison. Running
one here would cost a handful of model calls per skill and would give the README something true to
say. Proposed: spec 002, after phase 5.

**12.5 — Do S10 and S11 belong in this spec's phase 5 or in the spec that adds the fifth skill?**
Both are cheap either way, and phase 5 is where the four names first exist to check.

**12.6 — Does the agent rules file mean more than `AGENTS.md` and `CLAUDE.md`?** Asked because the
cross-agent `skills` CLI installs into repositories that may carry `GEMINI.md`, `.cursor/rules/` or
`.github/copilot-instructions.md`, none of them measured. **Resolved 2026-09-11 as proposed — D9:**
the script's `--agent` accepts the two measured values, `agents` and `claude`; §2.4 step 3 copies
over any other rules file already present without this project naming or creating one; and the list
grows only when an agent's documented filename has been read and recorded in an amendment.

**12.7 — Does an executable belong in this repository, and what does it cost the documents?**
§5.5 makes `skills/` more than Markdown for the first time. Three things follow that this spec does
not settle: SECURITY.md's list of what counts as a vulnerability here should gain a line about a
defect in a shipped script, CONTRIBUTING.md's "no toolchain, Markdown and JSON only" describes
`check-skills.sh` and would need to stop describing the whole gate, and README's layout table gains
a row. The alternative is a second repository holding the script, which costs the adopter a second
install and breaks `${CLAUDE_SKILL_DIR}`. Proposed: keep it here and make the three document edits
part of phase 2. Needs an answer before phase 2.

**12.8 — Is a `py` variant worth it?** `specify init` offers `sh|ps|py`. D11 ships two. A third
would cover a host with neither bash nor PowerShell, at the cost of a third implementation S12 has
to hold identical and a Python runtime the adopter may not have. Proposed: no, until an adopter asks.

**12.9 — Does GitHub's `ubuntu-latest` image ship `pwsh`?** S12 (§8.4) runs both variants in one
job if it does, and needs a second runner if it does not. Unmeasured — read it from the runner image
manifest before phase 2, not from memory.
