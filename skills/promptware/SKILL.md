---
description: Scaffold a new Promptware module — a self-evolving agentic application with firmware, program, memory, tools, and reflection.
argument: "Name and purpose of the new promptware module (e.g. 'MeetingPrep - OSINT meeting participants and email me a brief')"
---

# Create a new Promptware module

You are scaffolding a new Promptware module. Promptware is a pattern for self-evolving agentic applications where prompts are treated like software — they ship, learn, and improve over time.

## Architecture

Every module consists of:

```
.shared/              -- Shared across all modules (already exists)
  Firmware.md         -- Fixed bootstrap prompt (never changes)
  Feedback.md         -- Feedback processing instructions
  Utils.ps1           -- PowerShell utilities (launcher helpers)

<ModuleName>/         -- The module's program folder
  Program.md          -- The "source code" — evolving instructions
  Memory/             -- Persistent knowledge across sessions (starts empty)
  Tools/              -- Scripts the agent creates for itself (starts empty)
  Logs/               -- Execution history (auto-created at runtime)

<ModuleName>.ps1      -- Thin launcher script
```

## Steps

1. **Parse the argument** to extract the module name and purpose. The name should be PascalCase (e.g. `MeetingPrep`, `ReviewCode`, `SyncDocs`).

2. **Check if `.shared/` exists** in the current working directory. If it does, reuse it. If not, create it with the standard Firmware.md, Feedback.md, and Utils.ps1 from the reference implementation below.

3. **Create the launcher script** `<ModuleName>.ps1`:

```powershell
. "$PSScriptRoot\.shared\Utils.ps1"

$programFolder = GetProgramFolder $PSCommandPath

$args = CollectArgs $args -Optional

$logFile = GetNextLogFile $programFolder

$promptFile = PrepareFirmware $PSScriptRoot $logFile $programFolder @{ Args = $args; WorkDir = (Get-Location).Path }

InvokeOrOutputPrompt $programFolder $promptFile $args $logFile
```

4. **Create the program folder** `<ModuleName>/` with:
   - `Program.md` — Write clear, step-by-step instructions for the agent based on the stated purpose. Be specific but leave room for the agent to improve over time. Include sections for Context, Execution Steps, and Output format.
   - `Memory/` — Create the directory (empty, agents populate this themselves)
   - `Tools/` — Create the directory (empty, agents create tools as needed)

