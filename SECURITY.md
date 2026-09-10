# Security

Report a vulnerability through GitHub's private reporting on this repository
(**Security → Report a vulnerability**). Do not open a public issue for it.

Supported: `main`. This repository publishes no tags and no release assets — every install channel
reads `main` — so a fix is published by landing there.

## What counts as a vulnerability here

The product is instructions an agent reads and acts on, with the adopter's credentials, in the
adopter's repository. Report any of these:

- A skill that instructs an agent to run a destructive command — deleting files, rewriting history,
  force-pushing — without the confirmation step the instruction implies.
- A skill that instructs an agent to read a credential, token or private key and send it anywhere:
  a URL, a request header, a log line, a commit.
- A skill that tells an agent to fetch and execute code from a URL, or to install from a source the
  adopter has not named.
- Text under `skills/` written to be read as an instruction by an agent rather than by the human
  reviewing the pull request.
- A private repository name, internal path or internal planning reference that reached a published
  file.

`scripts/check-skills.sh` checks structure — frontmatter, budgets, links, manifests. It does not
read a skill for intent, so the review of the pull request is where that is caught, and a report
here is where it is caught afterwards.
