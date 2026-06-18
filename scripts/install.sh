#!/usr/bin/env bash
set -euo pipefail

REPO_ARCHIVE_URL="${BANGIT_COMMANDS_ARCHIVE_URL:-https://github.com/vdaculan/bangit-commands/archive/refs/heads/main.tar.gz}"
INSTALL_DIR="${CODEX_SKILLS_DIR:-$HOME/.codex/skills}"

fail() {
  printf 'Error: %s\n' "$1" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || fail "missing required command: $1"
}

script_dir=""
if [ -n "${BASH_SOURCE[0]:-}" ] && [ -f "${BASH_SOURCE[0]}" ]; then
  script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
fi

tmp_dir=""
source_root=""

if [ -n "$script_dir" ] && [ -d "$script_dir/../.codex/skills" ]; then
  source_root="$(cd -- "$script_dir/.." && pwd)"
else
  require_command curl
  require_command tar

  tmp_dir="$(mktemp -d)"
  trap 'rm -rf "$tmp_dir"' EXIT
  curl -fsSL "$REPO_ARCHIVE_URL" | tar -xz -C "$tmp_dir" --strip-components=1
  source_root="$tmp_dir"
fi

skills_source="$source_root/.codex/skills"
[ -d "$skills_source" ] || fail "skills directory not found: $skills_source"

mkdir -p "$INSTALL_DIR"

installed_count=0
for skill_dir in "$skills_source"/ban-*; do
  [ -d "$skill_dir" ] || continue
  [ -f "$skill_dir/SKILL.md" ] || fail "missing SKILL.md in $skill_dir"

  skill_name="$(basename "$skill_dir")"
  target_dir="$INSTALL_DIR/$skill_name"

  rm -rf "$target_dir"
  mkdir -p "$target_dir"
  cp -R "$skill_dir"/. "$target_dir"/

  installed_count=$((installed_count + 1))
  printf 'Installed %s\n' "$skill_name"
done

[ "$installed_count" -gt 0 ] || fail "no ban-* skills found in $skills_source"

printf 'Installed %s skill(s) to %s\n' "$installed_count" "$INSTALL_DIR"
printf 'Open a new Codex thread so the skill inventory reloads.\n'
