Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$statusLinePattern = '^\s*status_line\s*=\s*\["five-hour-limit",\s*"weekly-limit",\s*"last-tokens"\]\s*$'
$codexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }
$configPath = Join-Path $codexHome "config.toml"
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)

if (-not (Test-Path $configPath)) {
  Write-Host "No config found at $configPath"
  exit 0
}

$configItem = Get-Item -LiteralPath $configPath -Force
if ($configItem.PSIsContainer) {
  throw "Config path is a directory: $configPath"
}
if (($configItem.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
  throw "Refusing to modify symbolic link or reparse point: $configPath"
}

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backupSuffix = [Guid]::NewGuid().ToString("N").Substring(0, 8)
$backupPath = "$configPath.backup-$timestamp-$backupSuffix"

$lines = Get-Content -LiteralPath $configPath
$newLines = $lines | Where-Object { $_ -notmatch $statusLinePattern }
$newContent = ($newLines -join "`n").TrimEnd() + "`n"
$tempPath = Join-Path $codexHome (".config.toml.tmp-" + [Guid]::NewGuid().ToString("N"))

try {
  [System.IO.File]::WriteAllText($tempPath, $newContent, $utf8NoBom)
  [System.IO.File]::Replace($tempPath, $configPath, $backupPath, $true)
} finally {
  if (Test-Path -LiteralPath $tempPath) {
    Remove-Item -LiteralPath $tempPath -Force
  }
}

Write-Host "Removed Codex limit status line from $configPath"
Write-Host "Restart Codex to apply the change."
