#!/usr/bin/env bash
# Agent-skill checks — every skill under `skills/` and the two `.claude-plugin/`
# manifests that publish them.
#
# What they hold a skill to: frontmatter every install channel can parse, a body
# inside the documented budgets, links that resolve, a README index that lists
# every skill directory, scripts that parse, with the bash and PowerShell
# variants of a program writing the same files, skill names that resolve, and
# AGENTS.md and CLAUDE.md named together. For every spec under specs/, they check
# that section references resolve and private references are redacted. They check structure, not intent
# — a skill that tells an agent to do the wrong thing passes all of them, and the
# pull-request review is where that is caught (SECURITY.md).
#
# No network and no build: grep, awk and python3, plus pwsh for the PowerShell
# half of S12 and S13. Without pwsh on the PATH those two report skipped, except
# under CI=true, where they fail. The `skills` job reports in seconds beside
# `rules`.
#
# Usage:
#   scripts/check-skills.sh               # check this checkout
#   scripts/check-skills.sh <root>        # check a tree elsewhere
#   scripts/check-skills.sh --self-test   # each check red against a seeded violation
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

if [ "${1:-}" = "--self-test" ]; then
  SELF_TEST=1
  ROOT="$REPO_DIR"
else
  SELF_TEST=0
  ROOT="${1:-$REPO_DIR}"
fi

SKILLS_DIR="$ROOT/skills"
MANIFEST_DIR="$ROOT/.claude-plugin"
README="$ROOT/README.md"

# The Agent Skills standard's six keys. Claude Code accepts fourteen more; the
# Skills API and claude.ai reject every one of them by name, so a skill that has
# to stay uploadable carries none.
STANDARD_KEYS="name description license compatibility metadata allowed-tools"

# The body is resident for every turn after the skill is invoked; a reference
# costs nothing until the agent opens it. The description is resident in every
# session, invoked or not.
SKILL_BODY_MAX=400
REFERENCE_MAX=250
DESCRIPTION_MAX=1024

# ── python helpers ───────────────────────────────────────────────
# Each is a function so its heredoc is parsed at statement level; a heredoc
# written inside $( … ) is scanned for the closing paren and misreads quotes.

py_s1() {
  python3 - "$1" <<'PY'
import pathlib, re, sys
for skill in sorted(pathlib.Path(sys.argv[1]).glob('*/SKILL.md')):
    lines = skill.read_text().split('\n')
    if not lines or lines[0] != '---':
        print(f"{skill.parent.name}: line 1 is not ---"); continue
    try:
        end = lines.index('---', 1)
    except ValueError:
        print(f"{skill.parent.name}: no closing ---"); continue
    for n, line in enumerate(lines[1:end], start=2):
        if not line.strip():
            continue
        m = re.match(r'^(\s*)([A-Za-z0-9_-]+):(\s*)(.*)$', line)
        if not m:
            print(f"{skill.parent.name}:{n}: not a key: value line"); continue
        value = m.group(4)
        if value and value[0] not in '"\'' and ': ' in value:
            print(f"{skill.parent.name}:{n}: unquoted value carrying ': '")
PY
}

py_parsed() {
  python3 - "$1" <<'PY'
import pathlib, re, sys
for skill in sorted(pathlib.Path(sys.argv[1]).glob('*/SKILL.md')):
    lines = skill.read_text().split('\n')
    if not lines or lines[0] != '---' or '---' not in lines[1:]:
        continue
    parent = ''
    for line in lines[1:lines.index('---', 1)]:
        m = re.match(r'^(\s*)([A-Za-z0-9_-]+):(\s*)(.*)$', line)
        if not m:
            continue
        indent, key, value = len(m.group(1)), m.group(2), m.group(4)
        if indent == 0:
            parent = key
            print(f"{skill.parent.name}\t{key}\t{value}")
        else:
            print(f"{skill.parent.name}\t{parent}.{key}\t{value}")
PY
}

py_s6() {
  python3 - "$1" <<'PY'
import pathlib, re, sys
root = pathlib.Path(sys.argv[1])
for f in sorted(root.rglob('*.md')):
    for m in re.finditer(r'\]\((?!https?://|#|mailto:)([^)#]+)', f.read_text()):
        if not (f.parent / m.group(1)).exists():
            print(f"{f.relative_to(root)} → {m.group(1)}")
PY
}

