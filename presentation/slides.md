---
theme: excali-slide
title: Promptware
info: |
  Promptware — Software made of prompts.
  A lightning talk about self-evolving agentic modules.
class: text-center
drawings:
  persist: false
transition: slide-left
---

# Promptware

Software made of prompts

by Niels Bosma (niels@ivy.app)

<div class="abs-br m-6 text-sm opacity-50">
Lightning Talk
</div>

---
layout: center
---

# How can I make self-improving software?

<div class="mt-4 text-lg opacity-60">
The result of a sleepless night.
</div>

<v-click>

<div class="mt-8 text-base opacity-50">
Not necessarily agentic — but often agentic.
</div>

</v-click>

---
layout: center
---

# The Problem

<v-clicks>

You write an agent prompt...

It works **okay**...

But it never gets **better**.

Every session starts from zero.

</v-clicks>

---

# What if prompts were more like software?

<v-clicks>

Software has **source code** that evolves over time

Software has **memory** — databases, config, state

Software has determinisitic **tools** — libraries, utilities, scripts

Software has **logs** — observability, audit trails

</v-clicks>

<v-click>

<div class="mt-8 text-2xl font-bold text-center">
What if your agent prompts had all of that?
</div>

</v-click>

---

# Promptware: The Anatomy

Every agentic module follows the same structure:

```
MyAgent/
  Program.md    -- The "source code" (evolves over time)
  Memory/       -- Persistent knowledge across sessions
  Tools/        -- Scripts the agent creates for itself
  Logs/         -- Execution history
```

<v-click>

Plus a shared **Firmware** layer — a template prompt injected into every agent that bootstraps the whole thing.

</v-click>

<v-click>

```
Launcher.ps1  -->  Firmware.md  -->  Program.md  -->  Do the work  -->  Reflect
     ^                                                                     |
     |_____________________________________________________________________|
                              next run is better
```

Powered by **Claude Code** in yolo mode (`--dangerously-skip-permissions`)

</v-click>

---

# Firmware: The Bootstrap

The firmware is a **fixed template** that every agent receives. It tells the agent:

<v-clicks>

1. **Read** your `Program.md` — your instructions
2. **List** your tools and memory — your accumulated knowledge
3. **Execute** the task
4. **Reflect** — update Program.md, Memory, or Tools

</v-clicks>

<v-click>

<div class="mt-6 p-4 bg-green-500 bg-opacity-10 rounded-lg">

The firmware **never changes**. It's the bootloader.

The Program.md **changes over time**. It's the evolving intelligence.

</div>

</v-click>

---

# The Reflection Loop

At the end of **every** execution, the agent asks itself:

<v-clicks>

- Should I add new instructions to `Program.md`?
- Did I learn something worth saving to `Memory/`?
- Should I create a reusable `Tool` for next time? 
- Is any of my existing knowledge outdated?

</v-clicks>

---

# How I use this at my work on Ivy

I run ~20 promptware's built on this pattern as part of our general harness engineering system:

<div class="grid grid-cols-2 gap-4 mt-4">

<div>

**Plan lifecycle**
- MakePlan
- UpdatePlan
- ExpandPlan
- BuildPlan
- TestPlan

</div>

<div>

**Git & review**
- CreateCommit
- CreatePullRequest
- MakePRs
- Sync

</div>

</div>

<v-click>

<div class="mt-6 p-4 bg-blue-500 bg-opacity-10 rounded-lg">

Each one started as a simple <code>Program.md</code>.

Each one is now full of learned patterns, self-made tools, and accumulated memory with reference to my specific systems.

</div>

</v-click>

---

# Example: Meeting Prep Agent

<img src="/example-meeting.png" class="mx-auto h-96 rounded shadow-lg" />

---
layout: center
class: text-center
---

# Promptware

Firmware + Program + Memory + Tools + Reflection

<img src="/qr.png" class="mx-auto mt-6 w-40" />

<div class="mt-2 text-sm opacity-50">
github.com/nielsbosma/Promptware
</div>
