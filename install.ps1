<#
.SYNOPSIS
  Installs claude-statusline on Windows.

.DESCRIPTION
  Windows companion to install.sh. Copies statusline-command.sh into ~/.claude,
  normalises it to LF line endings, and registers it in ~/.claude/settings.json.

  Two Windows-specific details this handles for you:
    * The command path is written with forward slashes ("~/.claude/...").
      Claude Code runs status line commands through Git Bash on Windows, and
      Git Bash silently eats backslashes in an unquoted path — a "\" path makes
      the status line fail with no visible error.
    * The status line is the bash script itself (no "pwsh"/"powershell" wrapper),
      so no extra console window flashes on every refresh.

.PARAMETER RepoRaw
  Base raw URL to download statusline-command.sh from when it is not found next
  to this script (e.g. when run via `irm ... | iex`). Defaults to this fork.

.PARAMETER ClaudeDir
  Target Claude config directory. Defaults to ~/.claude. Override only if your
  Claude Code config lives elsewhere.

.EXAMPLE
  # From a local clone:
  powershell -ExecutionPolicy Bypass -File .\install.ps1

.EXAMPLE
  # One-liner (no clone):
  irm https://raw.githubusercontent.com/soo-rich/claude-statusline/main/install.ps1 | iex
#>
[CmdletBinding()]
param(
  [string]$RepoRaw = "https://raw.githubusercontent.com/soo-rich/claude-statusline/main",
  [string]$ClaudeDir = (Join-Path $HOME ".claude")
)

$ErrorActionPreference = "Stop"

# Windows PowerShell 5.1 negotiates TLS 1.0 by default; GitHub requires 1.2+.
try { [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12 } catch {}

$ScriptName = "statusline-command.sh"
$Target     = Join-Path $ClaudeDir $ScriptName
$Settings   = Join-Path $ClaudeDir "settings.json"
# Forward slashes on purpose — see .DESCRIPTION.
$Command    = "~/.claude/$ScriptName"

function Write-Ok   ($m) { Write-Host "OK  $m" -ForegroundColor Green }
function Write-Info ($m) { Write-Host "->  $m" -ForegroundColor Cyan }
function Write-Warn2($m) { Write-Host "!   $m" -ForegroundColor Yellow }

Write-Info "Installing claude-statusline (Windows)..."

# 0. Prerequisite checks (warn only — install still proceeds).
$gitBash = @(
  "$env:ProgramFiles\Git\bin\bash.exe",
  "${env:ProgramFiles(x86)}\Git\bin\bash.exe"
) | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1
if (-not $gitBash) {
  Write-Warn2 "Git Bash not found. Claude Code needs Git Bash to run a .sh status line on Windows."
  Write-Warn2 "Install Git for Windows: https://git-scm.com/download/win"
}
if (-not (Get-Command python3 -ErrorAction SilentlyContinue)) {
  Write-Warn2 "python3 not found on PATH. The script parses JSON with python3."
}
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
  Write-Warn2 "git not found on PATH. The branch segment will be empty without it."
}

# 1. Ensure ~/.claude exists.
if (-not (Test-Path $ClaudeDir)) { New-Item -ItemType Directory -Path $ClaudeDir -Force | Out-Null }

# 2. Obtain the script (prefer the local copy next to this installer).
$localScript = if ($PSScriptRoot) { Join-Path $PSScriptRoot $ScriptName } else { $null }
if ($localScript -and (Test-Path $localScript)) {
  # ReadAllText auto-detects BOM and defaults to UTF-8 on every PowerShell version.
  # (Get-Content -Raw uses the ANSI codepage on Windows PowerShell 5.1 and would
  # corrupt the box-drawing characters in the bar.)
  $content = [System.IO.File]::ReadAllText($localScript)
  Write-Info "Using local $ScriptName"
} else {
  Write-Info "Downloading $ScriptName from $RepoRaw"
  $content = (Invoke-WebRequest -UseBasicParsing -Uri "$RepoRaw/$ScriptName").Content
}

# 3. Write with LF endings and no BOM (CRLF or a BOM break bash).
$content = $content -replace "`r`n", "`n" -replace "`r", "`n"
[System.IO.File]::WriteAllText($Target, $content, (New-Object System.Text.UTF8Encoding($false)))
Write-Ok "Script -> $Target"

# 4. Patch settings.json (back up first; preserve existing keys).
if (Test-Path $Settings) {
  try {
    $json = [System.IO.File]::ReadAllText($Settings) | ConvertFrom-Json
  } catch {
    Write-Host "X   settings.json is invalid JSON - fix it manually then re-run." -ForegroundColor Red
    exit 1
  }
  Copy-Item -Path $Settings -Destination "$Settings.bak" -Force
} else {
  $json = [pscustomobject]@{}
}

$statusLine = [pscustomobject]@{ type = "command"; command = $Command }
$json | Add-Member -NotePropertyName "statusLine" -NotePropertyValue $statusLine -Force

$out = $json | ConvertTo-Json -Depth 100
[System.IO.File]::WriteAllText($Settings, $out + "`n", (New-Object System.Text.UTF8Encoding($false)))
if (Test-Path "$Settings.bak") {
  Write-Ok "settings.json updated (backup -> settings.json.bak)"
} else {
  Write-Ok "settings.json created"
}

Write-Host ""
Write-Host "Done. Trigger an interaction (or restart Claude Code) to see your status line." -ForegroundColor Green
