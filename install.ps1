$ErrorActionPreference = "Stop"

$statusLine = 'status_line = ["five-hour-limit", "weekly-limit"]'
$codexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }
$configPath = Join-Path $codexHome "config.toml"

New-Item -ItemType Directory -Force -Path $codexHome | Out-Null

if (Test-Path $configPath) {
  $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
  Copy-Item -LiteralPath $configPath -Destination "$configPath.backup-$timestamp"
  $content = Get-Content -LiteralPath $configPath -Raw
} else {
  $content = ""
}

function Set-CodexStatusLine {
  param([string] $Text)

  $lines = if ($Text.Length -gt 0) { $Text -split "`r?`n", -1 } else { @() }
  $result = New-Object System.Collections.Generic.List[string]
  $inTui = $false
  $sawTui = $false
  $updated = $false

  for ($i = 0; $i -lt $lines.Count; $i++) {
    $line = $lines[$i]
    $isSection = $line -match '^\s*\[[^\]]+\]\s*$'

    if ($isSection -and $inTui -and -not $updated) {
      $result.Add($statusLine)
      $updated = $true
    }

    if ($line -match '^\s*\[tui\]\s*$') {
      $inTui = $true
      $sawTui = $true
      $result.Add($line)
      continue
    }

    if ($isSection -and $line -notmatch '^\s*\[tui\]\s*$') {
      $inTui = $false
    }

    if ($inTui -and $line -match '^\s*status_line\s*=') {
      if (-not $updated) {
        $result.Add($statusLine)
        $updated = $true
      }
      continue
    }

    $result.Add($line)
  }

  if ($sawTui -and -not $updated) {
    $result.Add($statusLine)
  }

  if (-not $sawTui) {
    if ($result.Count -gt 0 -and $result[$result.Count - 1].Trim().Length -gt 0) {
      $result.Add("")
    }
    $result.Add("[tui]")
    $result.Add($statusLine)
  }

  ($result -join "`n").TrimEnd() + "`n"
}

$newContent = Set-CodexStatusLine $content
[System.IO.File]::WriteAllText(
  $configPath,
  $newContent,
  [System.Text.UTF8Encoding]::new($false)
)

Write-Host "Updated $configPath"
Write-Host "Restart Codex to see: 5h limit and weekly limit in the footer."
