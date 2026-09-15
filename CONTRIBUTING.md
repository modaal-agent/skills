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
scripts/package-skills.sh
                        # one .zip per skill into dist/, the archives a release carries
.github/workflows/ci.yml
  rules                 # AGENTS.md and CLAUDE.md are byte-identical
  skills                # scripts/check-skills.sh
.github/workflows/release.yml
  checks                # ci.yml's two jobs, at the tagged commit
  release               # the archives, published as a GitHub release
specs/NNN-slug/spec.md  # the plan, the measurements and the decisions behind a change
CHANGELOG.md            # what each release changed
_assets/                # images README.md shows
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
6. **When the skill writes a section of the agent rules file, install that section here in the same
   commit.** Copy its block into `AGENTS.md`, fill any decision lines, keep this repository's own
   lines below the skill's last line, and run `cp AGENTS.md CLAUDE.md`. [AGENTS.md](AGENTS.md)
   §"The skills are the product" states the rule; `writing-style`, `git-discipline` and
   `spec-driven-development` are the three sections installed today.
7. **Add the skill's line under `## Unreleased` in [CHANGELOG.md](CHANGELOG.md)**, as
   §"Recording a change" below says.
8. **Run the checks**, then open a pull request.

## Running the checks

```bash
scripts/check-skills.sh              # what the `skills` job runs
scripts/check-skills.sh --self-test  # each check against a seeded violation
cmp AGENTS.md CLAUDE.md              # what the `rules` job runs
```

No network and no build: `grep`, `awk` and `python3`, plus `pwsh` for S12 and for S13's PowerShell
half. Without `pwsh` on the PATH those two report skipped, except under `CI=true`, where they fail.
The `skills` job's `ubuntu-latest` runner has `pwsh` installed.

`--self-test` builds a valid fixture tree in a temporary directory once per seeded violation, seeds
that violation into the copy, and fails if the check it targets stays green. Run it after editing a
check — a check that has never gone red is a check that has not been run.

What the checks hold every skill and spec to:

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
| S10 | a backticked name followed by "skill" or "skills", in a `.md` under `skills/`, that is not a directory under `skills/` |
| S11 | a file under `skills/` that names `AGENTS.md` without `CLAUDE.md`, or `CLAUDE.md` without `AGENTS.md` |
| S12 | a `scripts/init-repo.sh` without its `.ps1`, or the two writing different trees for a flag list in `S12_MATRIX`; a generated check that does not pass, or does not fail on drift; a second run that does not refuse |
| S13 | a `.sh` or `.ps1` under `skills/`, or a `.sh.tmpl` or `.ps1.tmpl`, that does not parse |
| S15 | in a spec, a `§N` or `§N.M` with no matching heading or numbered definition in the file; a `§"Title"` after a file name with no heading in that file beginning with the title; a "spec NNN §N" that does not resolve |
| S16 | a spec with no `External references` section, an `E` id it cites with no row there, a public cell other than `yes` or `no`, or a `no` row that does not start `*Redacted:*` |

The budgets and the key list live in `scripts/check-skills.sh` as `SKILL_BODY_MAX`,
`REFERENCE_MAX` and `STANDARD_KEYS`. Change a number there, not in a document.

## Four channels publish one tree

`skills/` is what every channel README.md lists installs: the cross-agent `skills` CLI, the Claude
Code plugin, a hand copy into `~/.claude/skills/`, and an upload to claude.ai, the Claude desktop app
or the Skills API. The first three read `main`, so a change reaches them when it lands there, and CI
runs before it lands. claude.ai and the desktop app take one `.zip` per skill, which a release
publishes (§"Releasing").

One plugin carries every skill in the repository. A plugin reads the `skills/` directory inside its
own root and cannot be pointed above it, so a plugin per skill would need a separate nested root per
skill — and the other three channels want one flat tree. An adopter who wants a single skill copies
that one directory.

## Releasing

