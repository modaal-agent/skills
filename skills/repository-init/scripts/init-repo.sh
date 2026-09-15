#!/usr/bin/env bash
# Write the files a repository carries on day one from the templates beside this
# script: AGENTS.md and its CLAUDE.md copy, README.md, CONTRIBUTING.md,
# SECURITY.md, CHANGELOG.md, a license, .gitignore, specs/, the agent rules check
# and its CI job. init-repo.ps1 is the same program in PowerShell, and writes the
# same bytes for the same flags.
#
# It writes files and nothing else: no git init, no git add, no commit.
#
# Usage: init-repo.sh [flags]   (--help lists them)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES="$SCRIPT_DIR/../templates"

usage() {
  cat <<'USAGE'
Usage: init-repo.sh [flags]

  --path <dir>                     where to write (default: .)
  --agent agents|claude            repeatable; claude adds CLAUDE.md, a copy of AGENTS.md
                                   (default: claude)
  --script sh|ps                   the language of the generated check (default: sh)
  --license mit|apache-2.0|none    (default: mit)
  --holder <name>                  the MIT copyright holder (default: git config user.name)
  --contributing | --no-contributing   (default: on)
  --security | --no-security           (default: on)
  --changelog | --no-changelog         (default: off)
  --specs | --no-specs                 (default: on)
  --ci github|none                 write the GitHub Actions job (default: github)
  --default-branch <name>          (default: read from git, otherwise asked)
  --skip-existing                  write only the files that do not exist
  --force                          overwrite the files that exist
  --dry-run                        print what would be written, and write nothing
  --non-interactive                never prompt; exit 2 naming the missing value

Exit status: 0 when written; 1 when a file exists and neither --skip-existing nor
--force was given, with nothing written; 2 on a usage error or a missing value.
USAGE
}

die() {
  echo "init-repo: $1" >&2
  exit 2
}

path="."
agent_seen=0
claude=0
script="sh"
license="mit"
holder=""
contributing=1
security=1
changelog=0
specs=1
ci="github"
default_branch=""
skip_existing=0
force=0
dry_run=0
non_interactive=0

while [ $# -gt 0 ]; do
  case "$1" in
    --path | --agent | --script | --license | --holder | --ci | --default-branch)
      [ $# -ge 2 ] || die "$1 needs a value"
      value="$2"
      case "$1" in
        --path) path="$value" ;;
        --agent)
          agent_seen=1
          case "$value" in
            agents) ;;
            claude) claude=1 ;;
            *) die "--agent takes agents or claude, not '$value'" ;;
          esac
          ;;
        --script)
          case "$value" in sh | ps) script="$value" ;; *) die "--script takes sh or ps, not '$value'" ;; esac
          ;;
        --license)
          case "$value" in
            mit | apache-2.0 | none) license="$value" ;;
            *) die "--license takes mit, apache-2.0 or none, not '$value'" ;;
          esac
          ;;
        --holder) holder="$value" ;;
        --ci)
          case "$value" in github | none) ci="$value" ;; *) die "--ci takes github or none, not '$value'" ;; esac
          ;;
        --default-branch) default_branch="$value" ;;
      esac
      shift
      ;;
    --contributing) contributing=1 ;;
    --no-contributing) contributing=0 ;;
    --security) security=1 ;;
    --no-security) security=0 ;;
    --changelog) changelog=1 ;;
    --no-changelog) changelog=0 ;;
    --specs) specs=1 ;;
    --no-specs) specs=0 ;;
    --skip-existing) skip_existing=1 ;;
    --force) force=1 ;;
    --dry-run) dry_run=1 ;;
    --non-interactive) non_interactive=1 ;;
    -h | --help)
      usage
      exit 0
      ;;
    *) die "unknown flag '$1'; --help lists the flags" ;;
  esac
  shift
done

if [ "$agent_seen" -eq 0 ]; then
  claude=1
fi
if [ "$skip_existing" -eq 1 ] && [ "$force" -eq 1 ]; then
  die "--skip-existing and --force contradict each other"