py_s8() {
  python3 - "$1" "$2" <<'PY'
import json, pathlib, sys
manifests, root = pathlib.Path(sys.argv[1]), pathlib.Path(sys.argv[2])
try:
    marketplace = json.loads((manifests / 'marketplace.json').read_text())
    plugin = json.loads((manifests / 'plugin.json').read_text())
except Exception as error:
    print(f"a manifest does not parse: {error}"); raise SystemExit
name = plugin.get('name')
entries = [p for p in marketplace.get('plugins', []) if p.get('name') == name]
if not entries:
    listed = ', '.join(p.get('name', '?') for p in marketplace.get('plugins', []))
    print(f"plugin.json is named {name!r}; the marketplace lists {listed!r}")
    raise SystemExit
source = entries[0].get('source', './')
if not isinstance(source, str):
    print(f"the marketplace entry's source is not a path: {source!r}"); raise SystemExit
plugin_root = (root / source).resolve()
if not plugin_root.is_dir():
    print(f"source {source!r} does not resolve to a directory under {root}")
elif (root / 'skills').is_dir() and not (plugin_root / 'skills').is_dir():
    print(f"source {source!r} resolves to {plugin_root}, which holds no skills/ directory")
PY
}

py_s10() {
  python3 - "$1" <<'PY'
import pathlib, re, sys
skills = pathlib.Path(sys.argv[1])
names = {p.name for p in skills.iterdir() if p.is_dir()}
# A skill reference is a backticked name, or a list of them, followed by the
# word "skill" or "skills": "the `writing-style` skill", "the `a` or `b` skill".
token = r'`[a-z0-9]+(?:-[a-z0-9]+)*`'
group = re.compile(r'((?:' + token + r'(?:,\s+|\s+(?:and|or)\s+)?)+)\s+skills?\b')
for f in sorted(skills.rglob('*.md')):
    text = f.read_text()
    for m in group.finditer(text):
        for name in re.findall(r'`([a-z0-9-]+)`', m.group(1)):
            if name not in names:
                line = text.count('\n', 0, m.start()) + 1
                print(f"{f.relative_to(skills.parent)}:{line}: `{name}` names no directory under skills/")
PY
}

py_s11() {
  python3 - "$1" <<'PY'
import pathlib, sys
skills = pathlib.Path(sys.argv[1])
for f in sorted(p for p in skills.rglob('*') if p.is_file()):
    try:
        text = f.read_text()
    except UnicodeDecodeError:
        continue
    agents, claude = 'AGENTS.md' in text, 'CLAUDE.md' in text
    if agents != claude:
        named, missing = ('AGENTS.md', 'CLAUDE.md') if agents else ('CLAUDE.md', 'AGENTS.md')
        print(f"{f.relative_to(skills.parent)} names {named} and not {missing}")
PY
}

