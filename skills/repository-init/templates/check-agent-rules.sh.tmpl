#!/usr/bin/env bash
# AGENTS.md is the agent rules file, and each file in COPIES is a byte-identical
# copy of it for an agent that reads that file instead. An edit to one and not
# the others fails here. Fix a failure with: cp AGENTS.md <copy>
set -euo pipefail
cd "$(dirname "$0")/.."

COPIES="CLAUDE.md"

status=0
for copy in $COPIES; do
  if ! cmp -s AGENTS.md "$copy"; then
    echo "FAIL: $copy differs from AGENTS.md. Fix with: cp AGENTS.md $copy" >&2
    status=1
  fi
done
if [ "$status" -eq 0 ]; then
  echo "OK: $COPIES byte-identical to AGENTS.md"
fi
exit "$status"
