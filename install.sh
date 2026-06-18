#!/bin/sh
set -eu
umask 077

status_line='status_line = ["five-hour-limit", "weekly-limit", "last-tokens"]'
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

mkdir -p "$codex_home"

if [ -f "$config_path" ]; then
  timestamp="$(date +%Y%m%d-%H%M%S)"
  backup_path="$config_path.backup-$timestamp-$$"
  cp "$config_path" "$backup_path"
  chmod 600 "$backup_path"
  source_path="$config_path"
else
  source_path="/dev/null"
fi

tmp_path="$(mktemp "$codex_home/.config.toml.tmp.XXXXXX")"

awk -v status_line="$status_line" '
  BEGIN {
    in_tui = 0
    saw_tui = 0
    updated = 0
  }

  /^[[:space:]]*\[[^]]+\][[:space:]]*$/ {
    if (in_tui && !updated) {
      print status_line
      updated = 1
    }
  }

  /^[[:space:]]*\[tui\][[:space:]]*$/ {
    in_tui = 1
    saw_tui = 1
    print
    next
  }

  /^[[:space:]]*\[[^]]+\][[:space:]]*$/ {
    if ($0 !~ /^[[:space:]]*\[tui\][[:space:]]*$/) {
      in_tui = 0
    }
  }

  in_tui && /^[[:space:]]*status_line[[:space:]]*=/ {
    if (!updated) {
      print status_line
      updated = 1
    }
    next
  }

  { print }

  END {
    if (saw_tui && !updated) {
      print status_line
    }
    if (!saw_tui) {
      print ""
      print "[tui]"
      print status_line
    }
  }
' "$source_path" > "$tmp_path"

chmod 600 "$tmp_path"
mv -f "$tmp_path" "$config_path"
tmp_path=""
trap - EXIT HUP INT TERM

printf 'Updated %s\n' "$config_path"
printf 'Restart Codex to see: 5h limit, weekly limit, and latest token usage in the footer.\n'
