#!/bin/sh
set -eu

status_line='status_line = ["five-hour-limit", "weekly-limit"]'
codex_home="${CODEX_HOME:-$HOME/.codex}"
config_path="$codex_home/config.toml"

mkdir -p "$codex_home"

if [ -f "$config_path" ]; then
  timestamp="$(date +%Y%m%d-%H%M%S)"
  cp "$config_path" "$config_path.backup-$timestamp"
else
  : > "$config_path"
fi

tmp_path="$config_path.tmp.$$"

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
' "$config_path" > "$tmp_path"

mv "$tmp_path" "$config_path"

printf 'Updated %s\n' "$config_path"
printf 'Restart Codex to see: 5h limit and weekly limit in the footer.\n'
