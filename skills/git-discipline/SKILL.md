---
name: git-discipline
description: Write the git and pull-request rules into a repository's agent rules file, AGENTS.md and CLAUDE.md, so an agent there confirms every commit, leaves the index alone, writes imperative subject lines and reaches the default branch through a pull request, starting with its first commit. Records the repository's default branch, merge strategy and branch-naming scheme with the user. Use when asked to add or update git, commit or pull-request rules in AGENTS.md or CLAUDE.md; when choosing a repository's default branch, merge strategy or branch names; or when a user asks that agents stop committing, staging, pushing or merging without asking.
license: MIT
---

# Git discipline

This skill writes the `## Git and pull requests` section into the repository's agent rules file:
four rules for commits, the index, subject lines and pull requests, and the repository's answers to
three decisions. Every session in the repository reads that file from its first turn, so the rules
cover the agent's first commit, which usually comes before anyone invokes a skill.

## The section

Write this block, with the three decision lines filled in by step 3 below:

```markdown
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

- **Default branch:** DEFAULT_BRANCH
- **Merge strategy:** MERGE_STRATEGY
- **Branch names:** BRANCH_NAMES

*Maintained by the `git-discipline` skill down to this line. This repository's own lines go below.*
```

## Write the section

**The agent rules file** is `AGENTS.md`, and every byte-identical per-agent copy the repository
carries, `CLAUDE.md` among them.

1. **List which of `AGENTS.md` and `CLAUDE.md` the repository has.** With neither, stop: say so, and
   name the `repository-init` skill, which writes both. With both, run `cmp AGENTS.md CLAUDE.md`
   before editing; a `CLAUDE.md` that matches is a copy.
2. **Find `## Git and pull requests`** in `AGENTS.md` when it exists, otherwise in the one file
   present, and make every edit below in that file. Also list any other section that states git
   rules, such as a heading naming git, commits, branches or pull requests, to show the user in
   step 5.
3. **Settle the three decisions**, each as the next section describes, and replace `DEFAULT_BRANCH`,
   `MERGE_STRATEGY` and `BRANCH_NAMES` with the answers. When the user leaves a decision open,
   delete its line, and name the open decision in the report.
4. **When the heading is absent**, insert the block after the last section that ends at a line
   naming the `writing-style` or `spec-driven-development` skill, and after any lines the
   repository added below that line. With neither section present, append the block at the end of
   the file.
5. **When the heading is present, or step 2 found other git sections**, compare the block with that
   text: from the heading to the line naming this skill, or to the next `##` heading when there is
   no such line. Show the user the difference, and replace the text only when the user confirms. An
   existing section often carries examples and exceptions the repository wrote for itself; offer to
   move those below the skill's line. Lines already below it are the repository's own; leave them.
6. **Copy the edited file over each file that was a copy in step 1**: `cp AGENTS.md CLAUDE.md`.
   Leave a symlink or an `@AGENTS.md` import as it is. Report a `CLAUDE.md` that differed before
   the edit as drift, and ask the user which file holds the rules they want.
7. **Stage nothing and commit nothing.** Report the files changed, the section's line range and any
   decision left open, and propose a commit subject, such as "Add the git and pull-request rules to
   the agent rules file". The section's first rule covers this commit.

## The three decisions

Ask the user for each decision, state what each option costs, and write the wording in the "write"
column. Where the repository already shows an answer, such as a merge setting on the hosting
provider or a pattern in its branch names, propose that answer first.

### Default branch

Read it; never assume a name.

- With a remote: the name after `origin/` in `git symbolic-ref --short refs/remotes/origin/HEAD`.
  On GitHub, `gh repo view --json defaultBranchRef --jq .defaultBranchRef.name` gives the same.
- Without a remote: `git branch --show-current`, confirmed with the user, since the current branch
  may be a feature branch.

Write the name in backticks, followed by a period.

### Merge strategy

| option | write | what it costs |
| --- | --- | --- |
| merge commits | "Merge commits. Every commit on a branch is kept, with the merge commit that joined it." | History is not linear; `git log --first-parent` is needed to read the default branch alone, and `git bisect` visits branch commits that may not build. |
| rebase and fast-forward | "Rebase onto the default branch, then fast-forward. Every commit on the default branch builds." | Each commit has to build and pass on its own. Updating a pull request after a rebase needs a force-push to its branch, which changes the commit hashes a reviewer saw. |
| squash | "Squash. The pull request's title and description become its one commit." | A branch's commits collapse into one, including a spec's series of `[NNN-slug]` commits, one per phase; the phases then exist only in the pull request. |
| chosen per pull request | "Merge, rebase or squash, chosen per pull request." | Whoever merges picks each time, and the default branch's history mixes the three shapes. |

### Branch names

| option | write | what it costs |
| --- | --- | --- |
| a spec's slug for spec work | "A spec's work goes on a branch named after the spec's directory, `NNN-slug`; other work on a branch named after its topic." | Nothing to maintain; a branch without a spec carries no reference to an issue. |
| type and topic | "`<type>/<topic>`, where type is one of `feat`, `fix`, `docs` or `chore`." | A list of types to keep, and a choice between two types for a change that is both. |
| issue and topic | "`<issue-number>-<topic>`." | Every change needs an issue first. |
| no scheme | Delete the line. | A branch name tells a reviewer nothing about the change or its spec. |
