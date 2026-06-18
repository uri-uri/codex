# Codex Limit Statusline

Show Codex rate-limit remaining status and latest turn token usage in the
Codex CLI TUI footer.

[日本語README](README.ja.md)

This config-only installer adds:

```toml
[tui]
status_line = ["five-hour-limit", "weekly-limit", "last-tokens"]
```

After installing, restart Codex.

## Install

The commands below download from an immutable commit and verify SHA-256 before
execution. Do not replace the commit with a branch name.

### Windows PowerShell

```powershell
$commit = "feb60a08df50202f42fbf6a7dfa4c3217e20f2e0"
$expected = "480945b92dacc036d13c45febdd0ef18095ebc62d191cf1a67bbf309b2584c3d"
$url = "https://raw.githubusercontent.com/uri-uri/codex/$commit/install.ps1"
$file = Join-Path $env:TEMP "codex-limit-statusline-install.ps1"

try {
  Invoke-WebRequest $url -OutFile $file
  $actual = (Get-FileHash -Algorithm SHA256 -LiteralPath $file).Hash.ToLowerInvariant()
  if ($actual -ne $expected) { throw "SHA-256 verification failed" }
  powershell -NoProfile -ExecutionPolicy Bypass -File $file
} finally {
  Remove-Item -LiteralPath $file -Force -ErrorAction SilentlyContinue
}
```

### macOS / Linux

```sh
commit="feb60a08df50202f42fbf6a7dfa4c3217e20f2e0"
expected="e7af80460a58cad5ccbfb68b4938a34b4b770573fbee67d03a8d2f088dc97670"
url="https://raw.githubusercontent.com/uri-uri/codex/$commit/install.sh"
file="$(mktemp "${TMPDIR:-/tmp}/codex-limit-statusline-install.XXXXXX")"

curl -fsSL "$url" -o "$file"
if command -v sha256sum >/dev/null 2>&1; then
  actual="$(sha256sum "$file" | awk '{print $1}')"
else
  actual="$(shasum -a 256 "$file" | awk '{print $1}')"
fi
[ "$actual" = "$expected" ] || { rm -f "$file"; echo "SHA-256 verification failed" >&2; exit 1; }
sh "$file"
rm -f "$file"
```

## What It Changes

- Creates `~/.codex/config.toml` if it does not exist.
- Adds or updates `[tui].status_line`.
- Creates a unique timestamped backup before replacing an existing config.
- Uses an atomic same-directory replacement.
- Rejects a symbolic-link or reparse-point `config.toml`.
- Writes Unix configs and backups with mode `600`.
- Cleans up temporary files on failure.
- Does not read or modify Codex auth files.
- Does not install packages or replace the Codex binary.
- Makes no network requests after the downloaded script starts.

## Uninstall

### Windows PowerShell

```powershell
$commit = "feb60a08df50202f42fbf6a7dfa4c3217e20f2e0"
$expected = "8aec301aa42cc7fdfaa55d6bd3d554e39e06c633f6571f47c92beeb15eaa8bf1"
$url = "https://raw.githubusercontent.com/uri-uri/codex/$commit/uninstall.ps1"
$file = Join-Path $env:TEMP "codex-limit-statusline-uninstall.ps1"

try {
  Invoke-WebRequest $url -OutFile $file
  $actual = (Get-FileHash -Algorithm SHA256 -LiteralPath $file).Hash.ToLowerInvariant()
  if ($actual -ne $expected) { throw "SHA-256 verification failed" }
  powershell -NoProfile -ExecutionPolicy Bypass -File $file
} finally {
  Remove-Item -LiteralPath $file -Force -ErrorAction SilentlyContinue
}
```

### macOS / Linux

```sh
commit="feb60a08df50202f42fbf6a7dfa4c3217e20f2e0"
expected="39363f620ddbea3b70cc6d16400aa707087c9f40d0e44d974fc4770ae53768cc"
url="https://raw.githubusercontent.com/uri-uri/codex/$commit/uninstall.sh"
file="$(mktemp "${TMPDIR:-/tmp}/codex-limit-statusline-uninstall.XXXXXX")"

curl -fsSL "$url" -o "$file"
if command -v sha256sum >/dev/null 2>&1; then
  actual="$(sha256sum "$file" | awk '{print $1}')"
else
  actual="$(shasum -a 256 "$file" | awk '{print $1}')"
fi
[ "$actual" = "$expected" ] || { rm -f "$file"; echo "SHA-256 verification failed" >&2; exit 1; }
sh "$file"
rm -f "$file"
```

The uninstall script removes this exact status-line setting. Restore a
timestamped backup if you need a previous custom status line.

## Display example

```text
5h 99% left
weekly 61% left
last 1.45K
```

## Notes

Color warnings and reset times require a modified Codex TUI. The
`feature/status-line-rate-limit-alerts` branch is experimental, based on an
older OpenAI Codex revision, and is not a maintained binary distribution.

See [SECURITY.md](SECURITY.md) for the security policy and private reporting
instructions.
