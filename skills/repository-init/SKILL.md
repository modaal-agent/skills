---
name: repository-init
description: Set a repository up so a coding agent working in it has rules to follow from its first turn. Writes AGENTS.md and its byte-identical copy CLAUDE.md, the check and CI job that hold the two identical, README.md, CONTRIBUTING.md, SECURITY.md, a license file, .gitignore and specs/. Use when creating a new repository, when a repository has no AGENTS.md or CLAUDE.md, when asked to add agent rules, contributor documentation, a security policy or a license, when AGENTS.md and CLAUDE.md have drifted apart, or when a CI job reports that CLAUDE.md differs from AGENTS.md.
license: MIT
---

# Repository initialization

Write the files a repository carries on day one, so an agent working in it reads rules from its
first turn and a contributor finds each procedure in one place. The files are written from the
skeletons in `templates/`, with `TODO(repository-init)` lines where only the repository or its owner
knows the answer. Fill each of those with the user before anything is committed.

## The agent rules file

**The agent rules file** is `AGENTS.md`, and every byte-identical per-agent copy the repository
carries, `CLAUDE.md` among them. Skills that edit the file use that term and the edit below.

- **`AGENTS.md` is the canonical file.** Coding agents that follow the `AGENTS.md` convention read
  it. Claude Code reads `CLAUDE.md` and not `AGENTS.md`, so a repository used with Claude Code
  carries both.
- **`CLAUDE.md` is a byte-identical copy**, refreshed with `cp AGENTS.md CLAUDE.md` after every
  edit. A copy reads the same in every agent, in a Markdown viewer and on every operating system.
- **A check holds the copy identical**: `scripts/check-agent-rules.sh`, run by CI on every pull
  request. Without it, an edit to one file and not the other goes unreported, and two agents in the
  same repository read different rules.
- **A `CLAUDE.md` that is a symlink to `AGENTS.md`, or that imports it with an `@AGENTS.md` line,
  also works** for Claude Code. When the repository already has one, leave it as it is. A symlink
  needs Administrator rights or Developer Mode on Windows, and an import is read by Claude Code
  alone, which is why this skill writes a copy.

**The edit, for this skill and for any other that changes the agent rules file:**

1. List which of `AGENTS.md` and `CLAUDE.md` the repository has. When it has both, run
   `cmp AGENTS.md CLAUDE.md` before editing: a `CLAUDE.md` that matches is a copy.
2. Make the edit in `AGENTS.md` when it exists, otherwise in the one that does.
3. Copy the edited file over each file that was a copy in step 1: `cp AGENTS.md CLAUDE.md`. Leave a
   symlink or an `@AGENTS.md` import as it is. Report a `CLAUDE.md` that differed before the edit as
   drift, and ask the user which file holds the rules they want.
4. When the repository has neither file, write both with this skill. Do not create one of them as
   a side effect of an edit.

## The file set

| file | what it holds | write it when |
| --- | --- | --- |
| `AGENTS.md` | rules only: what an agent does here, and what it does not | always |
| `CLAUDE.md` | the byte-identical copy of `AGENTS.md` | Claude Code is used in the repository |
| `scripts/check-agent-rules.sh` or `.ps1` | the comparison of `AGENTS.md` with each copy | a copy exists |
| `.github/workflows/agent-rules.yml` | the CI job that runs the check | a copy exists and CI is GitHub Actions |
| `README.md` | what the repository is, how to build and run it, its layout | always |
| `CONTRIBUTING.md` | how a change is made, checked and reviewed, and the licensing of a contribution | anyone other than the author contributes, an agent included |
| `SECURITY.md` | how to report a vulnerability privately, and what counts as one | the repository is public, or ships something other people run |
| `LICENSE` | the license text | the user has picked a license |
| `.gitignore` | build products, operating-system files, per-user agent state | always |
| `specs/` | one directory per spec, `specs/NNN-slug/spec.md` | the repository plans large changes in specs |
| `CHANGELOG.md` | what each release changes | the repository publishes something a consumer pins by version |

A repository that publishes nothing versioned gets no `CHANGELOG.md`: nobody reads it, and its
entries repeat the commit log.

## What goes in which document

Each fact has one home, so the documents do not become copies of each other:

- **Rules** go in `AGENTS.md`. A paragraph explaining what something *is* goes in `README.md`.
- **Procedure** goes in `CONTRIBUTING.md`: the steps of a change, the commands, the checks.
- **What the repository is** goes in `README.md`.
- **What a release changes** goes in `CHANGELOG.md`.
- **A number or list a check enforces** is written once, in the file the check reads. The documents
  name the check, not the value.

[references/agents-md-skeleton.md](references/agents-md-skeleton.md) states what each section of
`AGENTS.md` holds, how to fill it, and what to leave out.

## Write the files