5. **Do NOT create Logs/** — it gets auto-created at runtime by `GetNextLogFile`.

6. **Present the result** — Show the user what was created and how to run it:
   - `.\<ModuleName>.ps1 <args>` to run
   - `.\<ModuleName>.ps1 -Feedback "<feedback>"` to improve it

## Reference: .shared files

### Firmware.md
```markdown
---
[HEADER]
---
You are an agentic application that evolves over time.

This prompt is your Firmware and is never allowed to change.

In the header above your arguments is specified.

Your program folder is: [PROGRAMFOLDER]

## Logs

In [PROGRAMFOLDER]\Logs/ we maintain logs for all executions of this application.

A file for this session has already been created: [LOGFILE]

It currently only have the args written to it.

In the log file you are to maintain a record:

- The outcome of the execution
- Any tools created or changed
- Any memory created or changed
- And changes to the program during reflection

## Feedback

If Args contains the -Feedback flag then execute the instructions in [SHAREDFOLDER]\Feedback.md.

IMPORTANT! If YES stop following these instructions here.

## Goal

You are to execute the instructions in [PROGRAMFOLDER]\Program.md

Your goal is to complete these instructions with the following priority:

1. Completeness
2. Speed
3. Token efficiency
4. Improvement over time

To complete your task you have powershell tools stored in [PROGRAMFOLDER]\Tools/. You are urged to create and maintain reusable tools to better achieve your goals during this session and over time.

You can store memory in [PROGRAMFOLDER]\Memory/ as markdown files.

Always start with:

- Read [PROGRAMFOLDER]\Program.md
- List tools in [PROGRAMFOLDER]\Tools/
- List memory in [PROGRAMFOLDER]\Memory/

Complete you task and present the user with a summary.

## Reflection

Every execution needs to end with a reflection step. This is your opportunity to improve over time. What did we learn during this session. Save this in an applicable markdown file under [PROGRAMFOLDER]\Memory/. Create new tools if applicable. Add instructions to [PROGRAMFOLDER]\Program.md.

- Note that learnings might be falsified over time. Pruning memory is just as important as storing new memory.
- Many sessions don't have any new learnings. Only store memory when you need it.
```

### Feedback.md
```markdown
Based on the Feedback from the user improve:

Program.md
/Tools/
/Memory/

Don't forget to log your changes.

If user did give any Feedback after the -Feedback flag then stop.

If user mentions a number like 0001 - this refers to a log file under /Logs/ - Read that!
```

### Utils.ps1
```powershell
$claudeDir = Join-Path $env:USERPROFILE ".local\bin"
if (Test-Path $claudeDir) {
    if ($env:PATH -notlike "*$claudeDir*") {
        $env:PATH = "$claudeDir;$env:PATH"
    }
}

function GetProgramFolder {
    param([string]$ScriptPath)
    $scriptName = [System.IO.Path]::GetFileNameWithoutExtension($ScriptPath)
    $scriptFolder = Join-Path (Split-Path $ScriptPath) $scriptName
    if (-not (Test-Path $scriptFolder)) {
        New-Item -ItemType Directory -Path $scriptFolder | Out-Null
    }
    return $scriptFolder
}

function GetNextLogFile {
    param([string]$ProgramFolder)
    $logsFolder = Join-Path $ProgramFolder "Logs"
    if (-not (Test-Path $logsFolder)) {
        New-Item -ItemType Directory -Path $logsFolder | Out-Null
    }
    $existing = Get-ChildItem -Path $logsFolder -Filter "*.md" -File |
        Where-Object { $_.BaseName -match '^\d+$' } |
        ForEach-Object { [int]$_.BaseName } |
        Sort-Object -Descending |
        Select-Object -First 1
    $next = if ($existing) { $existing + 1 } else { 1 }
    return Join-Path $logsFolder ("{0:D5}.md" -f $next)
}

function PrepareFirmware {
    param(
        [string]$ScriptRoot,
        [string]$LogFile,
        [string]$ProgramFolder,
        [hashtable]$Values = @{}
    )
    $header = ($Values.GetEnumerator() | Sort-Object Name | ForEach-Object { "$($_.Key): $($_.Value)" }) -join "`n"
    $sharedFolder = Join-Path $ScriptRoot ".shared"
    $firmware = Get-Content "$sharedFolder\Firmware.md" -Raw
    $firmware = $firmware.Replace("[HEADER]", $header)
    $firmware = $firmware.Replace("[LOGFILE]", $LogFile)
    $firmware = $firmware.Replace("[PROGRAMFOLDER]", $ProgramFolder)
    $firmware = $firmware.Replace("[SHAREDFOLDER]", $sharedFolder)
    $promptFile = [System.IO.Path]::GetTempFileName()
    Set-Content -Path $promptFile -Value $firmware -NoNewline
    return $promptFile
}

function InvokeOrOutputPrompt {
    param(
        [string]$ProgramFolder,
        [string]$PromptFile,
        [string]$Prompt,
        [string]$LogFile,
        [string[]]$ExtraClaudeArgs = @()
    )
    Write-Host "Log file: $LogFile"
    Write-Host "Starting Agent..."
    Push-Location $ProgramFolder
    $firmware = Get-Content $PromptFile -Raw
    Remove-Item $PromptFile
    claude --dangerously-skip-permissions @ExtraClaudeArgs -- $firmware
    Pop-Location
}

function CollectArgs {
    param(
        [string[]]$Arguments,
        [switch]$Optional
    )
    $Arguments = $Arguments | Where-Object { $_ -ne $null -and $_.Trim() -ne "" }
    $joined = ($Arguments -join " ").Trim()
    if ($joined -eq "" -and $Optional) { return "(No Args)" }
    if ($joined -eq "") {
        $tempFile = [System.IO.Path]::GetTempFileName()
        Write-Host "No arguments provided. Opening Notepad - save the file and close it to continue."
        Start-Process -FilePath "notepad.exe" -ArgumentList $tempFile -Wait
        $joined = ((Get-Content $tempFile) -join " ").Trim()
        Remove-Item $tempFile
    }
    if ($joined -eq "") { Write-Host "No arguments provided. Exiting."; exit }
    return $joined
}
```
