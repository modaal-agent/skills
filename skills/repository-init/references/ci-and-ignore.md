# The rules check, the CI job and the ignore file

## The check

`scripts/check-agent-rules.sh` compares `AGENTS.md` with each file in its `COPIES` list, byte for
byte, with `cmp`. It prints the fix, `cp AGENTS.md <copy>`, for each copy that differs, and exits
non-zero when any does. `scripts/check-agent-rules.ps1` does the same with `Get-FileHash`, because
`cmp` is not on a Windows host.

- **Run it before a commit that touches either file.** The command is in `AGENTS.md` under "Run from
  the repository root".
- **A repository with a second copy** adds its path to `COPIES` in the bash script, or to `$Copies`
  in the PowerShell one. Add a copy only for an agent whose documentation names the file it reads.
- **A `CLAUDE.md` that is a symlink or holds an `@AGENTS.md` import** needs no check. Take it out of
  `COPIES`, and when no copy is left, delete the check and the CI job.

## The job on GitHub Actions

`templates/agent-rules.yml.tmpl` writes `.github/workflows/agent-rules.yml`, a separate workflow file
so that an existing `ci.yml` is left as it is.

- **Triggers:** every pull request, and every push to the default branch. A push to a branch with no
  pull request open runs nothing.
- **The checkout action's tag** is a `TODO(repository-init)` in the template. Resolve it with
  `git ls-remote --tags --refs https://github.com/actions/checkout 'v*'`, take the highest tag of
  the form `v<number>` it lists, and write it after `actions/checkout@`. When the repository's other
  workflows already use `actions/checkout`, use the tag they use.
- **The job needs no toolchain.** `bash` and `cmp` are on `ubuntu-latest`, and so is `pwsh` for the
  PowerShell variant. Keep it apart from build jobs, so it reports in seconds and does not wait for a
  build to provision.
- **A repository that prefers one workflow file** moves the `rules` job into `ci.yml` unchanged, and
  deletes `agent-rules.yml`.

## On another CI system

The job is one step after checkout: run `bash scripts/check-agent-rules.sh`, or
`pwsh scripts/check-agent-rules.ps1`, and fail the pipeline when it exits non-zero. Trigger it on
every merge request or pull request and on every push to the default branch. Write it in that
system's configuration file, following the pattern of the jobs already there.

## `.gitignore`

`templates/gitignore.tmpl` writes three groups. Keep them, and add to the first.

- **Build products.** The template leaves a `TODO(repository-init)` line. Read the output
  directories from the build tool's configuration or from a build run, such as `build/` for Gradle,
  `dist/` and `node_modules/` for npm, `target/` for Cargo and Maven, `.venv/` and `__pycache__/`
  for Python. Run `git status --short --ignored` after a build and add each directory the build
  created.
- **Operating-system files.** `.DS_Store` is written by macOS Finder, and `Thumbs.db` by Windows
  Explorer.
- **Per-user agent state.** Claude Code writes a user's standing permission approvals to
  `.claude/settings.local.json`, and reads personal project instructions from `CLAUDE.local.md`.
  Neither belongs in a commit.

What stays tracked:

- **`.claude/` as a whole.** `.claude/settings.json`, `.claude/skills/` and `.claude/rules/` are
  shared with everyone who clones the repository. Ignore the two per-user files by name, never the
  directory.
- **`AGENTS.md`, `CLAUDE.md` and the check.** They are the point of the file set.

Ask the user before adding a line for local environment files such as `.env`. Many repositories
ignore `.env` and track an `.env.example` beside it, and a pattern such as `.env*` ignores both.
