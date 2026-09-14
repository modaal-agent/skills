# Tells of machine-written prose

This file adapts "Wikipedia:Signs of AI writing" by Wikipedia contributors, revision 1374467046 of
2026-09-12,
<https://en.wikipedia.org/w/index.php?title=Wikipedia:Signs_of_AI_writing&oldid=1374467046>,
licensed under CC BY-SA 4.0, <https://creativecommons.org/licenses/by-sa/4.0/>. Changes: each sign is
restated in this file's words, with a search and the rule in the writing-style section that removes
it. **This file is licensed under CC BY-SA 4.0**, unlike the rest of the skill, which is MIT.

The page records patterns its editors observed in chatbot output, and describes itself as
descriptive. A hit marks a sentence to reread against the rule named; the rewrite is whatever that
rule asks for.

Run a search with `grep -n -i -E "<pattern>" draft.md`. The patterns are extended regular
expressions, written without `\b` so they run under both GNU and BSD `grep`.

## Inflated significance (rule 10)

A claim that an ordinary detail represents, reflects or contributes to something larger.

- **Search:** `stands as|serves as a|is a testament|is a reminder|(crucial|pivotal|vital|key) (role|moment)|underscores|highlights (its|the) (importance|significance)|reflects broader|setting the stage|marks a shift|turning point|evolving landscape|indelible mark|deeply rooted`
- **Rewrite:** the value before, the value after, and the date. When there is no value to give,
  delete the claim.

## Trailing analysis clauses (rules 1, 10)

A sentence ends on an *-ing* clause that comments on what the fact means: "…, highlighting the
team's commitment to quality."

- **Search:** `, (highlighting|underscoring|emphasizing|reflecting|symbolizing|showcasing|ensuring|fostering|cultivating|contributing to)|valuable insights|(align|resonate)s? with`
- **Rewrite:** delete the clause, or replace it with the measurement it points at.

## Promotional language (rule 9)

Adjectives from advertising or travel writing, in a document meant to inform.

- **Search:** `boasts|vibrant|showcasing|exemplifies|commitment to|nestled|in the heart of|groundbreaking|renowned|diverse array`
- **Rewrite:** the property the adjective stands for, with its number: "handles 2,000 requests a
  second" for "powerful".

## Challenges-and-outlook endings (rule 11)

A closing paragraph or section that names challenges in general terms and ends on the future:
"Despite its strengths, the project faces challenges…".

- **Search:** `despite (its|these|the)|faces (several |many |some )?challenges|future (prospects|directions|outlook)`
- **Rewrite:** name each open problem with its owner and the file or issue that tracks it, or
  delete the paragraph.

## Overused vocabulary (rule 9)

Words whose frequency in published text rose after chatbots became widely available. The page dates
them by model generation; the older words have since become less common.

- **Search:** `delve|tapestry|testament|intricate|intricacies|interplay|meticulous|garner|bolstered|enduring|crucial|pivotal|landscape|underscore|showcasing|emphasizing|enhance|highlighting|fostering|additionally`
- **Rewrite:** the plain word: "read" for "delve into", "careful" for "meticulous", and for
  "crucial", the thing that depends on it.

## Avoiding "is" and "are" (rule 5)

"Serves as", "stands as", "functions as" or "marks" where "is" says the same thing.

- **Search:** `serves as|stands as|functions as|acts as (a|an|the)`
- **Rewrite:** "is" or "are".

## Negative parallelism (rule 6)

"Not just X, but Y"; "It's not X, it's Y"; "no X, no Y, just Z". The sentence rebuts a
misunderstanding nobody stated.

- **Search:** `not (just|only|merely)|it'?s not .*, it'?s|isn'?t (just|about)|no .*, no .*, just`
- **Rewrite:** state Y.

## Groups of three (rule 11)

Three adjectives, or three short phrases, in a row for their cadence.

- **Search:** `grep` finds too many false hits for this one. Reread each list of three, and keep it
  only when there are exactly three things to name.
- **Rewrite:** the items there are, as many as there are.

## Title-case headings

Every main word of a heading capitalized.

- **Search:** `^#+ ([A-Z][a-z]+ +){2,}[A-Z]`, without `-i`.
- **Rewrite:** sentence case, as in [tells.md](tells.md) §"Headings".

## Em dashes used for emphasis (rules 3, 11)

Dashes in a formulaic pattern, often spaced, setting off a clause for effect. The page's September
2026 note records that this sign appears less often in current output, so read a hit for its use,
and do not count dashes.

- **Search:** ` — ` (a spaced em dash).
- **Rewrite:** a period, a comma, a colon or parentheses, whichever the sentence needs.

## Chat phrases left in a document (rule 12)

Text written as a reply to a person, pasted into a document.

- **Search:** `I hope this helps|of course!|certainly!|you'?re absolutely right|would you like|let me know|here is a|here'?s a`
- **Rewrite:** delete it.

## Section summaries (rule 11)

A paragraph or a "Conclusion" heading that restates the section above. The page files this sign
under historical indicators, seen mostly in older models.

- **Search:** `^(in summary|in conclusion|overall|to sum up)|^#+ conclusion`
- **Rewrite:** delete it.

## Disclaimers about importance (rule 4)

"It's important to note", "worth noting", "may vary". The page files this sign under historical
indicators, seen mostly in models from about 2023.

- **Search:** `it'?s (important|critical|crucial) to (note|remember|consider)|worth noting|may vary`
- **Rewrite:** delete the disclaimer and state the fact; for "may vary", state what it varies with.