# py_specs <root>: one line per S15 or S16 failure, as <check>\t<message>.
py_specs() {
  python3 - "$1" <<'PY'
import pathlib, re, sys
root = pathlib.Path(sys.argv[1])

def collapse(s):
    return re.sub(r'\s+', ' ', s).strip()

def outline(path):
    """Heading titles, with and without their numbers, and the section and definition numbers."""
    titles, numbers = [], set()
    for line in path.read_text().split('\n'):
        m = re.match(r'^#{1,6}\s+(.*?)\s*$', line)
        if m:
            titles.append(collapse(m.group(1)))
            n = re.match(r'^(\d+(?:\.\d+)*)\.?\s+(.*)$', m.group(1))
            if n:
                numbers.add(n.group(1))
                titles.append(collapse(n.group(2)))
        for d in re.finditer(r'\*\*(\d+(?:\.\d+)+) —', line):
            numbers.add(d.group(1))
    return titles, numbers

specs = sorted(list(root.glob('specs/*/spec.md')) + list(root.glob('specs/*/followup-*.md')))
for spec in specs:
    rel = spec.relative_to(root)
    text = spec.read_text()
    titles, numbers = outline(spec)
    flat = collapse(text)

    # S15: §N, §N.M and both ends of §N–§M, unless written after an external id.
    for m in re.finditer(r'(E\d+ )?§(\d+(?:\.\d+)*)(?:–§(\d+(?:\.\d+)*))?', flat):
        if m.group(1) or re.search(r'spec \d{3} $', flat[max(0, m.start() - 9):m.start()]):
            continue
        for n in filter(None, (m.group(2), m.group(3))):
            if n not in numbers:
                print(f"S15\t{rel}: §{n} is not a heading or a numbered definition in this file")
    # S15: §"Title" directly after a file name, a backticked file name or a link.
    for m in re.finditer(r'(?:\[[^\]]*\]\(([^)#\s]+)\)|`([\w./-]+\.\w+)`|([\w./-]+\.\w+)) §"([^"]+)"', flat):
        link, target = m.group(1), m.group(1) or m.group(2) or m.group(3)
        candidates = [spec.parent / target] if link else [root / target, spec.parent / target]
        found = next((p for p in candidates if p.is_file()), None)
        title = collapse(m.group(4))
        if found is None:
            print(f"S15\t{rel}: {target} §\"{title}\" names a file that does not exist")
        elif not any(t.startswith(title) for t in outline(found)[0]):
            print(f"S15\t{rel}: {target} has no heading beginning \"{title}\"")
    # S15: spec NNN §N.
    for m in re.finditer(r'spec (\d{3}) §(\d+(?:\.\d+)*)', flat):
        targets = list(root.glob(f'specs/{m.group(1)}-*/spec.md'))
        if not targets or m.group(2) not in outline(targets[0])[1]:
            print(f"S15\t{rel}: spec {m.group(1)} §{m.group(2)} does not resolve")

    # S16: the register, a row per cited id, and a redaction on every private row.
    section = re.search(r'^## [^\n]*External references[ \t]*$(.*?)(?=^## |\Z)', text, re.M | re.S)
    if not section:
        print(f"S16\t{rel}: no ## heading ending in External references")
        continue
    rows = {}
    for line in section.group(1).split('\n'):
        cells = [c.strip() for c in line.strip().strip('|').split('|')]
        if len(cells) >= 3 and re.fullmatch(r'E\d+', cells[0]):
            rows[cells[0]] = cells
    body = text[:section.start()] + text[section.end():]
    for eid in sorted(set(re.findall(r'\bE\d+\b', body)), key=lambda s: int(s[1:])):
        if eid not in rows:
            print(f"S16\t{rel}: {eid} is cited and has no row in External references")
    for eid, cells in rows.items():
        if cells[2] not in ('yes', 'no'):
            print(f"S16\t{rel}: {eid}'s public cell is {cells[2]!r}, not yes or no")
        elif cells[2] == 'no' and not cells[1].startswith('*Redacted:*'):
            print(f"S16\t{rel}: {eid} is private, and its reference does not start with *Redacted:*")
PY
}

have_pwsh() { command -v pwsh >/dev/null 2>&1; }
# stdin is /dev/null so a script run inside a `while read` loop cannot read the loop's input.
run_pwsh() { pwsh -NoProfile -NonInteractive -File "$@" </dev/null; }

# The flag lists S12 runs both init-repo variants with, one run per line. Each
# line changes the file set: the copy, the check's language, the optional files,
# both license texts, and the CI job. Every line names --script, because each
# variant defaults to its own language.
S12_MATRIX='--agent claude --script sh --default-branch main --holder Fixture
--agent claude --script ps --default-branch main --holder Fixture
--agent agents --script sh --default-branch main --holder Fixture
--no-contributing --no-security --license apache-2.0 --script sh --default-branch trunk
--changelog --no-specs --ci none --license none --script ps --default-branch main'

