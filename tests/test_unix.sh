#!/bin/sh
set -eu

repo_dir="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
test_root="$(mktemp -d)"

cleanup() {
  rm -rf "$test_root"
}

trap cleanup EXIT HUP INT TERM

case "$(uname -s)" in
  MINGW* | MSYS* | CYGWIN*)
    supports_posix_security=false
    ;;
  *)
    supports_posix_security=true
    ;;
esac

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

assert_mode_600() {
  if [ "$supports_posix_security" != "true" ]; then
    return
  fi
  mode="$(stat -c '%a' "$1")"
  [ "$mode" = "600" ] || fail "$1 mode was $mode, expected 600"
}

codex_home="$test_root/codex-home"
mkdir -p "$codex_home"
cat > "$codex_home/config.toml" <<'EOF'
model = "test-model"

[tui]
status_line = ["model"]

[mcp_servers.example]
token_env_var = "PRIVATE_TOKEN"
EOF
printf '{"token":"do-not-touch"}\n' > "$codex_home/auth.json"
chmod 644 "$codex_home/config.toml"
auth_before="$(sha256sum "$codex_home/auth.json" | awk '{print $1}')"

CODEX_HOME="$codex_home" sh "$repo_dir/install.sh"

grep -Fq 'status_line = ["five-hour-limit", "weekly-limit", "last-tokens"]' "$codex_home/config.toml" ||
  fail "status line was not installed"
[ "$(grep -Fc 'status_line =' "$codex_home/config.toml")" -eq 1 ] ||
  fail "status line was duplicated"
grep -Fq 'token_env_var = "PRIVATE_TOKEN"' "$codex_home/config.toml" ||
  fail "unrelated config was changed"
assert_mode_600 "$codex_home/config.toml"
[ "$auth_before" = "$(sha256sum "$codex_home/auth.json" | awk '{print $1}')" ] ||
  fail "auth.json was modified"
backup="$(find "$codex_home" -maxdepth 1 -name 'config.toml.backup-*' -print -quit)"
[ -n "$backup" ] || fail "backup was not created"
assert_mode_600 "$backup"
[ -z "$(find "$codex_home" -maxdepth 1 -name '.config.toml.tmp.*' -print -quit)" ] ||
  fail "temporary config file remained"

CODEX_HOME="$codex_home" sh "$repo_dir/install.sh"
[ "$(grep -Fc 'status_line =' "$codex_home/config.toml")" -eq 1 ] ||
  fail "reinstall was not idempotent"

CODEX_HOME="$codex_home" sh "$repo_dir/uninstall.sh"
if grep -Fq 'status_line = ["five-hour-limit", "weekly-limit", "last-tokens"]' "$codex_home/config.toml"; then
  fail "status line was not removed"
fi
grep -Fq 'token_env_var = "PRIVATE_TOKEN"' "$codex_home/config.toml" ||
  fail "uninstall changed unrelated config"
assert_mode_600 "$codex_home/config.toml"
[ "$auth_before" = "$(sha256sum "$codex_home/auth.json" | awk '{print $1}')" ] ||
  fail "uninstall modified auth.json"
[ -z "$(find "$codex_home" -maxdepth 1 -name '.config.toml.tmp.*' -print -quit)" ] ||
  fail "temporary config file remained after uninstall"

if [ "$supports_posix_security" = "true" ]; then
  link_home="$test_root/link-home"
  mkdir -p "$link_home"
  external_config="$test_root/external-config.toml"
  printf 'sentinel = true\n' > "$external_config"
  ln -s "$external_config" "$link_home/config.toml"
  if CODEX_HOME="$link_home" sh "$repo_dir/install.sh" >/dev/null 2>&1; then
    fail "installer accepted a symbolic-link config"
  fi
  [ "$(cat "$external_config")" = "sentinel = true" ] ||
    fail "symbolic-link target was modified"
fi

printf 'Unix installer security tests passed.\n'
