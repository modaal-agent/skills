#!/usr/bin/env bash
# Skill archives — one .zip per skill under skills/, the file claude.ai and the
# Claude desktop app take under Skills → Add → Upload skill.
#
# Each archive's root entry is the skill directory: writing-style.zip opens to
# writing-style/SKILL.md, the layout claude.ai accepted on 2026-09-15. An archive
# holds the files under skills/<name>/ that git tracks or does not ignore, as
# they are in the working tree, so .DS_Store stays out. Every entry carries the
# last commit's time instead of the checkout's. SHA256SUMS beside the archives
# lists their checksums.
#
# release.yml runs it at a version tag. Run it locally to upload a skill before
# it is released. git and python3 only.
#
# Usage:
#   scripts/package-skills.sh             # writes dist/
#   scripts/package-skills.sh <out-dir>   # writes <out-dir>/
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
OUT_DIR="${1:-$REPO_DIR/dist}"

python3 - "$REPO_DIR" "$OUT_DIR" <<'PY'
import hashlib, pathlib, subprocess, sys, time, zipfile

root, out = pathlib.Path(sys.argv[1]), pathlib.Path(sys.argv[2])

def git(*args):
    return subprocess.run(['git', '-C', str(root), *args], check=True,
                          capture_output=True, text=True).stdout

stamp = time.gmtime(int(git('log', '-1', '--format=%ct')))[:6]

# <name>/<path> for every file under skills/<name>/ that git tracks or does not
# ignore, grouped by <name>. --cached lists a tracked file deleted from the
# working tree, so each path is checked on disk.
skills = {}
for path in git('ls-files', '-z', '--cached', '--others', '--exclude-standard', '--', 'skills').split('\0'):
    parts = pathlib.PurePosixPath(path).parts
    if len(parts) > 2 and (root / path).is_file():
        skills.setdefault(parts[1], set()).add('/'.join(parts[1:]))
if not skills:
    sys.exit(f'✘ no skill directory under {root / "skills"}')

out.mkdir(parents=True, exist_ok=True)
sums = []
for name in sorted(skills):
    files = skills[name]
    if f'{name}/SKILL.md' not in files:
        sys.exit(f'✘ skills/{name}/ holds no SKILL.md, and claude.ai refuses an archive without one')
    dirs = {'/'.join(f.split('/')[:i]) + '/' for f in files for i in range(1, f.count('/') + 1)}
    archive = out / f'{name}.zip'
    with zipfile.ZipFile(archive, 'w') as zf:
        for entry in sorted(files | dirs):
            info = zipfile.ZipInfo(entry, stamp)
            info.create_system = 3  # Unix, so unzip applies the modes below
            if entry.endswith('/'):
                info.external_attr = (0o40755 << 16) | 0x10
                zf.writestr(info, b'')
            else:
                source = root / 'skills' / entry
                mode = 0o755 if source.stat().st_mode & 0o111 else 0o644
                info.external_attr = (0o100000 | mode) << 16
                zf.writestr(info, source.read_bytes(), compress_type=zipfile.ZIP_DEFLATED)
    sums.append(f'{hashlib.sha256(archive.read_bytes()).hexdigest()}  {archive.name}')
    print(f'✔ {archive} — {len(files)} file(s), {archive.stat().st_size} bytes')

(out / 'SHA256SUMS').write_text('\n'.join(sums) + '\n')
print(f'✔ {out / "SHA256SUMS"}')
PY
