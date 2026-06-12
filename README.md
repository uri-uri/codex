# Codex Limit Statusline

Show Codex rate-limit remaining status in the Codex CLI TUI footer.

[日本語README](README.ja.md)

This is a tiny installer for existing Codex users. It only updates your Codex
config file:

```toml
[tui]
status_line = ["five-hour-limit", "weekly-limit"]
```

After installing, restart Codex.

## Install

### Windows PowerShell

```powershell
$url = "https://raw.githubusercontent.com/uri-uri/codex/codex-limit-statusline/install.ps1"
$file = Join-Path $env:TEMP "codex-limit-statusline-install.ps1"
Invoke-WebRequest $url -OutFile $file
powershell -ExecutionPolicy Bypass -File $file
```

### macOS / Linux

```sh
url="https://raw.githubusercontent.com/uri-uri/codex/codex-limit-statusline/install.sh"
file="${TMPDIR:-/tmp}/codex-limit-statusline-install.sh"
curl -fsSL "$url" -o "$file"
sh "$file"
```

## What It Changes

- Creates `~/.codex/config.toml` if it does not exist.
- Adds or updates `[tui].status_line`.
- Creates a timestamped backup before changing an existing config file.
- Does not read or modify Codex auth files.
- Does not install packages.
- Does not make network requests.
- Does not replace the Codex binary.

## Uninstall

### Windows PowerShell

```powershell
$url = "https://raw.githubusercontent.com/uri-uri/codex/codex-limit-statusline/uninstall.ps1"
$file = Join-Path $env:TEMP "codex-limit-statusline-uninstall.ps1"
Invoke-WebRequest $url -OutFile $file
powershell -ExecutionPolicy Bypass -File $file
```

### macOS / Linux

```sh
url="https://raw.githubusercontent.com/uri-uri/codex/codex-limit-statusline/uninstall.sh"
file="${TMPDIR:-/tmp}/codex-limit-statusline-uninstall.sh"
curl -fsSL "$url" -o "$file"
sh "$file"
```

The uninstall script removes this exact status line setting when present. If you
had a previous custom status line, restore the timestamped backup created during
install.

## Notes

Codex displays these values as remaining quota, for example:

```text
5h 99% left
weekly 61% left
```

Color warnings for low remaining quota require Codex TUI support and cannot be
added safely by a config-only installer.