claude.ai and the Claude desktop app install a skill from an uploaded `.zip`, and read neither
`main` nor a tag. A release is how they receive a change: one archive per skill, published by
[`release.yml`](.github/workflows/release.yml) when a version tag is pushed. The other three
channels read `main`, and a release changes nothing for them.

### Recording a change

A pull request that changes a file under `skills/` adds a line under `## Unreleased` in
[CHANGELOG.md](CHANGELOG.md). The line names the skill, and says what an adopter holding the last
release has to do. A change no adopter receives, such as an edit to a check or a workflow, gets no
line.

### What the version number says

A version is `MAJOR.MINOR.PATCH`. Bump the part that matches the largest change under
`## Unreleased`:

| part | the release | an adopter holding the previous release |
| --- | --- | --- |
| MAJOR | removes or renames a skill, or renames the heading of the section a skill writes into `AGENTS.md` and `CLAUDE.md` | deletes the old skill, uploads the new archive, and renames the section in each repository that carries it |
| MINOR | adds a skill, or adds, removes or changes a rule a skill teaches | uploads the new archive, and invokes the skill again in each repository to update its section |
| PATCH | changes wording, a reference file, a template or a script, and no rule | uploads the new archive |

While MAJOR is 0, a change that calls for a MAJOR bump bumps MINOR.

### Cutting a release

1. **Write the version heading on `main`.** Rename `## Unreleased` to `## X.Y.Z — YYYY-MM-DD`, with
   the date you tag, and add an empty `## Unreleased` above it. The edit touches no code, so it may
   go straight to `main` ([AGENTS.md](AGENTS.md) §"Git and pull requests").
2. **Tag that commit with the bare version, and push the tag:**

   ```bash
   git tag X.Y.Z
   git push origin X.Y.Z
   ```

   `release.yml` triggers on `X.Y.Z` alone. A tag such as `v0.1.0` or `0.2.0-rc.1` runs nothing.
3. **Open the run** under the repository's **Actions** tab, and once it passes, the release under
   **Releases**.

To try an archive in claude.ai before tagging, run `scripts/package-skills.sh` and upload a file
from `dist/`.

### What `release.yml` checks and publishes

| job | step | fails when |
| --- | --- | --- |
| `checks` | `ci.yml`'s `rules` and `skills` jobs, at the tagged commit | a check fails |
| `release` | the tagged commit is on `main` | the tag points at a commit that is only on another branch |
| `release` | `CHANGELOG.md` has a section headed `## X.Y.Z` | the section is missing or empty |
| `release` | `scripts/package-skills.sh dist` writes `<name>.zip` for each skill, and `SHA256SUMS` | a directory under `skills/` holds no `SKILL.md` |
| `release` | `gh release create` publishes the archives and `SHA256SUMS`, with the section as the release notes | a release for the tag exists already |

Each archive's root entry is the skill directory, so `writing-style.zip` opens to
`writing-style/SKILL.md`. It holds the files under `skills/<name>/` that git tracks or does not
ignore. On 2026-09-15, claude.ai accepted a `writing-style.zip` in that layout.

### After a tag is pushed

- **A published release stays.** Adopters may hold its archives, so do not move or delete its tag.
  Correct a mistake in the next PATCH release.
- **A tag whose run failed published nothing.** Fix `main`, delete the tag with
  `git tag -d X.Y.Z && git push origin :refs/tags/X.Y.Z`, and tag the fixed commit.
- **A fix for a vulnerability** reported through [SECURITY.md](SECURITY.md) gets a PATCH release
  once it lands on `main`.

## Licensing

MIT, inbound = outbound. Opening a pull request means your contribution is licensed under the
[MIT License](LICENSE). Each `SKILL.md` carries `license:` in its frontmatter, so the license
travels with the directory through every install channel.

A file adapted from material under another license carries that license, states it in its opening
lines, and is named in its skill's `license:`. Today that is one file:
`skills/writing-style/references/ai-tells.md`, adapted from a Wikipedia page and licensed under
CC BY-SA 4.0. Material under a license that allows adaptation with attribution, such as the Open
Government Licence v3.0 or CC BY 4.0, may sit in an MIT file with its attribution in that file.
