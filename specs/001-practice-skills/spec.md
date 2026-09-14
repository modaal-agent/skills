# 001 — Four practice skills: writing style, spec-driven development, repository initialization, git discipline

**Status:** Written 2026-09-11, revised in place 2026-09-14. Phases 1–5 landed 2026-09-14; phase 6
not implemented (§9.1). **Baseline:** `main` at `1753a20`. **Obsoletes:** nothing.

**Relates to:**

- [AGENTS.md](../../AGENTS.md) — the sections "Writing style", "Git and pull requests" (before
  phase 4, "Git state" and "Changes reach `main` through a pull request"), "Specs" (before phase 5,
  "Specs are a decision record") and "A skill is written for an agent in someone else's repository". The first three are
  the source material for three of the skills; §2.3
  of this spec is the rule that keeps a skill and the section it came from from becoming two answers
  to one question.
- [README.md](../../README.md) §"Skills" — one row per skill this spec plans.
- [CONTRIBUTING.md](../../CONTRIBUTING.md) §"Adding a skill" and §"Running the checks" — the
  procedure and the checks each of the four passes.
- [scripts/check-skills.sh](../../scripts/check-skills.sh) — `STANDARD_KEYS`, `SKILL_BODY_MAX`,
  `REFERENCE_MAX` and `DESCRIPTION_MAX`, the budgets §3–§6 size against.