# s12_pair <init-repo.sh> <init-repo.ps1> <empty work dir>: prints one line per
# difference between the two variants, and nothing when they agree.
s12_pair() {
  local sh="$1" ps="$2" work="$3" n=0 flags tree
  while IFS= read -r flags; do
    [ -n "$flags" ] || continue
    n=$((n + 1))
    mkdir -p "$work/$n/sh" "$work/$n/ps"
    # $flags is split into words on purpose: each matrix line is a flag list.
    # shellcheck disable=SC2086
    if ! bash "$sh" --path "$work/$n/sh/project" --non-interactive $flags >"$work/$n/sh.out" 2>&1 </dev/null; then
      echo "init-repo.sh $flags exited non-zero: $(tail -n 1 "$work/$n/sh.out")"
      continue
    fi
    # shellcheck disable=SC2086
    if ! run_pwsh "$ps" --path "$work/$n/ps/project" --non-interactive $flags >"$work/$n/ps.out" 2>&1; then
      echo "init-repo.ps1 $flags exited non-zero: $(tail -n 1 "$work/$n/ps.out")"
      continue
    fi
    if ! diff -r "$work/$n/sh/project" "$work/$n/ps/project" >"$work/$n/diff" 2>&1; then
      echo "the two variants wrote different trees for: $flags"
      head -n 20 "$work/$n/diff"
    fi
  done <<< "$S12_MATRIX"

  # Runs 1 and 2 each wrote a check. It passes on the tree it came with and fails
  # once CLAUDE.md drifts, and a second run into that tree refuses and writes nothing.
  tree="$work/1/sh/project"
  if [ -f "$tree/scripts/check-agent-rules.sh" ]; then
    if ! bash "$tree/scripts/check-agent-rules.sh" >/dev/null 2>&1; then
      echo "the check-agent-rules.sh init-repo.sh wrote fails on the tree it wrote"
    fi
    echo "drift" >> "$tree/CLAUDE.md"
    if bash "$tree/scripts/check-agent-rules.sh" >/dev/null 2>&1; then
      echo "the check-agent-rules.sh init-repo.sh wrote passes a CLAUDE.md that differs from AGENTS.md"
    fi
    if bash "$sh" --path "$tree" --non-interactive --default-branch main --holder Fixture >/dev/null 2>&1 \
      || [ "$(tail -n 1 "$tree/CLAUDE.md")" != "drift" ]; then
      echo "init-repo.sh, run into a tree it already wrote, did not refuse"
    fi
  fi
  tree="$work/2/ps/project"
  if [ -f "$tree/scripts/check-agent-rules.ps1" ]; then
    if ! run_pwsh "$tree/scripts/check-agent-rules.ps1" >/dev/null 2>&1; then
      echo "the check-agent-rules.ps1 init-repo.ps1 wrote fails on the tree it wrote"
    fi
    echo "drift" >> "$tree/CLAUDE.md"
    if run_pwsh "$tree/scripts/check-agent-rules.ps1" >/dev/null 2>&1; then
      echo "the check-agent-rules.ps1 init-repo.ps1 wrote passes a CLAUDE.md that differs from AGENTS.md"
    fi
    if run_pwsh "$ps" --path "$tree" --non-interactive --default-branch main --holder Fixture >/dev/null 2>&1 \
      || [ "$(tail -n 1 "$tree/CLAUDE.md")" != "drift" ]; then
      echo "init-repo.ps1, run into a tree it already wrote, did not refuse"
    fi
  fi
}

FAILED=0
fail() {
  printf '✘ %s — %s\n' "$1" "$2" >&2
  FAILED=1
}
ok() { printf '✔ %s — %s\n' "$1" "$2"; }

# ── the checks ───────────────────────────────────────────────────

run_checks() {
  local skill_count=0
  if [ -d "$SKILLS_DIR" ]; then
    skill_count="$(find "$SKILLS_DIR" -mindepth 2 -maxdepth 2 -name SKILL.md | wc -l | tr -d ' ')"
  fi

  if [ "$skill_count" -eq 0 ]; then
    ok "S1–S7, S9–S13" "no skill directory under skills/ yet — nothing to check"
  else
    run_skill_checks
  fi

  # ── S8: the two manifests agree with each other and the tree ───
  # Every channel but the Claude Code plugin reads skills/ directly; this is the
  # one that reads a manifest first, so a plugin root that has come away from
  # the tree fails only here.
  local s8
  s8="$(py_s8 "$MANIFEST_DIR" "$ROOT")"
  if [ -n "$s8" ]; then
    fail S8 "the plugin root and the skill tree came apart:
$s8"
  else
    ok S8 "both manifests parse and name the same plugin"
  fi

  # ── S15, S16: every reference in a spec resolves for a public reader ──
  # AGENTS.md §"Public-facing text is hermetic". S15 resolves each section
  # reference to a heading; S16 finds a row for each external id the spec cites,
  # and a redaction on each private row. A private name in a working copy fails
  # S16 here, before the push that would publish it.
  local spec_count=0 specs_out s15 s16
  if [ -d "$ROOT/specs" ]; then
    spec_count="$(find "$ROOT/specs" -mindepth 2 -maxdepth 2 -type f \( -name spec.md -o -name 'followup-*.md' \) | wc -l | tr -d ' ')"
  fi
  if [ "$spec_count" -eq 0 ]; then
    ok "S15, S16" "no spec under specs/ — nothing to check"
    return
  fi
  specs_out="$(py_specs "$ROOT")"
  s15="$(printf '%s\n' "$specs_out" | awk -F'\t' '$1 == "S15" { print $2 }')"
  s16="$(printf '%s\n' "$specs_out" | awk -F'\t' '$1 == "S16" { print $2 }')"
  if [ -n "$s15" ]; then
    fail S15 "a section reference in a spec does not resolve:
$s15"
  else
    ok S15 "every section reference in $spec_count spec file(s) resolves"
  fi
  if [ -n "$s16" ]; then
    fail S16 "an external reference in a spec has no row, or a private row is not redacted:
$s16"
  else
    ok S16 "every cited external id has a row, and every private row is redacted"
  fi
}

