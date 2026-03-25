# Promptware

[View the presentation (PDF)](./presentation/slides.pdf)

**Software made of prompts.**

Born from a sleepless night around one question: *How can I make self-improving software?*

Not necessarily agentic — but often agentic. These days you never know if you're doing something unique or if everyone else is doing the same thing. So here it is.

## The Problem

You write an agent prompt. It works okay. But it never gets **better**. Every session starts from zero.

## What if prompts were more like software?

Software has **source code** that evolves over time. Software has **memory** — databases, config, state. Software creates **tools** — libraries, utilities, scripts. Software has **logs** — observability, audit trails.

What if your agent prompts had all of that?

## The Anatomy of a Promptware Module

Every module follows the same structure:

```
MyAgent/
  Program.md    -- The "source code" (evolves over time)
  Memory/       -- Persistent knowledge across sessions
  Tools/        -- Scripts the agent creates for itself
  Logs/         -- Execution history
```

Plus a shared **Firmware** layer — a fixed template prompt injected into every agent that bootstraps the whole thing.

```
Launcher.ps1  -->  Firmware.md  -->  Program.md  -->  Do the work  -->  Reflect
     ^                                                                     |
     |_____________________________________________________________________|
                              next run is better
```

## Firmware: The Bootstrap

The firmware is a fixed template that every agent receives. It tells the agent:

1. **Read** your `Program.md` — your instructions
2. **List** your tools and memory — your accumulated knowledge
3. **Execute** the task
4. **Reflect** — update Program.md, Memory, or Tools

The firmware **never changes**. It's the bootloader. The `Program.md` **changes over time**. It's the evolving intelligence.

## The Reflection Loop

At the end of every execution, the agent asks itself:

- Should I add new instructions to `Program.md`?
- Did I learn something worth saving to `Memory/`?
- Should I create a reusable `Tool` for next time?
- Is any of my existing knowledge outdated?

**Run 1:** The agent follows basic instructions.
**Run 10:** It has created its own checklist templates.
**Run 50:** It has a library of tools and project-specific patterns.

## Why PowerShell?

PowerShell is cross-platform — but really, use whatever you want. The pattern is script-agnostic. You need:

1. A thin launcher script
2. A firmware template
3. A folder with `Program.md`

That's it.

## How It Runs

Each agent is launched via [Claude Code](https://docs.anthropic.com/en/docs/claude-code) in yolo mode (`--dangerously-skip-permissions`), giving it full autonomy to read, write, and execute. The firmware prompt is passed directly to `claude` as a one-shot instruction — no framework, no SDK, just a CLI call.

## Install

Clone the repo and run the install script to add the `/promptware` skill to Claude Code:

```powershell
git clone https://github.com/nielsbosma/Promptware.git
cd Promptware
.\install.ps1
```

Then in any Claude Code session, use `/promptware` to scaffold a new module:

```
/promptware MeetingPrep - OSINT meeting participants and email me a brief
```

## Reference Implementation

See the [`/reference`](./reference/) directory for a minimal working example — a `CreateCommit` agent stripped down to just the essentials (no accumulated logs, memory, or tools).

## Presentation

The [`/presentation`](./presentation/) directory contains a [Slidev](https://sli.dev) lightning talk about Promptware.

```bash
cd presentation
npm install
npm run dev
```
