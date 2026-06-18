#!/bin/sh
set -eu
umask 077

codex_home="${CODEX_HOME:-$HOME/.codex}"
config_path="$codex_home/config.toml"
tmp_path=""

cleanup() {
  if [ -n "$tmp_path" ] && [ -e "$tmp_path" ]; then
    rm -f "$tmp_path"
  fi
}

trap cleanup EXIT HUP INT TERM

if [ -L "$config_path" ]; then
  printf 'Refusing to modify symbolic link: %s\n' "$config_path" >&2
  exit 1
fi

if [ ! -f "$config_path" ]; then
  printf 'No config found at %s\n' "$config_path"
  exit 0
fi

timestamp="$(date +%Y%m%d-%H%M%S)"
backup_path="$config_path.backup-$timestamp-$$"
cp "$config_path" "$backup_path"
chmod 600 "$backup_path"

tmp_path="$(mktemp "$codex_home/.config.toml.tmp.XXXXXX")"
grep -v '^[[:space:]]*status_line[[:space:]]*=[[:space:]]*\["five-hour-limit",[[:space:]]*"weekly-limit",[[:space:]]*"last-tokens"\][[:space:]]*$' "$config_path" > "$tmp_path" || true
chmod 600 "$tmp_path"
mv -f "$tmp_path" "$config_path"
tmp_path=""
trap - EXIT HUP INT TERM

printf 'Removed Codex limit status line from %s\n' "$config_path"
printf 'Restart Codex to apply the change.\n'