run_skill_checks() {
  # ── S1: the frontmatter every channel can parse ────────────────
  # `---` on line 1, one `key: value` per line, a closing `---`, and no
  # unquoted value carrying `: `. The last rule is not pedantry: the cross-agent
  # `skills` CLI parses this block with a strict YAML parser and refuses the
  # file with "Nested mappings are not allowed in compact mappings", while
  # Claude Code's own loader accepts it.
  local s1
  s1="$(py_s1 "$SKILLS_DIR")"
  if [ -n "$s1" ]; then
    fail S1 "the frontmatter does not parse for every loader:
$s1"
  else
    ok S1 "frontmatter opens at line 1 and parses"
  fi

  # Parse each skill's frontmatter into <dir>\t<key>\t<value> for the checks
  # below. A nested key is recorded under its parent as `parent.key`.
  local parsed
  parsed="$(py_parsed "$SKILLS_DIR")"

  # ── S2: `name:` is the directory, and is not `synced` ──────────
  # A skill is invoked by its directory name, and `synced` is reserved under
  # ~/.claude/skills/.
  local s2="" dir name
  while IFS= read -r dir; do
    [ -n "$dir" ] || continue
    name="$(printf '%s\n' "$parsed" | awk -F'\t' -v d="$dir" '$1==d && $2=="name" {print $3}')"
    [ "$name" = "$dir" ] || s2="$s2 $dir(name=$name)"
    [ "$dir" != "synced" ] || s2="$s2 $dir(reserved)"
  done <<< "$(printf '%s\n' "$parsed" | awk -F'\t' '{print $1}' | sort -u)"
  if [ -n "$s2" ]; then
    fail S2 "a skill is invoked by its directory name, so the two cannot differ:$s2"
  else
    ok S2 "name: equals the containing directory"
  fi

  # ── S3: only the Agent Skills standard's keys ──────────────────
  local s3="" key
  while IFS=$'\t' read -r dir key _; do
    [ -n "$key" ] || continue
    case "$key" in *.*) continue ;; esac
    case " $STANDARD_KEYS " in
      *" $key "*) ;;
      *) s3="$s3 $dir/$key" ;;
    esac
  done <<< "$parsed"
  if [ -n "$s3" ]; then
    fail S3 "packaging for the Skills API rejects a Claude Code extension key by name:$s3"
  else
    ok S3 "frontmatter carries only the six standard keys"
  fi

  # ── S4: the description is present and within budget ───────────
  # It is what auto-invocation is decided from, and it is resident in every
  # session whether the skill is used or not.
  local s4="" description length
  while IFS= read -r dir; do
    [ -n "$dir" ] || continue
    description="$(printf '%s\n' "$parsed" | awk -F'\t' -v d="$dir" '$1==d && $2=="description" {print $3}')"
    length=${#description}
    if [ "$length" -eq 0 ]; then
      s4="$s4 $dir(empty)"
    elif [ "$length" -gt "$DESCRIPTION_MAX" ]; then
      s4="$s4 $dir($length>$DESCRIPTION_MAX)"
    fi
  done <<< "$(printf '%s\n' "$parsed" | awk -F'\t' '{print $1}' | sort -u)"
  if [ -n "$s4" ]; then
    fail S4 "the description is what auto-invocation is decided from:$s4"
  else
    ok S4 "description present and within $DESCRIPTION_MAX characters"
  fi

  # ── S5: the body and each reference within budget ──────────────
  local s5="" file lines limit
  while IFS= read -r file; do
    [ -n "$file" ] || continue
    lines="$(wc -l < "$file" | tr -d ' ')"
    case "$file" in
      */SKILL.md) limit=$SKILL_BODY_MAX ;;
      *) limit=$REFERENCE_MAX ;;
    esac
    [ "$lines" -le "$limit" ] || s5="$s5 ${file#"$ROOT"/}($lines>$limit)"
  done <<< "$(find "$SKILLS_DIR" -name '*.md' | sort)"
  if [ -n "$s5" ]; then
    fail S5 "over budget:$s5"
  else
    ok S5 "SKILL.md ≤ $SKILL_BODY_MAX lines, each reference ≤ $REFERENCE_MAX"
  fi

  # ── S6: every relative link resolves ───────────────────────────
  # A skill installs as a directory, so a link out of it — to a file in this
  # repository the adopter never receives — is a link to nothing.
  local s6
  s6="$(py_s6 "$SKILLS_DIR")"
  if [ -n "$s6" ]; then
    fail S6 "a link in the skill tree points at a file that does not exist:
