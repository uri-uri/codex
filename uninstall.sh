#!/bin/sh
set -eu

codex_home="${CODEX_HOME:-$HOME/.codex}"
config_path="$codex_home/config.toml"

if [ ! -f "$config_path" ]; then
  printf 'No config found at %s\n' "$config_path"
  exit 0
fi

timestamp="$(date +%Y%m%d-%H%M%S)"
cp "$config_path" "$config_path.backup-$timestamp"

tmp_path="$config_path.tmp.$$"
grep -v '^[[:space:]]*status_line[[:space:]]*=[[:space:]]*\["five-hour-limit",[[:space:]]*"weekly-limit",[[:space:]]*"last-tokens"\][[:space:]]*$' "$config_path" > "$tmp_path" || true
mv "$tmp_path" "$config_path"

printf 'Removed Codex limit status line from %s\n' "$config_path"
printf 'Restart Codex to apply the change.\n'