fi

# ── the target directory ─────────────────────────────────────────
if [ -d "$path" ]; then
  root="$(cd "$path" && pwd)"
else
  parent="$(dirname "$path")"
  [ -d "$parent" ] || die "--path $path: its parent directory does not exist"
  root="$(cd "$parent" && pwd)/$(basename "$path")"
fi
project="$(basename "$root")"

ask() {
  # ask <flag> <question>: print the answer, or exit 2 when prompting is off.
  if [ "$non_interactive" -eq 1 ] || [ ! -t 0 ]; then
    die "$1 is required: $2"
  fi
  local answer
  printf '%s ' "$2" >&2
  IFS= read -r answer
  [ -n "$answer" ] || die "$1 is required: $2"
  printf '%s' "$answer"
}

in_git() {
  command -v git >/dev/null 2>&1 && [ -d "$root" ] && git -C "$root" rev-parse --git-dir >/dev/null 2>&1
}

# ── the values the templates need ────────────────────────────────
needs_branch=0
if [ "$contributing" -eq 1 ] || { [ "$claude" -eq 1 ] && [ "$ci" = github ]; }; then
  needs_branch=1
fi
if [ "$needs_branch" -eq 1 ] && [ -z "$default_branch" ]; then
  if in_git; then
    default_branch="$(git -C "$root" symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null || true)"
    default_branch="${default_branch#origin/}"
    if [ -z "$default_branch" ]; then
      default_branch="$(git -C "$root" branch --show-current 2>/dev/null || true)"
    fi
  fi
  if [ -z "$default_branch" ]; then
    default_branch="$(ask --default-branch "The default branch's name?")"
  fi
fi

if [ "$license" = mit ] && [ -z "$holder" ]; then
  if in_git; then
    holder="$(git -C "$root" config user.name 2>/dev/null || true)"
  elif command -v git >/dev/null 2>&1; then
    holder="$(git config --global user.name 2>/dev/null || true)"
  fi
  if [ -z "$holder" ]; then
    holder="$(ask --holder "The copyright holder for the MIT license?")"
  fi
fi

case "$license" in
  mit) license_name="MIT" ;;
  apache-2.0) license_name="Apache-2.0" ;;
  *) license_name="" ;;
esac
case "$script" in
  sh) check_ext="sh" check_command="bash scripts/check-agent-rules.sh" ;;
  ps) check_ext="ps1" check_command="pwsh scripts/check-agent-rules.ps1" ;;
esac

flags=""
[ "$claude" -eq 0 ] || flags="$flags claude"
[ "$contributing" -eq 0 ] || flags="$flags contributing"
[ "$security" -eq 0 ] || flags="$flags security"
[ "$changelog" -eq 0 ] || flags="$flags changelog"
[ "$specs" -eq 0 ] || flags="$flags specs"
[ "$license" = none ] || flags="$flags license"
flags="$flags $script"

# ── the plan: template → file, in the order both variants write ──
plan_src=()
plan_dst=()
plan() {
  plan_src+=("$1")
  plan_dst+=("$2")
}

plan AGENTS.md.tmpl AGENTS.md
if [ "$claude" -eq 1 ]; then plan @copy CLAUDE.md; fi
plan README.md.tmpl README.md
if [ "$contributing" -eq 1 ]; then plan CONTRIBUTING.md.tmpl CONTRIBUTING.md; fi
if [ "$security" -eq 1 ]; then plan SECURITY.md.tmpl SECURITY.md; fi
if [ "$changelog" -eq 1 ]; then plan CHANGELOG.md.tmpl CHANGELOG.md; fi
if [ "$license" != none ]; then plan "LICENSE-$license.tmpl" LICENSE; fi
plan gitignore.tmpl .gitignore
if [ "$specs" -eq 1 ]; then plan @empty specs/.gitkeep; fi
if [ "$claude" -eq 1 ]; then
  plan "check-agent-rules.$check_ext.tmpl" "scripts/check-agent-rules.$check_ext"
  if [ "$ci" = github ]; then plan agent-rules.yml.tmpl .github/workflows/agent-rules.yml; fi
