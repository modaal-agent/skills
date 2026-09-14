# Seven habits, and how to rewrite them

Each habit below breaks one or more of the twelve rules in the section. Each entry says what the
habit is, gives short before-and-after pairs, and ends with one longer rewrite that names what was
deleted.

The examples are invented for illustration. Replace a placeholder in italics with the real value
from the work being described.

## Mannered prose (rule 8)

A metaphor or a flourish where a literal phrase is available. The reader has to translate the
phrase back into the plain statement, and the metaphor carries connotations the writer did not pick.

| before | after |
| --- | --- |
| a dial worth turning | a parameter worth varying |
| this point earns its keep | this point still matters, because *the reason* |
| the migration hit a wall | the migration stops at step 4: `0042_split_orders` fails on tables over 2 GB |
| we doubled down on caching | we added a second cache, in front of the API gateway |

**Longer rewrite.**

> Before: The test suite is the safety net that lets us move fast without breaking things.
>
> After: `make test` runs 1,840 tests in 6 minutes. CI runs it on every pull request, and a failing
> run blocks the merge.

Deleted: "safety net" and "move fast without breaking things". Neither names a test, a command or a
gate. The rewrite names all three and gives the numbers.

## Aphoristic pairing (rules 7, 11)

Two short phrases set against each other so the sentence sounds like a proverb. The cost on each
side is implied, never stated, and the recommendation is left to the reader.

| before | after |
| --- | --- |
| Free now, a second migration later. | The migration costs one day now. Deferring it means a second migration when the schema changes again, about three days. Do it now. |
| Fast to write, slow to read. | The generator writes the file in 10 seconds; reviewing its 2,000 lines took 40 minutes. |
| Cheap today, expensive at scale. | At 1,000 requests a day the service costs $4 a month. At the 1 million a day planned for March it costs $4,000. |

**Longer rewrite.**

> Before: Mocks are easy to add and hard to remove. Choose wisely.
>
> After: Adding a mock to a test takes one line. Removing it later means rewriting every assertion
> that reads its recorded calls, 30 in `OrderServiceTest.kt` today. Use the real `Clock` where a
> test only needs the time.

Deleted: the proverb and "choose wisely". The rewrite gives both costs, the file they apply to, and
the choice.

## Dramatic reversal and punchline (rules 10, 11)

A sentence built to land a turn: something "has reversed", "changed everything", or went "from X to
Y" as a flourish. State the two values and when each was measured.

| before | after |
| --- | --- |
| That direction has reversed. | Build time was 4 minutes on 2026-06-01 and 9 minutes on 2026-09-01. |
| The change upgraded those steps from redundant to breaking. | Before the change, steps 3 and 4 repeated step 2 and could be skipped. After it, skipping them fails the build with `missing artifact`. |
| And then everything changed. | Delete. Write what changed, in the next sentence. |

**Longer rewrite.**

> Before: For months the flaky test was a nuisance. Then it became the whole story.
>
> After: `CheckoutFlowTest` failed in 3 of 200 CI runs in June and in 41 of 180 in August. Since
> 2026-08-12 it has blocked 11 merges.

Deleted: "nuisance" and "the whole story". The rewrite gives the failure rate at both dates and the
effect on merges.

## Negative-space phrasing (rule 6)

A statement of what is absent, such as "checked by nobody", "not cosmetic" or "not the place for
it", where the reader needs to know what is there, or what to do.

| before | after |
| --- | --- |
| This is checked by nobody. | No CI job runs `lint`. Add it to `ci.yml`; it takes about 30 seconds per run. |
| The change is not cosmetic. | The change turns the exit code from 0 into 1 when a file is missing. |
| `SKILL.md` is not the place for it. | Move the paragraph to `references/troubleshooting.md`. |
| This is not the thing to move. | Move the retry loop instead; the timeout stays where it is. |

**Longer rewrite.**

> Before: The config is not validated, and nothing stops a bad value from reaching production.
>
> After: `config.yaml` is loaded without a schema check. A typo in `timeout_ms` ships in the next
> deploy. Add `scripts/validate-config.sh` to the `build` job, which rejects an unknown key.

Deleted: "not validated" and "nothing stops". The rewrite names the file, the failure, the check to
add and the job to add it to.

## Metaphor or personification as the only statement of a point (rule 8)

A figure of speech carrying the point on its own, or a document or a system that "owes", "wants",
"fights" or "knows". A metaphor may follow the literal statement; it may not replace it.

| before | after |
| --- | --- |
| A fresh repository has no code to fight. | A new repository has no existing code, so the first commit sets the layout. |
| The gate now has teeth. | The `check` job now fails the pull request; before, it posted a warning. |
| This is what the spec still owes. | The spec's author still has to write §4 and §6. |
| The config wants a restart. | A change to `config.yaml` takes effect after `systemctl restart app`. |

**Longer rewrite.**

> Before: The monolith resists every attempt to split it, and the database knows too much.
>
> After: Three attempts to extract billing, in January, March and June, stopped at the same place:
> 14 tables are written by both billing and orders. Splitting them needs a migration that moves
> `invoice_lines` first.

Deleted: "resists" and "knows too much". The rewrite names the attempts, the tables, and the first
step.

## Rhetorical contrast standing in for content (rules 6, 11)

"Verified, not merely committed"; "it is not that X, it is that Y". The contrast implies a claim
about X that the sentence never states. Write both facts as statements, and drop the contrast.

| before | after |
| --- | --- |
| Verified, not merely committed. | The fix is committed as `a1b2c3d`, and `make test` passed on that commit. |
| It is not that the API is slow; it is that we call it 40 times. | Each page load calls the API 40 times, at about 50 ms a call. |
| This is less a bug than a design choice. | The function returns `null` for a missing user, as `docs/api.md` specifies. |

**Longer rewrite.**

> Before: The problem isn't the framework, it's how we use it.
>
> After: Every screen creates its own HTTP client, 23 of them in `app/screens/`. Each keeps its own
> connection pool. Share one client from `app/network/Client.kt`.

Deleted: the contrast with the framework, which the draft never examined. The rewrite states the
measured use and the fix.

## The closing paragraph that draws a moral (rule 11)

A section ends and the writer adds a general lesson: "ultimately", "the takeaway", "this shows that".
The paragraph repeats the section and gives the reader nothing to do. End with a concrete rule and
where it lives, or end without one.

| before | after |
| --- | --- |
| Ultimately, good tooling pays for itself. | Delete. |
| The takeaway: measure before you optimize. | Add `make bench` to `CONTRIBUTING.md`'s checklist for a change under `src/engine/`. |
| This shows how much small details matter. | Delete. |

**Longer rewrite.**

> Before: In the end, this incident is a reminder that assumptions are dangerous and that every
> team benefits from clear ownership.
>
> After: `alerts.yaml` routes `disk_full` to the platform team from 2026-09-15. The runbook for it
> is `docs/runbooks/disk-full.md`.

Deleted: the reminder and the benefit, which apply to any incident. The rewrite states the two
changes this incident produced.
