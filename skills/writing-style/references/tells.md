# Filler, buzzwords and headings: what to search a draft for

Run the searches over the draft, and read each hit. Rewrite or delete the word unless it is literal
where it stands: the exceptions column names the common literal uses. The searches are
case-insensitive and match whole words or phrases:

```bash
grep -n -i -w -E "in order to|just|simply|easily|please" draft.md
```

For a tree of files, `grep -rn -i -w -E "…" docs/` searches every file under `docs/`.
[ai-tells.md](ai-tells.md) holds the searches for the tells of machine-written prose.

## Filler (rule 4)

| search for | do instead |
| --- | --- |
| `in order to` | "to" |
| `just` | Delete it; the sentence means the same without it. |
| `simply`, `it's that simple`, `quickly` in a procedure | Delete it. A step that is simple for the writer may not be for the reader. |
| `easy`, `easily` | Delete it, or state what the step takes: the command, the time. |
| `please`, `please note` | Delete it, and state the instruction or the fact. |
| `it is important to note`, `note that`, `it's worth noting` | Delete it, and state the fact. |
| `additionally` at the start of a sentence | Delete it, or write "Also". |
| `at this time` | "now", or the date. |

## Words to avoid, with replacements (rules 7, 9)

| word | except when | use instead |
| --- | --- | --- |
| agenda | a meeting's agenda | plan |
| advance | | improve, or the specific change |
| collaborate | | work with |
| combat | military | solve, fix, or the specific action |
| commit, pledge | a git commit | "plan to" or "will", with the specific verb |
| counter | a counter that counts | prevent, or rephrase as a solution |
| deliver | parcels, post, a network delivering packets | make, create, provide, or the specific term |
| deploy | software or military | use, build, create, put into place |
| dialogue | a dialog box | spoke to, discussion |
| disincentivise | | discourage, deter |
| empower | | allow, give permission |
| facilitate | | say how: run (a workshop), host, schedule |
| focus | a UI element with keyboard focus | work on, concentrate on |
| foster | children | encourage, help |
| impact | a collision | have an effect on, influence, or the measured effect |
| incentivise | | encourage, motivate |
| initiate | | start, begin |
| key | a key that unlocks something: an API key, a map key, a dictionary key | important, or delete |
| land | aircraft | get, achieve; for a change, "merge into" |
| leverage | the financial sense | use, build on, take advantage of |
| liaise | | work with |
| overarching | | delete, or "encompassing" |
| progress | a progress bar | work on, develop, make progress |
| promote | an advertising campaign, a promotion at work, promoting a build to a release channel | recommend, support |
| robust | a sturdy object | well thought out, comprehensive, or the property: "retries 3 times" |
| slim down | | make smaller, reduce the size |
| streamline | | simplify, remove the unnecessary step |
| strengthening | a structure | the specific action: add funding, add staff, add a check |
| tackle | fishing or sport | stop, solve, deal with |
| transform | a data transformation, a geometric transform | describe the change |
| utilise, utilize | | use |
| drive | a vehicle, a disk drive | create, cause, encourage |
| drive out | cattle | stop, avoid, prevent |
| going forward, moving forward | | from now on, in the future, or the date |
| in order to | | to |
| hub, portal, one-stop shop | the name of a product | website, service |
| ring fencing | | separate; for a budget, "money that will be spent on *x*" |

The last six are metaphors: each says something the writer did not mean, and the reader has to
translate it.

## Headings

- **Sentence case**: capitalize the first word of a heading and proper nouns, and nothing else.
  "Run the checks", not "Run The Checks".
- **No period or colon at the end** of a heading.

Search for a heading with three or more capitalized words:

```bash
grep -n -E "^#+ ([A-Z][a-z]+ +){2,}[A-Z]" draft.md
```

## Sources

- The "Words to avoid" table adapts the entry "Words to avoid" in the GOV.UK A to Z style guide,
  <https://guidance.publishing.service.gov.uk/writing-to-gov-uk-standards/style-guides/a-to-z-style-guide/>,
  read 2026-09-14. Changes: the exceptions column adds uses literal in software, and some
  replacements are shortened. Contains public sector information licensed under the Open Government
  Licence v3.0, <https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/>.
- The filler entries for "in order to", "just", "easy", "please" and "please note", "simply" and
  "at this time", and the replacements for "leverage" and "utilize", adapt the Google developer
  documentation style guide's "Word list" and "Voice and tone" pages,
  <https://developers.google.com/style/word-list> and <https://developers.google.com/style/tone>,
  read 2026-09-14, licensed under CC BY 4.0, <https://creativecommons.org/licenses/by/4.0/>.
  Changes: restated as searches with replacements.