- [kotlin-ksp-mocks](https://github.com/modaal-agent/kotlin-ksp-mocks) spec `001-agent-skill` and
  [swift-sourcery-templates](https://github.com/modaal-agent/swift-sourcery-templates) spec
  `002-annotation-registry-and-agent-skill` — the two skills already published, and the two spec
  documents §1.3 measures the flow from.
- The thirteen style-guide sources in §1.8 — the inputs to `writing-style`'s rules.
- §14 — every external reference this spec makes, with its URL and pin, or its redaction text.

Every fact in §1.1–§1.7 was read from the three checkouts on 2026-09-11: this repository at
`1753a20`, `modaal-agent/kotlin-ksp-mocks` and `modaal-agent/swift-sourcery-templates` at their
working `main` and `master`, and `modaal-agent/duet-tutorials` at its working `main`. §1.8 was read
on 2026-09-14 from the public pages it names. Outside §1, this spec names parts of this repository's
files by heading rather than by line, because phases 1–6 edit them.

---

## 0. TL;DR

1. **The four skills' source material already exists, three times over.** The writing-style section
   is 38 lines and is byte-identical across `kotlin-ksp-mocks/AGENTS.md:27-64`,
   `swift-sourcery-templates/AGENTS.md:29-66` and `AGENTS.md:40-77` here at `1753a20`, except for three hunks
   that swap a repository-specific example (§1.2). The skill is the fourth copy, and the one a
   fifth repository installs instead of copying.
2. **Four directories under `skills/`:** `writing-style`, `spec-driven-development`,
   `repository-init`, `git-discipline` (§2.1). Names are unprefixed, which is a decision with a
   known cost (§10, D1).
3. **What each teaches** is in §3–§6: twelve writing rules, each resting on a dated style-guide
   source (§1.8), and the tells to search a draft for; the manual spec flow measured from a run that
   produced eight commits (§1.3); the eight files and one CI job a repository carries on day one
   (§1.4); the confirmation, index and subject-line rules, and the three things three repositories
   do differently (§1.5).
4. **The four compose by naming each other, never by restating each other** (§2.3), and share three
   terms each owned by one skill (§2.4). The agent rules file is one of them: `AGENTS.md` plus every
   byte-identical copy the repository carries. Three of the four edit it, and all three write the
   same four steps, so none can leave `CLAUDE.md` behind (D6).
5. **Three of the four exist to write one section of the agent rules file.** A skill's body is
   resident only after the skill is invoked, and an agent writes prose, commits and edits specs in
   the turns before that. So `writing-style`, `git-discipline` and `spec-driven-development`,
   invoked, each write or update their section of the agent rules file, which is resident from turn
   one, and report the change. The section governs the agent's later turns; each skill keeps one
   task-time use, such as reviewing a draft or writing a spec (§2.5, D3). *Revised 2026-09-14:* this
   item applied the model to `writing-style` alone and to two rules of `spec-driven-development`.
6. **The gate is the nine checks that already run** (`scripts/check-skills.sh`), plus four: S10, a
   skill that names another skill names one that exists (§8.2); S11, a skill that names
   `AGENTS.md` also names `CLAUDE.md` (§8.3); S15, every section reference in a spec resolves
   (§8.7); and S16, every external-reference id a spec cites has a row, and every private row is
   redacted (§8.8).
7. **Six phases, six commits**, ordered by which skill owns a shared term — `repository-init`, its
   two scripts, `writing-style`, `git-discipline`, `spec-driven-development`, then the README,
   CONTRIBUTING and the cross-skill checks (§9). Phases 3–5 also replace the matching section of
   this repository's `AGENTS.md` with the skill's block.
8. **`repository-init` ships a script**, in bash and PowerShell, bundled in the skill and called as
   `${CLAUDE_SKILL_DIR}/scripts/init-repo.sh` — never fetched over the network, which this
   repository's own SECURITY.md would report (§5.5, D10). Its flags follow `specify init` from
   github/spec-kit: `--agent`, `--script sh|ps`, `--force`, `--dry-run`, `--non-interactive`. S12
   diffs the trees the two variants write, so neither can fall behind (§8.4, D11).
9. **No eval suite in this spec.** Both published skills have one; this repository has no runner
   wired and the cases cost model calls. Deferred to spec 002 (§11, §12.4).
10. **A spec is a decision record** (§4.4): edited in place while its feature is in progress, with a
    short note where an important earlier decision is overturned, and amended by addition once the
    feature is done. This repository's `AGENTS.md` adopted the rule on 2026-09-14, and this spec
    was revised in place under it.
11. **Public-facing text is hermetic** (§13). It names no private repository or private work;
    every internal cross-reference resolves; every external reference is to a public source,
    pinned where it cites a line, a count or a quotation. A spec lists its external references in
    one section (§14 here), and a private reference is named only there and redacted before it is
    pushed to a public origin. The rule landed in this repository's `AGENTS.md` on 2026-09-14,
    before phase 1, and reaches `spec-driven-development` in phase 5.

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
E16 §0 TL;DR at `:28`, E16 §1 "Current state (verified 2026-09-10)" at `:53`, and six amendment
sections, E16 §11–§16, appended at `:608`, `:789`, `:855`, `:927`, `:1011` and `:1207` — one per
phase, plus a cross-repository comparison. `swift-sourcery-templates/specs/` holds 877, 1659 and 243
lines in three specs and an 824-line follow-up file beside the first. All four open with a TL;DR
numbered 0 and a Current state numbered 1, both dated.

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

### 1.8 The style-guide sources, read 2026-09-14

Each page was downloaded on 2026-09-14 and converted to text, and the quotations were copied from
that text into working notes that are not published (E15). The table records which rule in §3.2 or
step in §3.3 rests on which source; §14 holds each source's URL and pin. The skill carries the rules
without attribution (§3.5).

| ref (§14) | source | date | licence | taken for |
| --- | --- | --- | --- | --- |
| E1 | David Ogilvy, "How to Write", internal memo, as reproduced from *The Unpublished David Ogilvy* (1986) | 1982 | in copyright | rules 2, 3, 9, 12; review step 3 |
| E2 | George Orwell, "Politics and the English Language" | 1946 | in copyright in the US | rules 8, 9; the closing line |
| E3 | William Strunk Jr., *The Elements of Style* | 1918; rule numbers from the 1920 printing | public domain | rules 1, 4 (Strunk 13), 5 (10), 6 (11), 7 (12) |
| E4 | The Kansas City Star, "The Star Copy Style" | undated; the Star believes about 1915 | sheet public domain | rules 3, 6, 9 |
| E5 | Winston Churchill, "Brevity", War Cabinet memorandum, as transcribed at Wikiquote | 9 Aug 1940 | Crown copyright | rule 4 |
| E6 | Jeff Bezos, email to Amazon's senior team; 2017 letter to shareholders | 9 Jun 2004; 18 Apr 2018 | short quotation | review step 1 |
| E7 | Paul Graham, "Write Like You Talk"; "Write Simply" | Oct 2015; Mar 2021 | short quotation | rule 2 |
| E8 | GOV.UK, "Writing to GOV.UK standards" and the A to Z entry "Words to avoid" | undated | Open Government Licence v3.0 | rules 3, 4, 5, 8, 9; the 37 replacements in `references/tells.md` |
| E9 | Google developer documentation style guide, "Voice and tone" and "Word list" | updated 2026-05-27; 2026-08-25 | CC BY 4.0 | rules 4, 8, 9; word-list entries in `references/tells.md` |
| E10 | Microsoft Writing Style Guide, "Top 10 tips for Microsoft style and voice" | 2026-07-02 | short quotation | rules 2, 5, 12; sentence-case headings in `references/tells.md` |
| E11 | Wikipedia, "Signs of AI writing" | revision 1374467046, 2026-09-12 | CC BY-SA 4.0 | rules 5, 6, 9, 10, 11; the twelve tells in `references/tells.md` |
| E12 | Kobak, González-Márquez, Horvát, Lause, arXiv 2406.07016 v5 | 3 Jul 2025 | abstract, short quotation | the measurement below |
| E13 | Liang et al., arXiv 2404.01268 | 1 Apr 2024 | abstract, short quotation | the measurement below |

Not fetched: The Economist style guide (E14), whose site returned a challenge page. No rule rests on
it.

What the sources establish:

- Kobak et al. measured the frequency of style words in over 15 million PubMed abstracts from
  2010–2024 and conclude that "at least 13.5% of 2024 abstracts were processed with LLMs", "reaching
  40% for some subcorpora". Liang et al. measured 950,965 papers from January 2020 to February 2024
  and put LLM-modified content in computer-science papers at "up to 17.5%". Both measure
  vocabulary, so `references/tells.md` is a list of words and phrases to search for. Neither
  measures an agent working with or without a rules section, so §1.7's first bullet stands.
- Wikipedia's page calls itself "descriptive, not prescriptive". Its em-dash entry carries a
  September 2026 editor note that the sign "seems to be less common in current LLM output", and the
  page files "Section summaries" and "Didactic disclaimers" under historical indicators.
  `references/tells.md` marks those three entries as the page marks them.

Not verified, so no skill text relies on them: rule numbers in Strunk's 1918 edition (the 1920
printing was read); a date for the Kansas City Star sheet; Churchill's wording against the archive
image, where three transcriptions differ in three places; Bezos's 2004 wording, where reproductions
differ in two places; a GOV.UK "reading age of 9" sentence, which the current pages do not carry;
Google word-list entries for "very", "delve" and "note that", which do not exist.

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
| the twelve writing rules (§3.2) | `writing-style` | `spec-driven-development` (a spec is prose), `repository-init` (its last step names the skill that writes them) |
| confirmation, the index, subject lines, branch and PR flow | `git-discipline` | `spec-driven-development` (which commits carry a slug), `repository-init` |
| spec numbering, sections, the decision-record rule, the external-references section (§13) | `spec-driven-development` | `repository-init` (the `specs/` directory it creates) |
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

1. List which of the two the repository has. With both, run `cmp AGENTS.md CLAUDE.md` before the
   edit: a `CLAUDE.md` that matches is a copy.
2. Make the edit in `AGENTS.md` when it exists, otherwise in the one that does.
3. Copy it over each file that was a copy in step 1 — `cp AGENTS.md CLAUDE.md` for the pair §1.4
   measured — so they stay byte-identical. Leave a symlink or an `@AGENTS.md` import as it is, and
   report a file that differed before the edit as drift.
4. If the repository has neither, say so and name `repository-init` as the skill that creates them.
   Do not create half the set as a side effect of a rules edit.

*Revised 2026-09-14, phase 1:* step 3 copied over every per-agent copy. Claude Code's memory
documentation (E24) states that Claude Code "reads `CLAUDE.md`, not `AGENTS.md`", and recommends a
`CLAUDE.md` that imports `@AGENTS.md`, or a symlink. A `cp` overwrites the import with a full copy,
and on a symlink `cp` fails because source and target are one file. Step 1's `cmp` tells a copy from
either.

`repository-init` states why the files are byte-identical, writes both, and adds the CI job that
runs `cmp AGENTS.md CLAUDE.md`. The other three state the four steps and nothing more, which is
§2.3's rule applied: the procedure is the part they need, and the reasoning stays with the owner.

That CI job is also the mechanical catch — a skill that edits one file and not the other reds the
adopter's next pull request. A repository that has not run `repository-init` has no such job, which
is why step 3 is written into all three skills rather than assumed.

### 2.5 Three of the four exist to write a section of the agent rules file

A skill's body is resident only after the skill is invoked. An agent writes prose, commits and edits
specs in turns before that, and nothing in an adopter's session invokes a skill ahead of the first
such turn. The agent rules file is resident from turn one. So `writing-style`, `git-discipline` and
`spec-driven-development` each own one `##` section of the agent rules file, and their job, invoked,
is to write or update that section and report the change. The section governs the agent's later
turns. D3 records the choice.

*Revised 2026-09-14:* before this subsection, `writing-style` copied its rules into the file,
`spec-driven-development` copied two of its eight steps, and `git-discipline` copied only its three
unsettled decisions. An agent then read "confirm every commit" only after invoking `git-discipline`,
which nothing did before the agent's first commit. And §3.6's triggers matched most turns that
produce prose, which invoked `writing-style` per task.

**Headings.** Each skill fixes the heading of its section:

| skill | heading |
| --- | --- |
| `writing-style` | `## Writing style` |
| `git-discipline` | `## Git and pull requests` |
| `spec-driven-development` | `## Specs` |

**Where the section ends.** The section runs from its heading to a last line naming the skill that
writes it and stating that re-invoking the skill updates the section. Lines a repository adds after
that line, under the same heading, are the repository's own, and the skill does not edit them (D12).

**What the body carries.** The section's text as one fenced block, which the skill writes verbatim;
the procedure below; and the material for one task-time use, read only when the skill is invoked
for that task:

| skill | task-time use |
| --- | --- |
| `writing-style` | reviewing a draft against the rules, with `references/tells.md` and `references/habits.md` (§3.3) |
| `spec-driven-development` | writing or amending a spec, with `references/spec-skeleton.md` (§4.2) |
| `git-discipline` | none beyond the section; the three decisions are settled during the write (step 3 below) |

**The procedure each of the three writes.**

1. List which agent rules files the repository has (§2.4 step 1). With neither, stop and name
   `repository-init` (§2.4 step 4).
2. Look for the skill's heading in `AGENTS.md`, or in the one rules file present.
3. `git-discipline` only: settle the three decisions before writing. Read the default branch from
   the repository — the name after `origin/` in `git symbolic-ref --short refs/remotes/origin/HEAD`,
   or the current branch when there is no remote — and ask the user for the merge strategy and the
   branch-naming scheme, stating the cost of each option (D4). Leave a decision the user does not
   answer out of the section, and name it in the report.
4. Heading absent: insert the section after the last section another practice skill wrote, or at
   the end of the file when there is none.
5. Heading present: compare the text between the heading and the skill's last line with the block,
   show the user the difference, and replace it only on the user's confirmation (D15). §1.2 measured
   three copies of one section that differ exactly where each repository put in a local example; a
   replacement without confirmation deletes those examples.
6. Copy the edited file over every per-agent copy the repository carries (§2.4 step 3).
7. Stage nothing and commit nothing. Report the files changed and the section's line range, and
   propose a commit subject. `git-discipline`'s confirmation rule binds this edit as it binds any
   other.

**What invokes each.** Each `description` names writing the section as the first trigger and the
task-time use as the second:

- `writing-style`: adding or updating writing rules in `AGENTS.md` or `CLAUDE.md`; a user asking
  that agents in the repository stop producing LLM-isms, AI tells or padded prose; reviewing a draft
  for them (§3.6).
- `git-discipline`: adding git or pull-request rules to `AGENTS.md` or `CLAUDE.md`; choosing the
  repository's default branch, merge strategy or branch-naming scheme.
- `spec-driven-development`: adding spec rules to `AGENTS.md` or `CLAUDE.md`; writing, reviewing or
  amending a document in the spec directory.

`repository-init`'s last step (§5.2) is the second route by which each of the three is invoked.

**What the sections cost an adopter.** They are read in every turn of every session in the adopting
repository. Measured in this repository's `AGENTS.md` on 2026-09-14, before phase 3: the
writing-style section was 38 lines, the two git sections 36, the spec section 15 — 89 lines
together. The twelve rules §3.2 plans were drafted as a 34-line block. Estimates for the sections as
the skills write them: 35–45 lines for `writing-style`, 30–40 for `git-discipline`, 15–25 for
`spec-driven-development`. No check holds these numbers; §12.10 asks for one. As landed, the
`writing-style` block is 35 lines, the `git-discipline` block 23, or 22 in this repository, which
leaves one decision line out, and the `spec-driven-development` block 20: 77 lines in this
repository, where the three sections they replaced were 89.

---

## 3. `writing-style`

### 3.1 What it teaches, and the enforcement problem

The rules are `AGENTS.md` §"Writing style" as it stood before phase 3 (`:40-77` at `1753a20`),
rewritten for an adopter and extended from the sources in §1.8: the
scope sentence, the one-sentence test (a fact the reader can verify, or an action they can take, with
the referent named), and eleven rules after it that absorb the seven habits — mannered prose,
aphoristic juxtaposition, dramatic reversal, negative-space phrasing, metaphor as load-bearing
content, rhetorical contrast, and the closing paragraph that generalizes the lesson. §3.2 is the
section the skill writes; §3.3 is the review procedure.

A skill body is resident only after the skill is invoked, and prose is produced in every turn of
every session. So the skill cannot be the thing that holds an agent to these rules, and must not
claim to be. Its job is the one §2.5 gives all three practice skills: **write the rules into the
agent rules file**, which every session reads from turn one, through §2.4's four-step edit. What the
skill is, after the write: the source of the section's text, and the procedure for reviewing a draft
when a user asks for a review.

### 3.2 The section it writes

A scope sentence, twelve rules and a closing line. The scope sentence is the former section's, with
this repository's list of documents replaced by the adopter's: every character of prose, replies in
chat included. In the table, "former section" is `AGENTS.md` at `1753a20`.

| # | rule | rests on (§1.8) | changed for an agent |
| --- | --- | --- | --- |
| 1 | Every sentence gives the reader a fact they can verify or an action they can take, with the referent named — the file, the line, the number, the date. If it does neither, delete it. | the former section's test; E3 | — |
| 2 | Write the way you would say it to a colleague. Reread each sentence and rewrite any you would not say aloud. | E1, E7, E10 | Ogilvy and Graham read the draft aloud; the agent rereads it |
| 3 | Short words, short sentences, short paragraphs. Split a sentence over 25 words; keep a paragraph to five sentences. | E1, E4, E8 | — |
| 4 | Omit needless words: "in order to", "just", "simply", "please note", "it is important to note", "additionally" at a sentence start. | E3, E5, E8, E9 | — |
| 5 | Active voice. Start statements with the verb. Write "is" where "serves as" or "stands as" appears, and cut "there is" and "there are". | E3, E8, E10, E11 | — |
| 6 | Positive form: say what is. No "it's not X, it's Y", no "not just X but Y", no phrasing that names only what is absent. | E3, E4, E11 | — |
| 7 | Definite, specific, concrete: the number over the adjective, the path over "the config", the date over "recently". | E3 | — |
| 8 | No figure of speech you have seen in print, and no metaphor as the only statement of a point. Documents do not owe, want or know things; name who does the work. | E2, E8, E9 | — |
| 9 | No jargon, buzzwords or extravagant adjectives, with a named list: leverage, robust, streamline, empower, tackle, facilitate, vibrant, groundbreaking, pivotal. | E1, E2, E4, E8, E9, E11 | — |
| 10 | No significance inflation: nothing "underscores", "highlights" or "marks a turning point". Give the before value, the after value and the date measured. | E11; the former section's dramatic reversals | — |
| 11 | No rule of three for rhythm, no aphoristic juxtaposition, no dramatic reversal, no rhetorical contrast standing in for content, no closing paragraph that draws the moral. End when the content ends. | E11; the former section's aphoristic juxtapositions, reversals, rhetorical contrast and closing paragraph | — |
| 12 | Say what the reader is to do and where: the command, the file, the person to ask. | E1, E10 | Ogilvy's tenth hint, "Go and tell the guy what you want", is left out; the agent's report is its only channel to the user |

Closing line, from Orwell's sixth rule: break any of these rules sooner than write something unclear.

**As landed in phase 3.** The block is 35 lines in `skills/writing-style/SKILL.md` §"The section":
the heading, the scope sentence, the twelve rules as imperatives with a bold lead, the closing line,
and a last line reading "Maintained by the `writing-style` skill down to this line. This
repository's own lines go below." This repository's `AGENTS.md` carries it byte for byte, followed
by two lines of its own: the scope includes `skills/`, and where the before-and-after pairs are.

Where the seven habits go:

| habit (the former section's list) | rule | before/after pair |
| --- | --- | --- |
| mannered prose | 8 | `references/habits.md` |
| aphoristic juxtaposition | 11 | `references/habits.md` |
| dramatic reversal | 10, 11 | `references/habits.md` |
| negative-space phrasing | 6 | `references/habits.md` |
| metaphor as load-bearing content | 8 | `references/habits.md` |
| rhetorical contrast | 6, 11 | `references/habits.md` |
| the closing paragraph that generalizes | 11 | `references/habits.md` |

### 3.3 The review procedure

Used when the skill is invoked to review a draft, the agent's or the user's:

1. Reread the draft once against the twelve rules before handing it over. E6 has memos "set aside
   for a couple of days, and then edited again with a fresh mind"; an agent's version is the one
   reread it performs inside its turn.
2. Run every search in `references/tells.md` over the draft, and delete or replace each hit.
3. Check every quotation against its source (E1, hint 6).

Ogilvy's hints 7 and 8 — send nothing on the day it is written, and have a colleague improve it — are
left out: the agent's reply is due in the turn, and the user reviewing that reply is the colleague.

**As landed in phase 3.** Step 2 runs the searches in both `references/tells.md` and
`references/ai-tells.md`, and reads a hit as a sentence to reread, since some listed words are
literal in software: a git `commit`, an API `key`. A fourth step reports each change as the
sentence, the rule it broke and the rewrite, and applies changes to a file only when the user asks.

### 3.4 Files

- `SKILL.md`, estimated 110–160 lines: the section's fenced block (§3.2), §2.5's procedure, and the
  review procedure (§3.3).
- `references/habits.md`, estimated 150–220 lines: the seven habits, each with one before/after
  pair and one longer rewrite naming the deletion. Sources for these are real: the diffs in §1.2 and
  the commit messages in §1.3 are prose written under these rules.
- `references/tells.md`, estimated 120–180 lines: the twelve tells from E11, each with its search
  terms and the rule in §3.2 that removes it; E8's 37 words to avoid, each with its replacement;
  E9's entries for "leverage", "just", "easy", "please", "in order to" and "utilize"; headings in
  sentence case (E10). One attribution line per source, with its licence.

Each file fits the budgets S5 enforces (§1.6).

*Revised 2026-09-14:* planned as `SKILL.md` and one `references/rewrites.md`. The tells from §1.8
needed a second reference file, and `rewrites.md` is renamed `habits.md` for what it holds.

**As landed in phase 3:**

- `SKILL.md`, 106 lines: the block, the six-step write procedure (§2.5 without its step 3, which is
  `git-discipline`'s), and the four-step review.
- `references/habits.md`, 162 lines: the seven habits, each with three or four short pairs and one
  longer rewrite naming what was deleted. The examples are invented, apart from those kept from the
  former `AGENTS.md` section.
- `references/tells.md`, 96 lines: eight filler searches, E8's 37 words with an exceptions column
  for uses literal in software, and sentence-case headings, with the OGL v3.0 and CC BY 4.0
  attributions.
- `references/ai-tells.md`, 119 lines: thirteen tells from E11, each with an extended regular
  expression that runs under GNU and BSD `grep`, and the rule that removes it. Licensed CC BY-SA 4.0
  in its opening lines and in the skill's `license:`.

*Revised 2026-09-14, phase 3:* the E11 tells were planned inside `references/tells.md`. They moved
to their own file under CC BY-SA 4.0 (§12.11). They number thirteen, where §1.8 counted twelve,
because E11 files "Section summaries" and "Didactic disclaimers" as two historical indicators and
the file keeps both, marked historical.

### 3.5 What stays out of the skill

- **The quotations and the argument from the sources.** AGENTS.md §"A skill is written for an agent
  in someone else's repository" keeps the measurement behind a rule in the spec; §1.8 is that record
  here. Leaving them out also keeps text still in copyright — Ogilvy's memo, and Orwell's essay in
  the US — out of a directory every install channel copies whole.
- **Attributions inside the section.** A source name after each rule adds twelve parentheticals to
  text read in every turn and gives the agent no action to take. `SKILL.md` and the section carry
  none; `references/tells.md` carries the attribution its licences require.
- **Wikipedia's prose.** `references/ai-tells.md` states each tell in the skill's own words, with a
  search and an attribution. Whether those search terms bring CC BY-SA 4.0's share-alike terms with
  them is §12.11, resolved by licensing that one file under CC BY-SA 4.0.

### 3.6 What should invoke it

`description` names the trigger, not the topic: the two §2.5 lists for this skill, with the phrasings
a user gives them — remove LLM-isms or AI tells, make prose concrete, cut a document down. It is the
description most at risk of being written as a topic ("writing style guidance"), which invokes on
nothing.

*Revised 2026-09-14:* the triggers were writing or reviewing a README, a spec, a commit message, a PR
body, a design document, a code comment or a review comment. Those turns are governed by the section
in the agent rules file (§2.5), so the description leaves them out.

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
7. **The spec is a decision record.** While the feature is being worked on, edit the spec in place
   to keep the plan current — what a phase landed, where it departed from the plan — and leave a
   short note where an important earlier decision is overturned. Once the feature is done, amend by
   addition. §4.4 states the rule, when a feature is done, and what the rule trades. *Revised
   2026-09-14:* the step was "amend by addition, never by revision" from the first commit on.
8. **Write the `## Specs` section into the agent rules file** through §2.5's procedure: steps 1, 2,
   5, 7 and 9, the definition of done, follow-up files, and what a new spec obsoletes. "Writing a
   spec is not authorization to implement it" and the decision-record rule only work if they are
   read before the work starts, and a skill body is not — the same argument as D3. *Revised
   2026-09-14:* the step copied steps 5 and 7 alone.
9. **Keep public-facing text hermetic** (§13.2). Every internal cross-reference resolves; every
   external reference is listed in the spec's `External references` section and is to a public
   source, pinned where the spec cites a line, a count or a quotation from it. When the origin is
   public — `gh repo view --json visibility` on GitHub, otherwise ask the user — a private reference
   is named only in that section and redacted before the commit carrying it is pushed.

### 4.2 Files

- `SKILL.md`, estimated 180–230 lines: the `## Specs` block, the nine steps, when not to write a
  spec, and the commit series.
- `references/spec-skeleton.md`, estimated 120–180 lines: the section skeleton with what each
  section holds and one real example line per section, taken from the four specs §1.3 measured,
  and the `External references` section with one public row and one redacted row (§13.2).

**As landed in phase 5:**

- `SKILL.md`, 150 lines: the 20-line block, which states steps 1, 2, 5 and 7 of §4.1, the definition
  of done, follow-up files, what a new spec obsoletes, and step 9 in one bullet; the six steps that
  write it; the flow in eight steps; §"References a reader can follow", which is step 9 in full,
  with the visibility command and the id-against-row check before a push; a review checklist; and
  §"What stays manual", which is §4.3.
- `references/spec-skeleton.md`, 178 lines: the skeleton in one fenced block, then each part with
  what it holds, an example and what to leave out, ending with `External references` and its public
  and redacted rows.

*Revised 2026-09-14, phase 5:* the examples were to be real lines from the four specs §1.3 measured.
§2.2 keeps those repositories out of skill text, so every example describes one invented change, an
offline sync feature. Two additions: a line reference into the repository names the commit it was
read at, which is how this spec's own `AGENTS.md` line references went stale in phases 3–5; and a
review checklist, since §2.5 names reviewing a spec as a task that invokes the skill.

### 4.3 The honest limit

This flow is manual. Nothing in it is enforced by a tool: no template generator, no numbering check,
no gate that fails a spec whose §1 was not measured. The skill says so rather than implying a
machinery that does not exist. The only mechanical part is the commit-subject prefix, which a
reviewer reads.

### 4.4 The decision-record rule

The rule the `## Specs` section states:

- **While the feature is being worked on, a spec may be edited in place** to keep the plan current.
  Where later work overturns an important earlier decision, leave a short note saying what it
  replaced and why.
- **Once the feature is done, a spec is amended by addition.** An addition that supersedes an
  existing claim names it by section, and the superseded section takes a line pointing forward to
  the addition.
- **A closed spec may take a follow-up file beside it**, `followup-<topic>.md` in the spec
  directory. The rule inside it is the same: additions only, naming by section what it supersedes.
- **A new spec names what it obsoletes**, by number and section.
- **Writing a spec is not authorization to implement it** (§4.1 step 5).

**When a feature is done.** The first two bullets depend on it. A feature is done when the commit
that lands its last planned phase reaches the default branch (D14). The section states that
definition, and the spec's status line records the date.

**What the rule trades.** §1.3 measured `kotlin-ksp-mocks/specs/001-agent-skill/spec.md` at 1303
lines, with six amendment sections starting at `:608`. A reader who wants the current plan there
reads the plan and then the 696 lines from `:608` to the end, which revise parts of it. Under this
rule a phase's result edits the plan in place while the feature is in progress, and the earlier
wording stays in `git log -p`. A reader of a finished spec gets the notes on important overturned
decisions in the document, and finds minor revisions only in git history.

**In this repository.** `AGENTS.md`, in a section then headed "Specs are a decision record", adopted
the rule on 2026-09-14, before phase 1, with the definition of done written against `main`. This
spec was revised in place under it on the same day. Phase 5 replaced that section with the skill's
block, now `AGENTS.md` §"Specs", and moved the `main` definition below the skill's line.

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
"read first, by question" table, the commands to run from the root, "state a rule once", and "what
goes in which document".

The skeleton and the script write no practice section. The body's last step names `writing-style`,
`git-discipline` and `spec-driven-development`, and states that each, invoked, writes its own
section (§2.5). Two facts decide this: a script cannot invoke a skill, and a section
`repository-init` copied would be a second copy of a skill's block that no skill updates when the
block changes.

*Revised 2026-09-14:* the skeleton carried the three practice sections, "copied from" each skill
"when installed", without stating who copied them or when.

**As landed in phase 1.** The skeleton `templates/AGENTS.md.tmpl` writes five parts: the opening
lines, "Read first, by question", "Run from the repository root", "State a rule once" and "What goes
in which document". Each part the repository has to supply is a `TODO(repository-init)` line, and
the body's step 4 has the agent fill every one with the user until
`grep -rn 'TODO(repository-init)' .` prints nothing. `references/agents-md-skeleton.md` gives each
part what it holds, how to fill it, one example and what to leave out, plus two parts the template
does not write: where the practice sections go, and how a repository writes a rule of its own. This
resolves §12.3.

### 5.3 Files

- `SKILL.md`, estimated 170–220 lines, landed at 158: the agent rules file and the four-step edit,
  the file set, what goes in which document, the seven steps that write the files, the template
  grammar, and what not to assume. Phase 2 adds how to run the script in §5.5.
- `references/agents-md-skeleton.md`, estimated 150–220 lines, landed at 125: §5.2's parts.
- `references/ci-and-ignore.md`, estimated 80–140 lines, landed at 64: the check, the job on GitHub
  Actions and on another CI system, and what a `.gitignore` carries — build products, OS files,
  per-user agent state — and what stays tracked.
- `templates/`, eleven files: `AGENTS.md`, `README.md`, `CONTRIBUTING.md`, `SECURITY.md`,
  `CHANGELOG.md`, two license texts, `.gitignore`, the check in bash and in PowerShell, and the
  GitHub Actions job.
- `scripts/init-repo.sh` and `scripts/init-repo.ps1` — §5.5.

Three Markdown files rather than two because §5.2's skeleton alone would push `SKILL.md` past the
400-line budget S5 enforces. S5 reads `*.md` only, so the two scripts are outside every budget the
gate holds today; §8.5 is what covers them instead.

*Revised 2026-09-14, phase 1:* `templates/` was not planned; the skeleton was to sit inside
`references/agents-md-skeleton.md`, and each script would have carried its own copy of every file it
writes. With `templates/`, the two scripts and an agent writing the files by hand read one copy of
each file. A template line that depends on a choice starts with a condition such as `@claude` or
`@!contributing`, and a value is a token such as `{{DEFAULT_BRANCH}}`;
`skills/repository-init/SKILL.md` §"Writing a template by hand" states the grammar. The `.tmpl` suffix keeps the files out of S5 and S6, which
read `*.md`. The Apache-2.0 text is `https://www.apache.org/licenses/LICENSE-2.0.txt` as fetched on
2026-09-14 (E26); the MIT text is this repository's `LICENSE` with the year and holder as tokens.
The job template leaves `actions/checkout`'s tag as a `TODO(repository-init)` line with the command
that lists the tags, because AGENTS.md §"A skill is written for an agent in someone else's
repository" rules out a version literal in a skill.

### 5.5 The init script

The skill body stays the instruction an agent follows. The script is what removes the typing, and
it is the first executable thing this repository ships: until now `skills/` has been Markdown, and
`scripts/check-skills.sh` has been able to say it reads Markdown and JSON only.

**Where it lives, and how the body calls it.** `skills/repository-init/scripts/init-repo.sh` and
`init-repo.ps1`. Claude Code resolves a skill's own directory as `${CLAUDE_SKILL_DIR}`, so the body
writes the call as:

```bash
${CLAUDE_SKILL_DIR}/scripts/init-repo.sh --path . --agent claude
```

and the frontmatter pre-approves it and the PowerShell call with
`allowed-tools: Bash(${CLAUDE_SKILL_DIR}/scripts/init-repo.sh *) Bash(pwsh ${CLAUDE_SKILL_DIR}/scripts/init-repo.ps1 *)`.
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
| `--agent <name>` | `agents`, `claude`; repeatable | `claude` | which per-agent copies of the rules file to write (§12.6, D9) |
| `--script sh\|ps` | | the variant's own: `sh` for `init-repo.sh`, `ps` for `init-repo.ps1` | which variant of the *generated* check the target repository gets |
| `--license <id>` | `mit`, `apache-2.0`, `none` | `mit` | which license text |
| `--holder <name>` | | `git config user.name`, else ask | the MIT copyright holder |
| `--contributing` / `--no-contributing` | | on | |
| `--security` / `--no-security` | | on | |
| `--changelog` / `--no-changelog` | | **off** | D8 |
| `--specs` / `--no-specs` | | on | `specs/.gitkeep` |
| `--ci github\|none` | | `github` | who gets the rules-equality job |
| `--default-branch <name>` | | read from the repository, else ask | the branch `CONTRIBUTING.md` names and the CI job triggers on, never assumed (§2.4) |
| `--skip-existing` | | off | write only the files that do not exist |
| `--dry-run` | | off | print the file list, write nothing |
| `--force` | | off | overwrite existing files |
| `--non-interactive` | | off | never prompt — fail with what is missing instead |

**What it writes.** `AGENTS.md`, plus `CLAUDE.md` copied from it under `--agent claude`; `README.md`,
`CONTRIBUTING.md`, `SECURITY.md`, `CHANGELOG.md`, the license file, `.gitignore`, `specs/.gitkeep`;
and, when `CLAUDE.md` is written, the rules-equality check as `scripts/check-agent-rules.sh` or
`.ps1` per `--script`, and `.github/workflows/agent-rules.yml`, the CI job that calls it. With
`--agent agents` alone there is no copy to compare, and it writes neither.

*Revised 2026-09-14, phase 2:* the call used `--here`, which the table never listed; it is
`--path .`. `--license` no longer sets a skill's `license:`, because the target is any repository and
carries no skill. `--specs` writes no spec rules section, per §5.2. `--holder` is added because the
MIT text names a holder, and `--skip-existing` because "What it refuses" below leaves the common case,
a repository that already has a `README.md`, with `--force` as its only way forward. Exit status: 0
when written, 1 on a collision with nothing written, 2 on a usage error or a value missing under
`--non-interactive`.

That check is a generated script rather than the inline `cmp AGENTS.md CLAUDE.md` §5.1 describes,
for two reasons: with more than one per-agent copy the job is a loop, and `cmp` is not on a
PowerShell host. §5.1's one-line job is the `--agent claude --script sh` case of it.

**What it refuses.** Any existing file, unless `--skip-existing` or `--force`: it lists every
collision and exits 1 having written nothing. The common case is not a greenfield directory — it is a repository
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
naming — stated as decisions with the cost of each option. The four rules and the three decisions
form the `## Git and pull requests` section the skill writes through §2.5's procedure, whose step 3
settles the decisions with the user. The skill writes "the default branch" throughout and never a
literal name: two of the three repositories §1.5 measured use `main` and the third uses `master`.

*Revised 2026-09-14:* only the three decisions went into the agent rules file, and the four rules
stayed in the skill body (§2.5).

**As landed in phase 4.** The block is the four rules as bullets, then "Decisions for this
repository" with three lines holding the placeholders `DEFAULT_BRANCH`, `MERGE_STRATEGY` and
`BRANCH_NAMES`, then the skill's last line. Step 3 replaces each placeholder with the wording in the
"write" column of `skills/git-discipline/SKILL.md` §"The three decisions", which gives the cost of
each option, or deletes the line when the user leaves the decision open. Two departures:

- The fourth rule also states when to branch: when the work starts, and, for finished work on the
  default branch, after asking which branch to move it to. The former `AGENTS.md` section stated it,
  and it transfers.
- Step 2 also lists other sections carrying git rules, and step 5 shows them for replacement. This
  repository was the case: its rules sat under two headings, "Git state" and "Changes reach `main`
  through a pull request".

In this repository the block reads `main` and "Merge, rebase or squash, chosen per pull request."
The branch-names line is left out: neither former section named a scheme, and the choice is the
user's (§2.5 step 3). Below the skill's line sit this repository's own lines: an example commit
series, when CI runs, and which changes may go straight to `main`.

### 6.2 Files

`SKILL.md` alone, estimated 120–160 lines, landed at 108: the section's fenced block, §2.5's
procedure, and the cost of each option for the three decisions. No reference file: the subject is
four rules and three decisions, and splitting it would put the reader one file-open away from half of
a short document.

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
- A quotation from §1.8's sources, or a source name inside the section a skill writes (§3.5).

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

**As landed in phase 2.** S12 runs every `skills/*/scripts/init-repo.sh` and the `init-repo.ps1`
beside it; either one alone fails. `S12_MATRIX` in `scripts/check-skills.sh` holds five flag lists:
`--agent claude --script sh`, `--agent claude --script ps`, `--agent agents`,
`--no-contributing --no-security --license apache-2.0`, and
`--changelog --no-specs --ci none --license none`. Every list also names `--script`, since each
variant defaults to its own language, and `--default-branch`. Between them they write every
template and both license texts. After the diff, S12 runs the check each of the first two lists generated, which has
to pass on its own tree and fail once `CLAUDE.md` gains a line, and reruns each variant into its
tree, which has to exit non-zero and leave the tree as it was. Without `pwsh` on the PATH, S12
reports skipped; under `CI=true`, which GitHub Actions sets, it fails instead. §12.9 put `pwsh` on
`ubuntu-latest`, so S12 runs in the `skills` job. The seeded violation in `--self-test` is a pair of
fixture scripts that each write a file naming their own variant.

### 8.5 S13 — both scripts parse

`bash -n` on the `.sh` and a parse-only load of the `.ps1`, on every push. It costs milliseconds and
catches the edit that was never run on the other host. S12 subsumes it when both interpreters are
present; S13 is what still reports when only one is.

**As landed in phase 2.** S13 parses every `*.sh` and `*.sh.tmpl` under `skills/` with `bash -n`,
and every `*.ps1` and `*.ps1.tmpl` with PowerShell's `Parser.ParseFile` in one `pwsh` run, so the
check scripts in `templates/` are held too. Without `pwsh` the PowerShell half is skipped locally
and fails under `CI=true`, as in S12. The seeded violation is a fixture `.sh` holding `if then`.

### 8.6 What no check can hold

That a skill's text and the `AGENTS.md` section it came from still say the same thing. The two are
written for different audiences and will not match textually, so there is nothing to `cmp` and no
set of names to compare — unlike `kotlin-ksp-mocks`, where checks K6 and K7 compare the skill's
member names against the renderer that emits them. Here the pull-request review is the only gate,
and §2.3's one-owner rule is what keeps the review small.

### 8.7 S15 — every section reference in a spec resolves

§13.2 rule 2, for `specs/*/spec.md` and `specs/*/followup-*.md`:

- `§N`, `§N.M`, and both ends of a range `§N–§M`, resolve to a heading `## N.` or `### N.M`, or to
  a bold definition opening `**N.M —`, in the same file. A reference or range written directly after
  an external-reference id (`E16 §11–§16`) points into another document and is skipped; S16 holds
  the id.
- `§"Title"` written directly after a file name — `AGENTS.md §"Scope"`, `` `AGENTS.md` §"Scope" ``,
  or a Markdown link to the file — resolves to a heading in that file that begins with the title,
  once line breaks and indentation inside the title are collapsed to one space. A
  `§"Title"` with no file name directly before it is not checked.
- "spec NNN §N" resolves to a heading in `specs/NNN-*/spec.md`. A bare "spec NNN" names a spec that
  may not be written yet, such as "spec 002" in §11, and is not checked.

Not held: `file:line` references, and decision, check and question numbers written without `§`; the
review holds those. Seeded violation in `--self-test`: a fixture spec citing a section number it does
not have.
S14 stays reserved for §12.10.

### 8.8 S16 — every external-reference id has a row, and every private row is redacted

§13.2 rules 4 and 5, for the same files as S15:

- The file carries a `##` heading ending `External references`.
- Every `E<n>` outside that section has a row in it whose first cell is `E<n>`.
- Every row's public cell is `yes` or `no`, and every `no` row's reference cell starts with
  `*Redacted:*`.

The third bullet fails in a working copy that still names a private reference, so running
`scripts/check-skills.sh` before a push is the reminder rule 5 needs. The same failure in CI on a
pushed branch reports a name that is already public (§13.1). Seeded violations in `--self-test`: a
fixture spec citing `E2` with only an `E1` row, and a `no` row without `*Redacted:*`.

---

## 9. Phasing

One commit per phase, each prefixed `[001-practice-skills]`. The order follows §2.4: the skill that
owns a shared term is written before the skills that write that term.

| phase | what lands | why here |
| --- | --- | --- |
| 1 | `skills/repository-init/` — the body, the two reference files and `templates/` | It owns the agent rules file, the term the other three edit. Writing it first means no later skill invents its own spelling for that file. |
| 2 | `skills/repository-init/scripts/` — both variants, S12 and S13 | The body written in phase 1 is the specification the two scripts are measured against. Splitting it out keeps the Markdown review and the code review in separate commits. |
| 3 | `skills/writing-style/`, and `AGENTS.md` §"Writing style" here replaced by its block | The first consumer of §2.4's four-step edit, and the rules the remaining two are written under. |
| 4 | `skills/git-discipline/`, and the `AGENTS.md` sections "Git state" and "Changes reach `main` through a pull request" here replaced by its block under `## Git and pull requests` | The shortest; consumes the agent rules file and owns "the default branch". |
| 5 | `skills/spec-driven-development/`, and the `AGENTS.md` section "Specs are a decision record" here replaced by its block | Consumes both terms above and owns the spec directory. |
| 6 | README rows, CONTRIBUTING mention, S10, S11, S15, S16 and their self-test cases | The index and the two cross-skill checks, once there are four names to check; the two spec checks, once every spec in the repository has an `External references` section. |

§5.2 has `repository-init` naming the other three in its last step, which looks like a cycle against
this order and is not: that reference is a name and a one-line statement of what each decides
(§2.3), so phase 1 needs no text from phases 2–5.

Each phase records in this spec what it landed and where it departed from the plan, by editing the
plan in place, per §4.1 step 7 and `AGENTS.md` §"Specs", the rule this spec is itself written
under.
Phase 6's commit closes the feature (§4.4); after it, this spec takes additions only.

Phases 3–5 make this repository's `AGENTS.md` the first install of each section (AGENTS.md §"The
skills are the product"), and copy the file to `CLAUDE.md` in the same commit. Lines specific to
this repository move below each section's last line (§2.5): the CI jobs a pull request runs, which
directories count as code, and the local examples in the writing and git sections. D5 records why
this file keeps a full copy of each section.

*Revised 2026-09-14, phase 3:* this paragraph had phase 6 rewrite the README row that named "the
append-only ledger rule". That row changed to the decision-record rule in the commit that changed
the rule, before phase 1.

§13's rule reached this repository's `AGENTS.md`, `CLAUDE.md` and `CONTRIBUTING.md` in its own
commit on 2026-09-14, before phase 1 (§12.12), and reaches `spec-driven-development` in phase 5.

*Revised 2026-09-14, phase 1:* README rows were all to land in phase 6. S9 fails a skill directory
`README.md` does not mention, and AGENTS.md §"State a rule once" has a new skill land with its row,
so each of phases 1, 3, 4 and 5 turns its skill's planned row into a link to the directory. Phase 6
keeps the README's closing edits.

### 9.1 What each phase landed

| phase | landed | departures from the plan, each recorded where the plan states it |
| --- | --- | --- |
| 1 | 2026-09-14: `SKILL.md` (158 lines), `references/agents-md-skeleton.md` (125), `references/ci-and-ignore.md` (64), `templates/` (11 files), the README row | `templates/` (§5.3); §2.4 step 3 leaves an import or a symlink (§2.4); README rows per phase (§9); §12.3 resolved (§5.2) |
| 2 | 2026-09-14: `scripts/init-repo.sh` and `init-repo.ps1`, `skills/repository-init/SKILL.md` §"Run the script" and `allowed-tools`, S12 and S13 with their self-test cases, and the SECURITY, CONTRIBUTING, README, `AGENTS.md` and `ci.yml` edits. Before the commit, S12 and `--self-test` ran against PowerShell 7.4.20 on arm64; CI's runner has 7.6.5 (§12.9) | `--holder`, `--skip-existing`, `--path .` for `--here`, and no check or job under `--agent agents` (§5.5); S12's matrix and its check, rerun and skip rules (§8.4); S13 parses the templates (§8.5); §12.7 and §12.9 resolved |
| 3 | 2026-09-14: `skills/writing-style/SKILL.md` (106 lines), `references/habits.md` (162), `references/tells.md` (96), `references/ai-tells.md` (119); the 35-line block in `AGENTS.md` and `CLAUDE.md` with this repository's two lines below it; the README row; `CONTRIBUTING.md` §"Licensing" on files under another license | `references/ai-tells.md` under CC BY-SA 4.0, and thirteen tells (§3.4, §12.11); the review's fourth step (§3.3); line references into `AGENTS.md` outside §1 replaced by headings (Relates to, §2.5, §3, §4.4, §9, D5) |
| 4 | 2026-09-14: `skills/git-discipline/SKILL.md` (108 lines); the block in `AGENTS.md` and `CLAUDE.md`, replacing two sections, with this repository's lines below it; the README row | the fourth rule's branching sentence, and the search for other git sections (§6.1); this repository's branch-naming decision left open for the user (§6.1) |
| 5 | 2026-09-14: `skills/spec-driven-development/SKILL.md` (150 lines), `references/spec-skeleton.md` (178); the 20-line block in `AGENTS.md` and `CLAUDE.md`, replacing "Specs are a decision record", with this repository's three lines below it; the README row | invented examples, commit-pinned line references and the review checklist (§4.2); §4.4's `AGENTS.md` section renamed to "Specs" |

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
weeks earlier. The per-phase record in this spec (§9) is where each phase states what it
re-measured.

**D3 — Each practice skill's job on invocation is to write its section of the agent rules file.**
The alternative is a skill that is the only home of its rules and claims to govern prose, commits or
specs whenever it is loaded, which is false for every turn before it is invoked (§2.5, §3.1) — for
`git-discipline`, the turn of the agent's first commit included. The cost of the section is drift
between the skill's block and each adopter's copy, which no check can see; a re-invocation shows the
difference (§2.5 step 5). Accepted: the rules are read in every turn, at the cost of that drift.
*Revised 2026-09-14:* D3 covered `writing-style` alone.

**D4 — `git-discipline` states the three unsettled decisions rather than picking one.** §1.5
measures three repositories under one set of rules disagreeing on default branch, merge strategy and
branch naming. A skill that picks one is wrong in two of the three repositories that already exist.

**D5 — This repository's agent rules file keeps its own copy of the rules, and does not shrink to a
pointer.** After phases 3–5, three sections of `AGENTS.md`, and its `CLAUDE.md` copy, duplicate three skills'
blocks. Replacing them with "see the `writing-style` skill" would leave an agent whose session has
not invoked that skill with no rules at all — the same failure §3.1 describes. The duplication is
the cost of the rules being resident. Lines specific to this repository sit below each section's
last line (§9). Recorded here so a later reader does not "fix" it.

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
reading that agent's documentation for the filename it loads and recording it in this spec. §2.4
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

**D12 — One fixed `##` heading per skill, ending at a line naming the skill.** The heading is how a
re-invocation finds the section, and the last line marks where the skill's text stops and the
repository's own lines start (§2.5). HTML comment markers would do the same for an agent but do not
render, so a person reading the file in a Markdown viewer could not see where the block ends.

**D13 — The sources stay in the spec; the skill and its section carry the rules.** §1.8 holds the
sources and §3.5 the reasons: the measurement behind a rule belongs in the spec, two sources are in
copyright, and an attribution in the section is read every turn and asks nothing of the agent.

**D14 — A feature is done when its last planned phase lands on the default branch** (§4.4). The
alternative, the spec's author declaring it done, gives an agent no fact to check before choosing
between an in-place edit and an addition.

**D15 — An existing section is replaced only on the user's confirmation** (§2.5 step 5). §1.2
measured local examples in every existing copy of the writing-style section.

**D16 — With a public origin, a private reference is redacted before push.** §13.1: a pushed
commit stays readable through clones, forks, cached SHA views and pull requests after a rewrite, and
GitHub Support removes data only where rotating credentials cannot mitigate the risk. Redacting at
merge would leave the name readable in the branch's commits and in the pull request. The cost: in a
public repository a private name exists only in the author's working copy, and a reviewer of the
pushed branch reads the redaction text. With a private origin, redaction happens at the merge into
the published branch.

**D17 — A private reference is named in one section and cited by id everywhere else.** Redaction
then edits one section's rows, and S16 (§8.8) compares the ids the body cites with the rows
the section holds. The alternative, names inline with a list at the end, needs every citing line
edited at redaction and leaves any line the editor misses unredacted. The cost: a reader of an
unredacted working copy follows an id to the section to learn a name.

**D18 — An external reference that cites a line, a count or a quotation is pinned.** §13.1 measured
two values in this spec's §1 that the public default branch of E17 no longer shows three days after
they were read. A pin — a commit SHA, a page revision, an arXiv version — lets a reader see the
value the spec read. The cost: a pinned reference shows a past state, so the register records the
date of each pin.

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
before phase 1. **Not answered.** On 2026-09-14 the user asked for phases 1–6 to be implemented,
and they are implemented under §2.1's names. A rename after that edits the directory, `name:`, the
README row and every mention in the other three skills, which S10 (§8.2) lists.

**12.2 — Does `repository-init` write a `CHANGELOG.md`?** Asked because §1.4 measures two of four
repositories carrying one, and both of those publish an artifact. **Resolved 2026-09-11 as proposed
— D8:** the skill states the rule, a repository that publishes something a consumer pins carries a
`CHANGELOG.md` and one that does not carries none, and the script's `--changelog` defaults to off.

**12.3 — How much of the `AGENTS.md` skeleton does `repository-init` supply verbatim?** A skeleton
with fill-in instructions is small and vague; a filled example is long and gets copied unread. §5.3
budgets 150–220 lines for the reference file either way. Needs an answer before phase 4.
**Resolved 2026-09-14 in phase 1:** a skeleton whose unknowns are `TODO(repository-init)` lines,
with a reference giving one example per part and no filled file (§5.2).

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
grows only when an agent's documented filename has been read and recorded in this spec.

**12.7 — Does an executable belong in this repository, and what does it cost the documents?**
§5.5 makes `skills/` more than Markdown for the first time. Three things follow that this spec does
not settle: SECURITY.md's list of what counts as a vulnerability here should gain a line about a
defect in a shipped script, CONTRIBUTING.md's "no toolchain, Markdown and JSON only" describes
`check-skills.sh` and would need to stop describing the whole gate, and README's layout table gains
a row. The alternative is a second repository holding the script, which costs the adopter a second
install and breaks `${CLAUDE_SKILL_DIR}`. Proposed: keep it here and make the three document edits
part of phase 2. Needs an answer before phase 2. **Resolved 2026-09-14 in phase 2 as proposed:**
SECURITY.md lists a script that writes outside its directory, overwrites without the flag that
allows it, or stages, commits or pushes; CONTRIBUTING.md's layout, its "Running the checks" and its
check table name `pwsh`, S12 and S13; README's layout table gains the `scripts/` and `templates/` row.
`AGENTS.md`'s command block and `ci.yml`'s `skills` comment changed with them.

**12.8 — Is a `py` variant worth it?** `specify init` offers `sh|ps|py`. D11 ships two. A third
would cover a host with neither bash nor PowerShell, at the cost of a third implementation S12 has
to hold identical and a Python runtime the adopter may not have. Proposed: no, until an adopter asks.

**12.9 — Does GitHub's `ubuntu-latest` image ship `pwsh`?** S12 (§8.4) runs both variants in one
job if it does, and needs a second runner if it does not. Unmeasured — read it from the runner image
manifest before phase 2, not from memory. **Resolved 2026-09-14 from E22:** the repository's README
maps `ubuntu-latest` to Ubuntu 24.04, and that image's software list, image version
`20260907.300.1`, lists PowerShell 7.6.5. S12 and S13 run in the `skills` job.

**12.10 — Does a check here hold each practice skill's block?** Candidate S14: each of the three
`SKILL.md` files carries exactly one fenced block whose first line is its §2.5 heading and whose
last line names the skill. A line budget for that block would hold §2.5's cost estimates, since the
block is read in every turn of the adopter's sessions. Proposed: S14 in phase 6 with S10 and S11;
the budget once three blocks exist to measure.

**12.11 — Does `references/tells.md` take on CC BY-SA 4.0's share-alike terms?** It carries search
terms taken from Wikipedia's "Signs of AI writing" (§3.5). Proposed: read the licence's terms for
adapted material before phase 3, and move the Wikipedia-derived rows to a file carrying that licence
if they apply. **Resolved 2026-09-14 in phase 3.** E27 §1(a) defines Adapted Material as material
"subject to Copyright and Similar Rights" that is derived from the licensed material, and §2(a)(2)
and §8(a) leave uses that need no permission outside the licence. Whether a list of search words and
restated observations needs permission is a legal question. Treating it as adapted material costs
one file, so the tells went into `skills/writing-style/references/ai-tells.md` under CC BY-SA 4.0,
named in the skill's `license:`, and `CONTRIBUTING.md` §"Licensing" states the rule for such a file.

**12.12 — Does §13.2 land in `AGENTS.md`, `CLAUDE.md` and `CONTRIBUTING.md` here before phase 1?**
None of the three is code, so the change may go straight to `main` (AGENTS.md §"Git and pull
requests", in this repository's lines below the skill's). `AGENTS.md` §"Scope" today names `skills/` and defers every other file to
CONTRIBUTING.md's first rule, which states rule 1 alone. Proposed: yes, in its own commit once this
section is approved, so phases 1–6 are written under it. **Resolved 2026-09-14 as proposed:** the
rule landed in its own commit on `001-practice-skills`, before phase 1, for cherry-picking to
`main`. It went into a new section, `AGENTS.md` §"Public-facing text is hermetic", which absorbs
§"Scope"'s first bullet, instead of a rule block inside §"Scope"; `CONTRIBUTING.md` §"This
repository is public" names it.

**12.13 — Which of §13.2's rules 2–4 does a check here hold, and where?** Candidates: (a) every `§`
reference in a spec resolves to a heading in the same file, and every `specs/NNN` reference to a
directory; (b) every spec has an `External references` section, and every `E` id its body cites has
a row there; (c) every URL and `owner/repository` in a tracked file answers HTTP 200 without
authentication. (a) and (b) read the tree and keep the `skills` job's no-toolchain property, though
`scripts/check-skills.sh` is named for skills. (c) needs the network, and §13.1 measured two hosts
answering 403 to a plain client, so it would run in a separate job that does not block a merge. Rule
1 has no check here (§13.4). Proposed: (a) and (b) in phase 6 with S10 and S11; (c) deferred. Needs
an answer before phase 6. **Resolved 2026-09-14:** (a) and (b), specified as S15 (§8.7) and S16
(§8.8), landing in phase 6; (c) is not planned.

---

## 13. Public-facing text is hermetic

### 13.1 What is public, measured 2026-09-14

- **The origin is public.** `gh repo view modaal-agent/skills` reports `PUBLIC`, and
  `https://github.com/modaal-agent/skills` answers HTTP 200 without authentication. On the origin
  that day: `main` at `1753a20`, and `001-practice-skills` at `eba37d1`, which carries the
  2026-09-11 version of this spec.
- **Everything pushed there is readable by anyone:** the files on every branch, every commit
  message, and the titles, bodies and review comments of pull requests.
- **A rewrite does not withdraw a pushed commit.** GitHub's "Removing sensitive data from a
  repository" (E23) lists where a commit stays reachable after history is rewritten: "In any clones
  or forks of your repository", "Directly via their SHA-1 hashes in cached views on GitHub", and
  "Through any pull requests that reference them". It states that "GitHub Support won't remove
  non-sensitive data", and assists only where "the risk can't be mitigated by rotating affected
  credentials". A private project name is not a credential.
- **Audit of this repository.** Read: the 12 tracked files, this spec's working copy, and
  `git log --all -p` with commit messages.
  - Five repositories are named — `modaal-agent/skills`, E16, E17, E18 and E19 — and all five are
    public by `gh repo view` and by unauthenticated HTTP 200.
  - A search for local filesystem paths, and for the names of the private repositories this spec's
    2026-09-14 inputs came from, returned no match.
  - The line references into `README.md`, `CONTRIBUTING.md`, `scripts/check-skills.sh` and
    `.github/workflows/ci.yml` in "Relates to", §1.1 and §11 point at the lines they describe.
  - Of the URLs in §14, 26 were requested without authentication: 24 answered HTTP 200; `sec.gov`
    (E6) and `economist.com` (E14) answered 403.
- **Two §1 values no longer hold at a public HEAD.** At E17's HEAD, `d796b18`,
  `skills/swift-sourcery-mocks/SKILL.md` is 212 lines (§1.6: 273) and `specs/` holds six specs
  (§1.3: three). §1 read "the working `main` and `master`" of three checkouts without recording a
  commit, so a reader cannot recover the state §1 read. Still holding at E16's HEAD, `0aa6c10`:
  `specs/001-agent-skill/spec.md` is 1303 lines with E16 §11–§16 at the lines §1.3 cites; at E18's HEAD,
  `0d765d9`, `CONTRIBUTING.md:49-52` carries the branch naming and rebase-only merge §1.5 cites.

### 13.2 The rule

**Public-facing text** is everything that reaches a place anyone can read. With a public origin,
that is everything pushed: tracked files on every branch, commit messages, and pull-request titles,
bodies and review comments. With a private origin, it is everything that reaches a published branch
or mirror. **Hermetic** means a reader holding the repository and the public internet can resolve
every reference in it.

1. **No reference to a private repository or private work**: no private repository or project name,
   internal path, internal document or internal numbering. State a finding from private work by what
   was measured and when, without naming where (CONTRIBUTING.md §"This repository is public").
2. **Every internal cross-reference resolves at the same commit.** A `§N.M` resolves to a heading in
   the same document; a decision, check or question number to its definition; `file:line` to that
   line in the same repository; "spec NNN §N" to a heading in `specs/NNN-*/spec.md`. "§5.4 from
   spec-24" in a repository with no `specs/024-*` fails this rule, and so does a commit message citing a spec section its commit's tree lacks.
3. **Every external reference is to a public source**: a URL or an `owner/repository` path a reader
   can open, pinned to a commit, page revision or version wherever the text cites a line, a count or
   a quotation from it (D18).
4. **Every spec lists its external references in one section, `External references`**, one row per
   reference: an id (`E1`, `E2` …), what it is, public or private, the URL with its pin or the
   redaction text, and the sections that cite it. A section of an external document is cited after
   its id, as in `E16 §11`.
5. **A private reference is named only in that section; the body cites its id.** Redaction replaces
   the row's name and location with the redaction text — what the reference is and when it was read
   — and edits no other line (D17). The redaction text starts `*Redacted:*`, which S16 reads. Redact before the text becomes public-facing: with a public
   origin, before the commit carrying the reference is pushed; with a private origin, before the
   merge into the published branch (D16).

### 13.3 Where the rule lands

- **This repository's `AGENTS.md` and `CLAUDE.md`:** landed 2026-09-14 as `AGENTS.md`
  §"Public-facing text is hermetic", which absorbs §"Scope"'s first bullet (§12.12).
- **`CONTRIBUTING.md` §"This repository is public":** a paragraph naming the `External references`
  section every spec carries, the redaction before push, and the `AGENTS.md` section. Landed in the
  same commit.
- **`spec-driven-development`:** §4.1 step 9, the `## Specs` section (§4.1 step 8), and the
  `External references` section in `references/spec-skeleton.md` (§4.2). Landed in phase 5, with the
  redaction before push in the block's last bullet.
- **This spec:** §14 is its register, and §1.8 and §3 cite sources by register id.
- **Checks:** S15 and S16 (§8.7, §8.8), phase 6.

### 13.4 What no check here can hold

Rule 1 needs the list of private names, and committing that list to a public repository publishes
it. A check for rule 1 can only read a list kept outside the repository — for example a git-ignored
file read by a local pre-push hook — so the CI jobs here cannot run it. S15 and S16 hold rules 2, 4 and
5 from the tree (§8.7, §8.8); rule 3's pins, and whether each source is reachable, are held by
review.

---

## 14. External references

Every reference this spec makes to something outside this repository. E1–E15, E21 and E23–E27
were read on 2026-09-14. E16–E20 were read on 2026-09-11, and E16–E18 again on 2026-09-14 for their
HEADs. E22 was read on 2026-09-14. Where §1 read a repository without recording a commit, the pin is
that repository's HEAD on 2026-09-14, and §13.1 records the values that differ.

| id | reference | public | URL and pin | cited in |
| --- | --- | --- | --- | --- |
| E1 | David Ogilvy, "How to Write", as reproduced from *The Unpublished David Ogilvy* (1986); both reproductions carry identical text | yes | https://fs.blog/david-ogilvy-10-tips-on-writing/ and https://www.openculture.com/2015/04/david-ogilvys-1982-memo-how-to-write-offers-10-pieces-of-timeless-advice.html; unversioned pages | §1.8, §3.2, §3.3, §3.5 |
| E2 | George Orwell, "Politics and the English Language" | yes | https://www.orwellfoundation.com/the-orwell-foundation/orwell/essays-and-other-works/politics-and-the-english-language/; unversioned | §1.8, §3.2, §3.5 |
| E3 | William Strunk Jr., *The Elements of Style*, 1920 Harcourt printing | yes | https://www.gutenberg.org/files/37134/37134-h/37134-h.htm; Project Gutenberg #37134 | §1.8, §3.2 |
| E4 | The Kansas City Star, "Star style and rules for writing" (1999 page) and the Star's facsimile of "The Star Copy Style" | yes | https://web.archive.org/web/20101230214630/http://www.kcstar.com/hemingway/ehstarstyle.shtml (capture of 2010-12-30) and https://is.muni.cz/th/z43k9/Hemingway_style_sheet.pdf | §1.8, §3.2 |
| E5 | Winston Churchill, "Brevity", as transcribed at Wikiquote; the archive image at `images.nationalarchives.gov.uk` returned HTTP 403 | yes | https://en.wikiquote.org/wiki/Brevity; unpinned | §1.8, §3.2 |
| E6 | Jeff Bezos, 2004 email as reproduced by Business Insider; 2017 letter to shareholders | yes | https://www.businessinsider.com/jeff-bezos-email-against-powerpoint-presentations-2015-7; https://www.aboutamazon.com/news/company-news/2017-letter-to-shareholders; the same letter as SEC Exhibit 99.1, https://www.sec.gov/Archives/edgar/data/1018724/000119312518121161/d456916dex991.htm, which answers 403 to a client without a declared User-Agent | §1.8, §3.3 |
| E7 | Paul Graham, "Write Like You Talk" and "Write Simply" | yes | https://paulgraham.com/talk.html; https://paulgraham.com/simply.html | §1.8, §3.2 |
| E8 | GOV.UK, "Use clear language", "Use the right tone", and the A to Z style guide entry "Words to avoid" | yes | https://guidance.publishing.service.gov.uk/writing-to-gov-uk-standards/writing-guidelines/clear-language/; `…/writing-guidelines/right-tone/`; `…/style-guides/a-to-z-style-guide/`; pages show no update date | §1.8, §3.2, §3.4 |
| E9 | Google developer documentation style guide, "Voice and tone" and "Word list" | yes | https://developers.google.com/style/tone (updated 2026-05-27); https://developers.google.com/style/word-list (updated 2026-08-25) | §1.8, §3.2, §3.4 |
| E10 | Microsoft Writing Style Guide, "Top 10 tips for Microsoft style and voice" | yes | https://learn.microsoft.com/en-us/style-guide/top-10-tips-style-voice (ms.date 2026-07-02) | §1.8, §3.2, §3.4 |
| E11 | Wikipedia, "Wikipedia:Signs of AI writing" | yes | https://en.wikipedia.org/w/index.php?title=Wikipedia:Signs_of_AI_writing&oldid=1374467046 | §1.8, §3.2, §3.4, §3.5, §12.11 |
| E12 | Kobak, González-Márquez, Horvát, Lause, "Delving into LLM-assisted writing in biomedical publications through excess vocabulary" | yes | https://arxiv.org/abs/2406.07016v5 | §1.8 |
| E13 | Liang et al., "Mapping the Increasing Use of LLMs in Scientific Papers" | yes | https://arxiv.org/abs/2404.01268v1 | §1.8 |
| E14 | The Economist Style Guide, introduction; not fetched | yes | https://www.economist.com/styleguide/introduction; answered with a challenge page | §1.8 |
| E15 | *Redacted:* the working notes the pages E1–E13 were downloaded into, with the quotations copied from their text, compiled 2026-09-14; not published | no | — | §1.8 |
| E16 | `modaal-agent/kotlin-ksp-mocks`: `AGENTS.md`, `specs/001-agent-skill/spec.md`, `.github/workflows/ci.yml`, checks K6 and K7 | yes | https://github.com/modaal-agent/kotlin-ksp-mocks; §1 read the working `main`, unpinned; HEAD on 2026-09-14 `0aa6c10` | Relates to, §0, §1.2–§1.6, §4.4, §8.6, §13.1 |
| E17 | `modaal-agent/swift-sourcery-templates`: `AGENTS.md`, `specs/`, `LICENSE.txt`, `.claude-plugin/plugin.json`, `skills/swift-sourcery-mocks/SKILL.md`, `.github/workflows/ci.yml` | yes | https://github.com/modaal-agent/swift-sourcery-templates; §1 read the working `master`, unpinned; HEAD on 2026-09-14 `d796b18` | Relates to, §0, §1.2–§1.6, §13.1, D18 |
| E18 | `modaal-agent/duet-tutorials`: `CONTRIBUTING.md`, `LICENSE`, `SECURITY.md` | yes | https://github.com/modaal-agent/duet-tutorials; §1 read the working `main`, unpinned; HEAD on 2026-09-14 `0d765d9` | Relates to, §1.4, §1.5, D6, §13.1 |
| E19 | github/spec-kit, the `specify init` command and its flags | yes | https://github.com/github/spec-kit; unpinned | §0, §5.5, D11, §12.8 |
| E20 | Claude Code skills documentation: `${CLAUDE_SKILL_DIR}`, `allowed-tools`, `shell` | yes | https://code.claude.com/docs/en/skills; unversioned | §1.7, §5.5, D10 |
| E21 | The cross-agent `skills` CLI, npm package `skills` | yes | https://github.com/vercel-labs/skills (from `npm view skills repository.url`); unpinned | §12.6 |
| E22 | GitHub Actions runner images: the README's label table, and the Ubuntu 24.04 software list | yes | https://github.com/actions/runner-images/blob/main/README.md; https://github.com/actions/runner-images/blob/main/images/ubuntu/Ubuntu2404-Readme.md, image version `20260907.300.1`; read 2026-09-14 | §8.4, §12.9 |
| E23 | GitHub Docs, "Removing sensitive data from a repository" | yes | https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository; unversioned | §13.1, D16 |
| E24 | Claude Code documentation, "How Claude remembers your project": which instruction files load, and §"AGENTS.md" | yes | https://code.claude.com/docs/en/memory; unversioned, read 2026-09-14 | §2.4 |
| E25 | Claude Code documentation, "Settings files and precedence": `.claude/settings.local.json` as personal, per-project settings | yes | https://code.claude.com/docs/en/settings; unversioned, read 2026-09-14 | §5.3 |
| E26 | Apache License, Version 2.0, plain text | yes | https://www.apache.org/licenses/LICENSE-2.0.txt; SHA-256 `cfc7749b96f63bd31c3c42b5c471bf756814053e847c10f3eb003417bc523d30`, fetched 2026-09-14 | §5.3 |
| E27 | Creative Commons Attribution-ShareAlike 4.0 International, legal code: §1(a), §2(a)(2), §3(b), §8(a) | yes | https://creativecommons.org/licenses/by-sa/4.0/legalcode.en; the 4.0 text is fixed, read 2026-09-14 | §12.11 |
