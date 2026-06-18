Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoDir = Split-Path -Parent $PSScriptRoot
$testRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("codex-statusline-test-" + [Guid]::NewGuid().ToString("N"))
$codexHome = Join-Path $testRoot "codex-home"
$configPath = Join-Path $codexHome "config.toml"
$authPath = Join-Path $codexHome "auth.json"

function Assert-True {
  param(
    [bool] $Condition,
    [string] $Message
  )

  if (-not $Condition) {
    throw $Message
  }
}

try {
  New-Item -ItemType Directory -Force -Path $codexHome | Out-Null
  @'
model = "test-model"

[tui]
status_line = ["model"]

[mcp_servers.example]
token_env_var = "PRIVATE_TOKEN"
'@ | Set-Content -LiteralPath $configPath -Encoding utf8
  '{"token":"do-not-touch"}' | Set-Content -LiteralPath $authPath -Encoding utf8

  $authBefore = (Get-FileHash -Algorithm SHA256 -LiteralPath $authPath).Hash
  $env:CODEX_HOME = $codexHome

  & (Join-Path $repoDir "install.ps1")

  $content = Get-Content -LiteralPath $configPath -Raw
  Assert-True ($content.Contains('status_line = ["five-hour-limit", "weekly-limit", "last-tokens"]')) "Status line was not installed."
  Assert-True (($content | Select-String -Pattern 'status_line\s*=' -AllMatches).Matches.Count -eq 1) "Status line was duplicated."
  Assert-True ($content.Contains('token_env_var = "PRIVATE_TOKEN"')) "Unrelated config was changed."
  Assert-True ($authBefore -eq (Get-FileHash -Algorithm SHA256 -LiteralPath $authPath).Hash) "auth.json was modified."
  Assert-True (@(Get-ChildItem -LiteralPath $codexHome -Filter "config.toml.backup-*").Count -ge 1) "Backup was not created."
  Assert-True (@(Get-ChildItem -LiteralPath $codexHome -Filter ".config.toml.tmp-*").Count -eq 0) "Temporary config file remained."

  & (Join-Path $repoDir "install.ps1")
  $content = Get-Content -LiteralPath $configPath -Raw
  Assert-True (($content | Select-String -Pattern 'status_line\s*=' -AllMatches).Matches.Count -eq 1) "Reinstall was not idempotent."

  & (Join-Path $repoDir "uninstall.ps1")
  $content = Get-Content -LiteralPath $configPath -Raw
  Assert-True (-not $content.Contains('status_line = ["five-hour-limit", "weekly-limit", "last-tokens"]')) "Status line was not removed."
  Assert-True ($content.Contains('token_env_var = "PRIVATE_TOKEN"')) "Uninstall changed unrelated config."
  Assert-True ($authBefore -eq (Get-FileHash -Algorithm SHA256 -LiteralPath $authPath).Hash) "Uninstall modified auth.json."
  Assert-True (@(Get-ChildItem -LiteralPath $codexHome -Filter ".config.toml.tmp-*").Count -eq 0) "Temporary config file remained after uninstall."

  Write-Host "Windows installer security tests passed."
} finally {
  Remove-Item Env:CODEX_HOME -ErrorAction SilentlyContinue
  if (Test-Path -LiteralPath $testRoot) {
    Remove-Item -LiteralPath $testRoot -Recurse -Force
  }
}
