# Contributing

How a skill is added to this repository, what the checks hold it to, and how it reaches the agents
that read it.

For **what this repository publishes and how it installs**, see [README.md](README.md). For the
rules an agent working in this repository follows, see [AGENTS.md](AGENTS.md) — the same file as
[CLAUDE.md](CLAUDE.md).

## This repository is public

Everything here — skill bodies, commit messages, spec documents, check output — is world-readable
the moment it is pushed. Write for a reader who has never seen the projects these skills are used
in: no private project names, no internal file paths, no references to internal planning documents
or their numbering. Findings and measurements are welcome; describe them without naming where they
came from.

Every reference has to resolve for that reader: an internal cross-reference at the same commit, an
external one to a public source. A spec lists its external references in an `External references`
section; a reference to private work is named only there, and redacted before the commit carrying it
is pushed. [AGENTS.md](AGENTS.md) §"Public-facing text is hermetic" states the rules.

## Repository layout

```
skills/<name>/
  SKILL.md              # the resident body — under 400 lines
  references/*.md       # loaded when the agent opens one — each under 250 lines
  scripts/              # a program the body runs, in bash and in PowerShell — S12, S13
  templates/            # files a script writes, read by the script and by an agent writing by hand
.claude-plugin/
  marketplace.json      # the repository root is the marketplace
  plugin.json           # one plugin, carrying every skill under skills/
scripts/check-skills.sh # the skill checks, and --self-test for the checks themselves
.github/workflows/ci.yml
  rules                 # AGENTS.md and CLAUDE.md are byte-identical
  skills                # scripts/check-skills.sh
specs/NNN-slug/spec.md  # the plan, the measurements and the decisions behind a change
```

## Adding a skill

1. **Write the spec first when the change is larger than a commit message can carry.**
   `specs/NNN-slug/spec.md` states what is true now, what the skill will tell an adopter to do, and
   what was measured. Writing it is not authorization to write the skill — see
   [AGENTS.md](AGENTS.md).
2. **Create `skills/<name>/SKILL.md`.** `name:` in the frontmatter is the directory name; the
   frontmatter carries only `name`, `description`, `license`, `compatibility`, `metadata` and
   `allowed-tools`, one key per line, with no unquoted value containing `: `.
3. **Write `description` for the invocation decision, not for a catalogue.** It is the only part of
   the skill resident in every session, and it is what an agent matches a task against. Name the
   tasks, the files, the commands and the error strings that should pull the skill in.
4. **Split at the budgets.** New material goes in `SKILL.md` while it stays under 400 lines, and in
   `references/<subject>.md` — each under 250 — once it does not.
5. **Add the row to README.md's skill table.** Check S9 fails a skill directory the README does not
   mention.
6. **Run the checks**, then open a pull request.

## Running the checks

```bash
scripts/check-skills.sh              # what the `skills` job runs
scripts/check-skills.sh --self-test  # each check against a seeded violation
cmp AGENTS.md CLAUDE.md              # what the `rules` job runs
```

No network and no build: `grep`, `awk` and `python3`, plus `pwsh` for S12 and for S13's PowerShell
half. Without `pwsh` on the PATH those two report skipped, except under `CI=true`, where they fail.
The `skills` job's `ubuntu-latest` runner has `pwsh` installed.

`--self-test` builds a valid fixture skill tree in a temporary directory once per check, seeds one
violation of that check in each copy, and fails if the check that violation targets stays green. Run
it after editing a check — a check that has never gone red is a check that has not been run.

What the checks hold every skill to:

| check | what it fails on |
| --- | --- |
| S1 | frontmatter that does not open at line 1, does not close, or carries an unquoted value with `: ` |
| S2 | `name:` that is not the directory name, or the reserved name `synced` |
| S3 | a frontmatter key outside the Agent Skills standard's six |
| S4 | a missing `description`, or one over 1024 characters |
| S5 | a `SKILL.md` over 400 lines, or a reference over 250 |
| S6 | a relative link pointing at a file that does not exist |
| S7 | a directory under `skills/` with no `SKILL.md` |
| S8 | manifests that do not parse, or a plugin root that does not hold `skills/` |
| S9 | a skill directory README.md does not mention |
| S12 | a `scripts/init-repo.sh` without its `.ps1`, or the two writing different trees for a flag list in `S12_MATRIX`; a generated check that does not pass, or does not fail on drift; a second run that does not refuse |
| S13 | a `.sh` or `.ps1` under `skills/`, or a `.sh.tmpl` or `.ps1.tmpl`, that does not parse |

The budgets and the key list live in `scripts/check-skills.sh` as `SKILL_BODY_MAX`,
`REFERENCE_MAX` and `STANDARD_KEYS`. Change a number there, not in a document.

## Four channels publish one tree

`skills/` is read directly by every channel README.md lists — the cross-agent `skills` CLI, the
Claude Code plugin, a hand copy into `~/.claude/skills/`, and packaging for claude.ai and the Skills
API. None of them reads a tag or a release asset, so a change is published by landing on `main` and
CI is the only gate in front of it.

One plugin carries every skill in the repository. A plugin reads the `skills/` directory inside its
own root and cannot be pointed above it, so a plugin per skill would need a separate nested root per
skill — and the other three channels want one flat tree. An adopter who wants a single skill copies
that one directory.

## Licensing

MIT, inbound = outbound. Opening a pull request means your contribution is licensed under the
[MIT License](LICENSE). Each `SKILL.md` carries `license: MIT` in its frontmatter, so the license
travels with the directory through every install channel.
