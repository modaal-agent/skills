#!/usr/bin/env bash
# Agent-skill checks — every skill under `skills/` and the two `.claude-plugin/`
# manifests that publish them.
#
# What they hold a skill to: frontmatter every install channel can parse, a body
# inside the documented budgets, links that resolve, and a README index that
# lists every skill directory. They check structure, not intent — a skill that
# tells an agent to do the wrong thing passes all nine, and the pull-request
# review is where that is caught (SECURITY.md).
#
# Markdown and JSON only, through grep, awk and python3 — no toolchain, no
# network — so the `skills` job reports in seconds beside `rules`.
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
    ok "S1–S7, S9" "no skill directory under skills/ yet — nothing to check"
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
  local check root skill red=0
  WORK="$(mktemp -d)"
  # The trap runs after the function returns, so the directory it removes
  # cannot be a local.
  trap 'rm -rf "$WORK"' EXIT

  for check in S1 S2 S3 S4 S5 S6 S7 S8 S9; do
    root="$WORK/$check"
    mkdir -p "$root"
    seed_fixture "$root"
    skill="$root/skills/fixture-skill/SKILL.md"
    case "$check" in
      S1) perl -0pi -e 's/^license:.*$/license: MIT: the file is unparseable now/m' "$skill" ;;
      S2) perl -0pi -e 's/^name: .*$/name: fixture-skills/m' "$skill" ;;
      S3) perl -0pi -e 's/^license:/when_to_use: whenever\nlicense:/m' "$skill" ;;
      S4) perl -0pi -e 's/^description: .*$/description:/m' "$skill" ;;
      S5) for _ in $(seq 1 "$SKILL_BODY_MAX"); do echo "padding" >> "$skill"; done ;;
      S6) echo 'See [references/missing.md](references/missing.md).' >> "$skill" ;;
      S7) mkdir -p "$root/skills/no-body" ;;
      S8) perl -0pi -e 's/"name": "fixture"/"name": "fixture-plugin"/' "$root/.claude-plugin/plugin.json" ;;
      S9) echo "An index that mentions no skill directory." > "$root/README.md" ;;
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