$s6"
  else
    ok S6 "every relative link resolves"
  fi

  # ── S7: every skill directory holds a SKILL.md ─────────────────
  # A directory without one loads as nothing, in silence.
  local s7=""
  while IFS= read -r dir; do
    [ -n "$dir" ] || continue
    [ -f "$dir/SKILL.md" ] || s7="$s7 $(basename "$dir")"
  done <<< "$(find "$SKILLS_DIR" -mindepth 1 -maxdepth 1 -type d | sort)"
  if [ -n "$s7" ]; then
    fail S7 "a directory under skills/ carries no SKILL.md:$s7"
  else
    ok S7 "every directory under skills/ holds a SKILL.md"
  fi

  # ── S9: README.md lists every skill ────────────────────────────
  # The index is maintained by hand, so this is what keeps it current.
  local s9="" base
  while IFS= read -r dir; do
    [ -n "$dir" ] || continue
    base="$(basename "$dir")"
    grep -qF "skills/$base/" "$README" || s9="$s9 $base"
  done <<< "$(find "$SKILLS_DIR" -mindepth 1 -maxdepth 1 -type d | sort)"
  if [ -n "$s9" ]; then
    fail S9 "a skill the README does not mention as skills/<name>/:$s9"
  else
    ok S9 "README.md lists every skill directory"
  fi

  # ── S10: a skill that names another skill names one that exists ─
  # The skills refer to each other by name, and a name in prose is not a link,
  # so S6 does not see it. A rename or a deletion fails here instead.
  local s10
  s10="$(py_s10 "$SKILLS_DIR")"
  if [ -n "$s10" ]; then
    fail S10 "a skill names a skill that does not exist:
$s10"
  else
    ok S10 "every skill a skill names is a directory under skills/"
  fi

  # ── S11: AGENTS.md and CLAUDE.md are named together ────────────
  # A skill that tells an agent to edit AGENTS.md alone leaves CLAUDE.md behind,
  # and the adopter's rules check fails on the next pull request.
  local s11
  s11="$(py_s11 "$SKILLS_DIR")"
  if [ -n "$s11" ]; then
    fail S11 "a file names one agent rules file without the other:
$s11"
  else
    ok S11 "every file under skills/ that names AGENTS.md or CLAUDE.md names both"
  fi

  # ── S12: a program's bash and PowerShell variants write the same tree ──
  # A program shipped in bash and in PowerShell is two programs, and one falls
  # behind the other unless something runs both. S12 runs every
  # scripts/init-repo.sh and the init-repo.ps1 beside it with the same flags into
  # empty directories, and compares the trees byte for byte.
  local s12="" s12_pairs="" script counterpart s12_work s12_out
  while IFS= read -r script; do
    [ -n "$script" ] || continue
    case "$script" in
      *.sh) counterpart="${script%.sh}.ps1" ;;
      *) counterpart="${script%.ps1}.sh" ;;
    esac
    if [ ! -f "$counterpart" ]; then
      s12="$s12
