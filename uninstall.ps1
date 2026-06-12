$ErrorActionPreference = "Stop"

$statusLinePattern = '^\s*status_line\s*=\s*\["five-hour-limit",\s*"weekly-limit",\s*"last-tokens"\]\s*$'
$codexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }
$configPath = Join-Path $codexHome "config.toml"

if (-not (Test-Path $configPath)) {
  Write-Host "No config found at $configPath"
  exit 0
}

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
Copy-Item -LiteralPath $configPath -Destination "$configPath.backup-$timestamp"

$lines = Get-Content -LiteralPath $configPath
$newLines = $lines | Where-Object { $_ -notmatch $statusLinePattern }
[System.IO.File]::WriteAllText(
  $configPath,
  (($newLines -join "`n").TrimEnd() + "`n"),
  [System.Text.UTF8Encoding]::new($false)
)

Write-Host "Removed Codex limit status line from $configPath"
Write-Host "Restart Codex to apply the change."