1. **Read what is there.** List the root with `ls -a`, and `.github/workflows/` when it exists.
   Note each file of the set that already exists: it is not overwritten, and the steps below write
   only the missing ones.
2. **Settle the choices with the user**, stating the default for each:
   - the license: MIT, Apache-2.0 or none, and for MIT the copyright holder, defaulting to
     `git config user.name`;
   - the default branch: the name after `origin/` in
     `git symbolic-ref --short refs/remotes/origin/HEAD`, or `git branch --show-current` when there
     is no remote, or the user's answer when the directory is not a git repository yet;
   - whether Claude Code is used here, which decides `CLAUDE.md`, the check and the CI job;
   - the check's language: bash, or PowerShell when contributors work on Windows without bash;
   - whether the repository uses specs, publishes a versioned artifact, and runs GitHub Actions.
3. **Write each missing file from `templates/`**, as the next section describes.
4. **Fill every `TODO(repository-init)` line with the user.** Read the answer from the repository
   where it shows: build files, existing CI configuration, the remote's URL. Ask for the rest.
   `grep -rn 'TODO(repository-init)' .` prints nothing when this step is done.
5. **Run the check** with the command in `AGENTS.md`, and fix what it reports.
6. **Stage nothing and commit nothing.** Report the files written and any existing file left as it
   was, and propose a commit subject, for example "Add the agent rules file, the contributor
   documents and the rules check". The user decides whether to commit.
7. **Name the three skills that write practice sections**, each of which, invoked, writes one
   `##` section into the agent rules file. This skill writes none of them.
   - `writing-style` writes `## Writing style`: the rules for prose the agent produces.
   - `git-discipline` writes `## Git and pull requests`: confirmation before a commit, the index,
     subject lines, the default branch, the merge strategy and branch naming.
   - `spec-driven-development` writes `## Specs`: when a spec is written, where, and when it is
     edited in place or amended by addition.

   Invoke each one the user asks for that is available in the session.

## Writing a template by hand

| template | written to | when |
| --- | --- | --- |
| `AGENTS.md.tmpl` | `AGENTS.md`, then copied to `CLAUDE.md` | always; the copy when `claude` holds |
| `README.md.tmpl` | `README.md` | always |
| `CONTRIBUTING.md.tmpl` | `CONTRIBUTING.md` | `contributing` |
| `SECURITY.md.tmpl` | `SECURITY.md` | `security` |
| `CHANGELOG.md.tmpl` | `CHANGELOG.md` | `changelog` |
| `LICENSE-mit.tmpl` or `LICENSE-apache-2.0.tmpl` | `LICENSE` | `license` |
| `gitignore.tmpl` | `.gitignore` | always |
| `check-agent-rules.sh.tmpl` or `.ps1.tmpl` | `scripts/check-agent-rules.sh` or `.ps1` | `claude` |
| `agent-rules.yml.tmpl` | `.github/workflows/agent-rules.yml` | `claude`, and CI is GitHub Actions |
| none | `specs/.gitkeep`, empty | `specs` |

Two edits turn a template into the file:

- **Conditions.** A line that starts with one or more conditions, such as `@claude` or
  `@!contributing@security`, is kept only when every condition holds, and is written without the
  conditions and the single space after them. `@name` holds when that choice is on; `@!name` holds
  when it is off.
- **Tokens.** Each `{{NAME}}` is replaced with its value.

| condition | holds when |
| --- | --- |
| `claude` | `CLAUDE.md` is written |
| `contributing`, `security`, `changelog`, `specs`, `license` | that file or directory is written |
| `sh`, `ps` | the check is written in bash, or in PowerShell |

| token | value |
| --- | --- |
| `{{PROJECT}}` | the name of the repository's root directory |
| `{{DEFAULT_BRANCH}}` | the default branch settled in step 2 |
| `{{CHECK_COMMAND}}` | `bash scripts/check-agent-rules.sh`, or `pwsh scripts/check-agent-rules.ps1` |
| `{{LICENSE_NAME}}` | `MIT` or `Apache-2.0` |
| `{{YEAR}}`, `{{HOLDER}}` | the current year and the copyright holder, in `LICENSE-mit.tmpl` only |

[references/ci-and-ignore.md](references/ci-and-ignore.md) covers the check, the CI job on GitHub
Actions and on other CI systems, and what `.gitignore` carries.

## What not to assume

- **The hosting provider and the CI system.** The job template is GitHub Actions. On any other CI,
  the job checks out the repository and runs the check on every pull request and on every push to
  the default branch.
- **The language and the build tool.** The skeletons name none. The build and test commands come
  from the repository's own files, or from the user.
- **Whether the repository is public.** Ask before writing `SECURITY.md` wording that names a
  public reporting channel.
- **The default branch's name.** Read it, or ask; never write `main` or `master` without doing one
  of the two.