fi

existing=()
for dst in "${plan_dst[@]}"; do
  if [ -e "$root/$dst" ] || [ -L "$root/$dst" ]; then existing+=("$dst"); fi
done
if [ "${#existing[@]}" -gt 0 ] && [ "$skip_existing" -eq 0 ] && [ "$force" -eq 0 ]; then
  {
    echo "init-repo: these files exist, and nothing was written:"
    for dst in "${existing[@]}"; do echo "  $dst"; done
    echo "Rerun with --skip-existing to write only the missing files, or with --force to overwrite."
  } >&2
  exit 1
fi

# ── the renderer ─────────────────────────────────────────────────
# A line starting with conditions (@name, @!name, …) is kept only when each holds,
# and is written without them and the one space after them. Each {{TOKEN}} is
# replaced with its value. Values come through the environment, so a backslash
# or an ampersand in one is written as it is.
RENDER='
function replace_all(s, from, to,    out, i) {
  out = ""
  while ((i = index(s, from)) > 0) {
    out = out substr(s, 1, i - 1) to
    s = substr(s, i + length(from))
  }
  return out s
}
BEGIN {
  n = split(ENVIRON["INIT_FLAGS"], f, " ")
  for (i = 1; i <= n; i++) on[f[i]] = 1
  nt = split("PROJECT DEFAULT_BRANCH CHECK_COMMAND LICENSE_NAME YEAR HOLDER", tokens, " ")
}
{
  line = $0
  if (match(line, /^(@!?[a-z]+)+/)) {
    conditions = substr(line, 1, RLENGTH)
    rest = substr(line, RLENGTH + 1)
    if (rest == "" || substr(rest, 1, 1) == " ") {
      m = split(substr(conditions, 2), parts, "@")
      for (j = 1; j <= m; j++) {
        name = parts[j]
        negated = substr(name, 1, 1) == "!"
        if (negated) name = substr(name, 2)
        if ((name in on) == negated) next
      }
      line = substr(rest, 2)
    }
  }
  for (k = 1; k <= nt; k++) line = replace_all(line, "{{" tokens[k] "}}", ENVIRON["INIT_" tokens[k]])
  print line
}'

render() {
  INIT_FLAGS="$flags" \
    INIT_PROJECT="$project" \
    INIT_DEFAULT_BRANCH="$default_branch" \
    INIT_CHECK_COMMAND="$check_command" \
    INIT_LICENSE_NAME="$license_name" \
    INIT_YEAR="$(date +%Y)" \
    INIT_HOLDER="$holder" \
    awk "$RENDER" "$TEMPLATES/$1"
}

# ── write ────────────────────────────────────────────────────────
for i in "${!plan_dst[@]}"; do
  src="${plan_src[$i]}"
  dst="${plan_dst[$i]}"
  target="$root/$dst"
  if [ -e "$target" ] && [ "$skip_existing" -eq 1 ]; then
    echo "skipped $dst (exists)"
    continue
  fi
  if [ "$dry_run" -eq 1 ]; then
    echo "would write $dst"
    continue
  fi
  mkdir -p "$(dirname "$target")"
  case "$src" in
    @copy) cp "$root/AGENTS.md" "$target" ;;
    @empty) : > "$target" ;;
    *) render "$src" > "$target" ;;
  esac
  case "$dst" in *.sh) chmod +x "$target" ;; esac
  echo "wrote $dst"
done

if [ "$dry_run" -eq 1 ]; then
  echo "Dry run: nothing was written."
  exit 0
fi
echo
echo "Next: fill every TODO(repository-init) line with the user:"
echo "  grep -rn 'TODO(repository-init)' $path"
echo "Nothing was staged or committed. A commit subject for these files:"
echo "  Add the agent rules file, the contributor documents and the rules check"
