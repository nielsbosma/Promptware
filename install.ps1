#!/usr/bin/env pwsh
# Install Promptware skills into Claude Code (requires PowerShell 7+)
$skillsDir = Join-Path $HOME ".claude" "skills"
$source = Join-Path $PSScriptRoot "skills" "promptware"
$target = Join-Path $skillsDir "promptware"

if (Test-Path $target) {
    Write-Host "Promptware skill already installed at $target" -ForegroundColor Yellow
    Write-Host "To reinstall, remove it first: Remove-Item '$target'"
    exit 0
}

if (-not (Test-Path $skillsDir)) {
    New-Item -ItemType Directory -Path $skillsDir | Out-Null
}

New-Item -ItemType SymbolicLink -Path $target -Target $source | Out-Null
Write-Host "Installed! Use /promptware in Claude Code to scaffold a new module." -ForegroundColor Green