${script#"$ROOT"/} has no $(basename "$counterpart") beside it"
    elif [ "${script##*.}" = sh ]; then
      s12_pairs="$s12_pairs
$script"
    fi
  done <<< "$(find "$SKILLS_DIR" -path '*/scripts/*' -type f \( -name init-repo.sh -o -name init-repo.ps1 \) | sort)"
  if [ -n "$s12_pairs" ] && have_pwsh; then
    while IFS= read -r script; do
      [ -n "$script" ] || continue
      s12_work="$(mktemp -d)"
      s12_out="$(s12_pair "$script" "${script%.sh}.ps1" "$s12_work")"
      rm -rf "$s12_work"
      [ -z "$s12_out" ] || s12="$s12
${script#"$ROOT"/}:
$s12_out"
    done <<< "$s12_pairs"
  fi
  if [ -n "$s12" ]; then
    fail S12 "the bash and PowerShell variants disagree:$s12"
  elif [ -z "$s12_pairs" ]; then
    ok S12 "no skill ships a scripts/init-repo.sh and init-repo.ps1 pair"
  elif ! have_pwsh && [ "${CI:-}" = true ]; then
    fail S12 "pwsh is not on the PATH, so init-repo.ps1 was not run"
  elif ! have_pwsh; then
    ok S12 "skipped: pwsh is not on the PATH here, and CI runs it"
  else
    ok S12 "each init-repo pair writes the same tree for every flag list in the matrix"
  fi

  # ── S13: every shipped script parses ───────────────────────────
  # bash -n, and PowerShell's parser, over every script and script template under
  # skills/. It costs milliseconds and reports an edit never run on the other
  # host, including where S12 is skipped.
  local s13="" s13_note="" errors ps_files parse_dir file
  local -a ps_list
  while IFS= read -r script; do
    [ -n "$script" ] || continue
    if ! errors="$(bash -n "$script" 2>&1)"; then
      s13="$s13
${errors//"$ROOT"\//}"
    fi
  done <<< "$(find "$SKILLS_DIR" -type f \( -name '*.sh' -o -name '*.sh.tmpl' \) | sort)"
  ps_files="$(find "$SKILLS_DIR" -type f \( -name '*.ps1' -o -name '*.ps1.tmpl' \) | sort)"
  if [ -n "$ps_files" ] && have_pwsh; then
    ps_list=()
    while IFS= read -r file; do ps_list+=("$file"); done <<< "$ps_files"
    parse_dir="$(mktemp -d)"
    cat > "$parse_dir/parse.ps1" <<'PS'
foreach ($file in $args) {
    $errors = $null
    [void][System.Management.Automation.Language.Parser]::ParseFile($file, [ref]$null, [ref]$errors)
    foreach ($e in $errors) { Write-Output "$($file):$($e.Extent.StartLineNumber): $($e.Message)" }
}
PS
    errors="$(run_pwsh "$parse_dir/parse.ps1" "${ps_list[@]}" 2>&1 || true)"
    rm -rf "$parse_dir"
    [ -z "$errors" ] || s13="$s13
${errors//"$ROOT"\//}"
  elif [ -n "$ps_files" ] && [ "${CI:-}" = true ]; then
    s13="$s13
pwsh is not on the PATH, so no .ps1 file was parsed"
  elif [ -n "$ps_files" ]; then
    s13_note="; .ps1 files skipped, pwsh is not on the PATH"
  fi
  if [ -n "$s13" ]; then
    fail S13 "a script under skills/ does not parse, or was not parsed:$s13"
  else
    ok S13 "every script under skills/ parses$s13_note"
  fi
}

# ── the self-test ────────────────────────────────────────────────
# Each check is run against a fixture tree seeded with exactly one violation of
# it. A check that has never gone red is a check that has not been run. The
# fixture is built here rather than copied from the checkout, so the self-test
# passes on a tree with no skills in it yet.

seed_fixture() {
  local target="$1"
  mkdir -p "$target/skills/fixture-skill/references" "$target/.claude-plugin"

  cat > "$target/skills/fixture-skill/SKILL.md" <<'FIXTURE'
---
name: fixture-skill
description: A valid skill the self-test seeds one violation into. Use when running scripts/check-skills.sh --self-test.
license: MIT
---

# Fixture skill

The body the self-test edits. See [references/notes.md](references/notes.md).
FIXTURE

  echo "Notes the fixture body links to." > "$target/skills/fixture-skill/references/notes.md"
  echo "The index mentions skills/fixture-skill/ so S9 passes." > "$target/README.md"

  cat > "$target/.claude-plugin/marketplace.json" <<'FIXTURE'
{
  "name": "fixture",
  "owner": { "name": "fixture", "url": "https://example.com" },
  "plugins": [{ "name": "fixture", "source": "./" }]
}
FIXTURE

  cat > "$target/.claude-plugin/plugin.json" <<'FIXTURE'
{ "name": "fixture", "license": "MIT" }
FIXTURE
}

seed_spec() {
  mkdir -p "$1/specs/001-fixture"
  cat > "$1/specs/001-fixture/spec.md" <<'FIXTURE'
# 001 — Fixture spec

## 1. Current state

The fact in §1 comes from E1.

## 2. External references

| id | reference | public | URL and pin | cited in |
| --- | --- | --- | --- | --- |
| E1 | a public page | yes | https://example.com; read 2026-01-01 | §1 |
FIXTURE
}

expect_red() {
  local check="$1" root="$2" output status
  set +e
  output="$("$SCRIPT_DIR/$(basename "${BASH_SOURCE[0]}")" "$root" 2>&1)"
  status=$?
  set -e
  if [ "$status" -eq 0 ]; then
    printf '✘ %s stayed green against its seeded violation\n' "$check" >&2
    return 1
  fi
  if ! printf '%s\n' "$output" | grep -q "✘ $check "; then
    printf '✘ %s did not report; the run said:\n%s\n' "$check" "$output" >&2
    return 1
  fi
  printf '✔ %s red against its seeded violation\n' "$check"
}

WORK=""
self_test() {
  local seed check root skill spec red=0
  WORK="$(mktemp -d)"
  # The trap runs after the function returns, so the directory it removes
  # cannot be a local.
  trap 'rm -rf "$WORK"' EXIT

  # A seed is a check name, with a suffix after "-" when one check has two.
  for seed in S1 S2 S3 S4 S5 S6 S7 S8 S9 S10 S11 S12 S13 S15 S16 S16-redaction; do
    check="${seed%%-*}"
    if [ "$check" = S12 ] && ! have_pwsh && [ "${CI:-}" != true ]; then
      printf -- '– S12 not self-tested: pwsh is not on the PATH\n'
      continue
    fi
    root="$WORK/$seed"
    mkdir -p "$root"
    seed_fixture "$root"
    skill="$root/skills/fixture-skill/SKILL.md"
    spec="$root/specs/001-fixture/spec.md"
    case "$seed" in
      S1) perl -0pi -e 's/^license:.*$/license: MIT: the file is unparseable now/m' "$skill" ;;
      S2) perl -0pi -e 's/^name: .*$/name: fixture-skills/m' "$skill" ;;
      S3) perl -0pi -e 's/^license:/when_to_use: whenever\nlicense:/m' "$skill" ;;
      S4) perl -0pi -e 's/^description: .*$/description:/m' "$skill" ;;
      S5) for _ in $(seq 1 "$SKILL_BODY_MAX"); do echo "padding" >> "$skill"; done ;;
      S6) echo 'See [references/missing.md](references/missing.md).' >> "$skill" ;;
      S7) mkdir -p "$root/skills/no-body" ;;
      S8) perl -0pi -e 's/"name": "fixture"/"name": "fixture-plugin"/' "$root/.claude-plugin/plugin.json" ;;
      S9) echo "An index that mentions no skill directory." > "$root/README.md" ;;
      S12)
        mkdir -p "$root/skills/fixture-skill/scripts"
        cat > "$root/skills/fixture-skill/scripts/init-repo.sh" <<'FIXTURE'
