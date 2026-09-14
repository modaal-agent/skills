---
name: writing-style
description: Write twelve rules for prose that states facts and actions into a repository's agent rules file, AGENTS.md and CLAUDE.md, so every agent session there follows them from its first turn, and review a draft against them. Use when asked to add or update writing rules in AGENTS.md or CLAUDE.md; when a user wants the agents in a repository to stop producing LLM-isms, AI tells, filler, buzzwords or padded prose; when asked to make a document concrete or to cut it down; or when asked to review a README, a spec, a commit message, a pull-request description or a reply for those tells.
license: MIT, except references/ai-tells.md, which is CC BY-SA 4.0
---

# Writing style

This skill does two jobs.

- **Write the section.** Put the block below into the repository's agent rules file. Every session
  in the repository reads that file from its first turn, so the rules govern prose the agent writes
  before anyone invokes this skill, which a skill's own text cannot do.
- **Review a draft.** Check a piece of prose against the rules and the searches in `references/`.

## The section

Write this block verbatim, from its heading to its last line:

```markdown
## Writing style

**Scope: every piece of prose an agent writes here**: documents, code comments, commit messages,
pull-request descriptions, review comments, and replies in chat.

1. **Every sentence gives the reader a fact they can check or an action they can take**, with the
   referent named: the file, the line, the command, the number, the date. Delete a sentence that
   does neither.
2. **Write the way you would say it to a colleague.** Reread each sentence, and rewrite any you
   would not say aloud.
3. **Use short words, short sentences and short paragraphs.** Split a sentence over 25 words, and
   keep a paragraph to five sentences.
4. **Cut needless words**: "in order to", "just", "simply", "please note", "it is important to
   note", and "additionally" at the start of a sentence.
5. **Use the active voice, and start a statement with its verb.** Write "is" where "serves as" or
   "stands as" appears, and rewrite "there is" and "there are" around the subject.
6. **Say what is.** Replace "it's not X, it's Y", "not just X but Y", and any phrasing that names
   only what is absent, with a statement of what is there.
7. **Be definite, specific and concrete**: the number instead of the adjective, the path instead of
   "the config", the date instead of "recently".
8. **Use no figure of speech you have seen in print, and no metaphor as the only statement of a
   point.** Documents do not owe, want or know things: name who does the work, and where.
9. **Use no jargon, buzzwords or extravagant adjectives**, such as leverage, robust, streamline,
   empower, tackle, facilitate, vibrant, groundbreaking and pivotal.
10. **Do not inflate significance.** Nothing "underscores", "highlights" or "marks a turning
    point". Give the value before, the value after, and the date it was measured.
11. **Write no rhythm devices**: no list of three kept for its cadence, no aphoristic pairing, no
    dramatic reversal, no contrast standing in for content, no closing line that draws a moral.
    End when the content ends.
12. **Say what the reader is to do, and where**: the command to run, the file to edit, the person
    to ask.

Break any of these rules sooner than write something unclear.

*Maintained by the `writing-style` skill down to this line. This repository's own lines go below.*
```

## Write the section

**The agent rules file** is `AGENTS.md`, and every byte-identical per-agent copy the repository
carries, `CLAUDE.md` among them.

1. **List which of `AGENTS.md` and `CLAUDE.md` the repository has.** With neither, stop: say so, and
   name the `repository-init` skill, which writes both. With both, run `cmp AGENTS.md CLAUDE.md`
   before editing; a `CLAUDE.md` that matches is a copy.
2. **Find `## Writing style`** in `AGENTS.md` when it exists, otherwise in the one file present.
   Make every edit below in that file.
3. **When the heading is absent**, insert the block after the last section that ends at a line
   naming the `git-discipline` or `spec-driven-development` skill, and after any lines the
   repository added below that line. With neither section present, append the block at the end of
   the file.
4. **When the heading is present**, compare the block with the section's text, from the heading to
   the line naming this skill, or to the next `##` heading when there is no such line. Show the user
   the difference, and replace that text only when the user confirms: an existing section often
   carries examples the repository wrote for itself. Lines below the skill's line are the
   repository's own; leave them.
5. **Copy the edited file over each file that was a copy in step 1**: `cp AGENTS.md CLAUDE.md`.
   Leave a symlink or an `@AGENTS.md` import as it is. Report a `CLAUDE.md` that differed before
   the edit as drift, and ask the user which file holds the rules they want.
6. **Stage nothing and commit nothing.** Report the files changed and the section's line range, and
   propose a commit subject, such as "Add the writing-style rules to the agent rules file". When the
   `git-discipline` skill is installed, its confirmation rule covers this commit as it covers any
   other.

A repository that wants its own examples for a rule adds them below the skill's line, where step 4
leaves them alone on the next update.

## Review a draft

Use this when asked to review prose, the agent's own or the user's.

1. **Reread the draft against the twelve rules**, one sentence at a time, and rewrite each sentence
   that breaks one.
2. **Run the searches** in [references/tells.md](references/tells.md) and
   [references/ai-tells.md](references/ai-tells.md) over the draft. Each hit marks a sentence to
   reread. Rewrite it unless the word is literal there: a `commit` in git, an API `key`, a `deploy`
   of software.
3. **Check every quotation against its source**, word for word, and every number against the place
   it was measured.
4. **Report each change** as the sentence, the rule it broke and the rewrite. Apply the changes to a
   file only when the user asks for that.

[references/habits.md](references/habits.md) has before-and-after pairs for seven habits the rules
remove: mannered prose, aphoristic pairing, dramatic reversal, negative-space phrasing, metaphor as
the only statement of a point, rhetorical contrast, and the closing paragraph that draws a moral.
Read it when a rewrite of one of them is not obvious.
