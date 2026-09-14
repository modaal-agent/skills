# The AGENTS.md skeleton, section by section

`templates/AGENTS.md.tmpl` writes the sections below, in this order. Each names what it holds, how
to fill its `TODO(repository-init)` lines, one example, and what to leave out. The examples are
illustrations for a repository that does not exist; write what the repository in front of you has.

Every line of `AGENTS.md` is read in every turn of every session in the repository. A line that no
agent acts on costs reading time in all of them, so keep the file under 200 lines and move
explanation to `README.md` or `CONTRIBUTING.md`.

## The opening lines

**Holds:** one sentence naming the repository and saying the rules add to `CONTRIBUTING.md` without
summarizing it, and, when `CLAUDE.md` is written, the sentence saying the two files are one file in
two places, with the command that copies one over the other and the check that compares them.

**Fill:** nothing. The template writes both from the choices.

**Leave out:** what the repository is. That is `README.md`'s first paragraph.

## Read first, by question

**Holds:** a two-column table. The left column is a question an agent has to answer before it can
act; the right column is the file that answers it. The template writes the rows for the files it
creates.

**Fill:** one row per further question, with the file or directory that answers it. Find them in
the repository: a `docs/` directory, an architecture document, a migrations directory, a style
configuration. Ask the user which questions new contributors ask most.

**Example rows:**

```markdown
| how a database schema change is made | `docs/migrations.md` |
| which modules may depend on which | `docs/architecture.md` §"Module graph" |
| the public API a change must keep compatible | `api/public.api` |
```

**Leave out:** a row per file in the repository, and a row whose right column is not a file. A
question with no file to answer it is a rule: write it as a rule in its own section.

## Run from the repository root

**Holds:** a fenced block with one command per line, each followed by a comment naming what it
checks. The template writes the agent rules check when a copy exists.

**Fill:** the command that builds, the command that runs the tests, and every command CI runs.
Read them from the CI configuration, such as the `run:` lines in `.github/workflows/*.yml`, and from
the build files, such as the `scripts` in `package.json`, a `Makefile`, `pyproject.toml` or
`build.gradle.kts`. Run each command once before writing it down, and write the time it took when it
is over a minute.

**Example:**

```bash
./gradlew build          # compiles every module and runs the unit tests, about 3 minutes
./gradlew detekt         # the static analysis CI runs
bash scripts/check-agent-rules.sh   # AGENTS.md and CLAUDE.md are byte-identical
```

**Leave out:** a command that was not run in this repository, and a command that needs a credential
the agent does not have. Name who runs the second kind instead.

## State a rule once

**Holds:** one line per number or list that a check enforces: where it is written, under what name,
and which check reads it.

**Fill:** read each check in CI and note the values it compares against, such as a coverage
threshold, a line-length limit, a list of allowed licenses or a minimum toolchain version. For each,
write the file and the name. When a value is written in more than one place today, ask the user
which place is canonical.

**Example:**

```markdown
- The minimum coverage is `minimumCoverage` in `build.gradle.kts`; the `coverage` job fails below
  it. Documents name the job, not the number.
```

**Leave out:** the value itself. A document that restates the number disagrees with the check the
first time the number changes.

## What goes in which document

**Holds:** one bullet per document the template wrote, saying what that document holds.

**Fill:** a bullet for each further document the repository keeps, such as an architecture
document or a runbook, saying what it holds and what it does not.

**Leave out:** the documents' contents. This section says where a fact goes, so an agent about to
write one puts it in one place.

## Sections other skills write

`writing-style`, `git-discipline` and `spec-driven-development` each write one section when invoked:
`## Writing style`, `## Git and pull requests` and `## Specs`. Each is inserted after "What goes in
which document", or after the last of the three already present, and ends at a line naming the skill
that wrote it. Lines a repository adds after that line, under the same heading, are its own, and the
skill leaves them alone when it updates the section.

Do not write those sections by hand from memory. Invoke the skill, or leave the section out.

## Rules this repository adds

Everything else in `AGENTS.md` is a rule the repository adds, one `##` section per subject. Write
each rule so an agent can follow it without asking:

- **Lead with the action, in bold**, as an imperative: "**Run `make fmt` before a commit.**"
- **Follow with the reason in one sentence**, naming the file, the check or the failure it prevents.
- **Name the check that holds it**, when there is one. A rule with no check is held by review; say
  so when that matters.

**Example:**

```markdown
## Generated code

- **Never edit a file under `gen/`.** `make generate` rewrites the directory from `schema/`, so a
  hand edit is lost on the next run. The `generate` job fails when `gen/` differs from its output.
```

**Leave out:** a rule the agent follows without being told, such as "write correct code"; a rule
that duplicates a check's error message; and a rule that holds only for one person's machine, which
goes in that person's `CLAUDE.local.md`.