#!/usr/bin/env bash
# Writes one file naming this variant, so the two variants' trees differ.
while [ $# -gt 0 ]; do
  if [ "$1" = --path ]; then target="$2"; fi
  shift
done
mkdir -p "$target" && echo sh > "$target/variant.txt"
FIXTURE
        cat > "$root/skills/fixture-skill/scripts/init-repo.ps1" <<'FIXTURE'
# Writes one file naming this variant, so the two variants' trees differ.
$target = $args[[array]::IndexOf($args, '--path') + 1]
New-Item -ItemType Directory -Force -Path $target | Out-Null
Set-Content -Path (Join-Path $target 'variant.txt') -Value 'ps'
FIXTURE
        ;;
      S13)
        mkdir -p "$root/skills/fixture-skill/scripts"
        printf '#!/usr/bin/env bash\nif then\n' > "$root/skills/fixture-skill/scripts/broken.sh"
        ;;
      S10) echo 'Invoke the `missing-skill` skill first.' >> "$skill" ;;
      S11) echo 'Add the rule to AGENTS.md.' >> "$skill" ;;
      S15)
        seed_spec "$root"
        perl -0pi -e 's/comes from E1\./comes from E1, and §9 has the rest./' "$spec"
        ;;
      S16)
        seed_spec "$root"
        perl -0pi -e 's/comes from E1\./comes from E1 and E2./' "$spec"
        ;;
      S16-redaction)
        seed_spec "$root"
        perl -0pi -e 's/comes from E1\./comes from E1 and E2./' "$spec"
        echo '| E2 | notes from a private repository | no | — | §1 |' >> "$spec"
        ;;
    esac
    expect_red "$check" "$root" || red=1
  done

  if [ "$red" -ne 0 ]; then
    printf '\n✘ self-test: a check did not go red\n' >&2
    exit 1
  fi
  printf '\n✔ self-test: every check red against its seeded violation\n'
}

if [ "$SELF_TEST" -eq 1 ]; then
  self_test
  printf '\nnow the checkout itself:\n'
fi

run_checks
if [ "$FAILED" -ne 0 ]; then
  printf '\n✘ skill checks failed\n' >&2
  exit 1
fi
printf '\n✔ skill checks passed\n'
