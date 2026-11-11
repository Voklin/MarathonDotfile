---
name: marathon-git-handoff
description: >-
  Start or conclude a single scoped MARATHON Tactical development task across
  Antigravity chats while minimizing context usage: inspect git status, execute
  minimal slice changes, verify results, update HANDOFF.md, and optionally
  format a ChatGPT Code Review Handoff report. Do not use for QML coding rules
  (quickshell-expert) or Hyprland diagnostics (hyprland-expert).
---

# MARATHON Tactical Git & Chat Handoff

## Purpose and Activation

**Core Principle**: One small, logically complete vertical slice = one Antigravity chat.

Use this skill at the start or end of a scoped task to isolate context, verify changes honestly, update `HANDOFF.md` (or `docs/HANDOFF.md` if the repository stores handoff files under `docs/`), and optionally prepare a structured GitHub/ChatGPT Code Review Handoff report without starting the next task.

## Mandatory 8-Step Workflow

1. **Read the current task**: Inspect the active user request and existing `HANDOFF.md` / `docs/HANDOFF.md` (and `docs/STATUS.md` if present).
2. **Inspect only task-relevant files**: Open only the exact files needed for the current slice — never load unrelated history or scan the whole repo.
3. **Check Git status**: Run `git status` and inspect recent commits/diff (`git log -n 5 --oneline`) if Git is installed and initialized. If Git is missing or `.git` does not exist, note this explicitly.
4. **Make minimal changes**: Implement strictly the scoped slice; avoid opportunistic refactors outside task boundaries.
5. **Run relevant checks**: Execute only applicable verification commands (`qmllint`, `qml` preview, unit/smoke tests). Never claim unexecuted or Linux-only checks passed; mark them `NOT RUN — <exact reason>`.
6. **Produce a concise summary**: Report factual changes, verification outputs, and blockers briefly.
7. **Update `HANDOFF.md`** (or `docs/HANDOFF.md` if already established in `docs/`): Overwrite/update cleanly using the exact schema below — keep facts tight, no sprawling logs.
8. **Stop cleanly**: End the session immediately after handoff. Do **not** begin the next task or milestone in the same chat.

## Required `HANDOFF.md` Template

```markdown
# Task Handoff

## Objective
<Single scoped goal for this chat>

## Completed
- <Concrete deliverable 1>
- <Concrete deliverable 2>

## Changed Files
- `path/to/file` — <brief purpose>

## Verification
- `<command>` — PASS / FAIL / NOT RUN (<exact reason>)

## Known Issues
- <Open issue or "None">

## Architecture Decisions
- <Concise decision + rationale, or "None">

## Next Task
<Exact next smallest slice and exact files to read first>

## Git Status
- Branch: `<branch or NOT INITIALIZED>`
- Commit: `<sha or NOT COMMITTED>`
- Working tree: `<clean / modified files summary>`
```

## ChatGPT Code Review Handoff Template

Use this format when preparing a PR/commit/diff summary for external review in ChatGPT:

```markdown
# Code Review Handoff

## Repository
`<owner/repo or local path>`

## Branch
`<branch-name>`

## Commit / PR
`<commit SHA or PR link / uncommitted diff>`

## Task
<1-3 sentences describing the scoped objective>

## Files Changed
- `path/to/file` — <what changed>

## Implemented Behavior
- <Key functional/UI/service behavior added or modified>

## Tests Executed
- `<command>` — <exact observed outcome>

## Tests Not Executed
- `<check>` — NOT RUN (<environment/tooling reason, e.g., requires CachyOS>)

## Known Risks
- <Prioritized risks or edge cases to scrutinize (P0-P3)>

## Questions for Review
1. <Specific architecture, QML, Hyprland, or security question>
```

## Strict Prohibitions

- **Do not re-read full project history** when `HANDOFF.md` and current task files suffice.
- **Do not bloat `HANDOFF.md`** with verbose transcripts, raw command dumps, or speculative plans.
- **Keep only verifiable facts**; never fabricate test results or claim "everything works" without proof.
- **Do not re-run checks needlessly** if nothing relevant changed since the last verified pass.
- **Do not create extra planning documents** when the task scope is already defined.
- **Never run `git push`** without explicit user authorization.
- **Never create Git commits automatically** unless explicitly permitted by the user.
- **Never mark a task done without verification**; when verification is impossible (e.g., CachyOS/Hyprland absent on Windows), state the exact blocker.

## Context Optimization

- Read `HANDOFF.md` / `docs/HANDOFF.md` + the 1–5 files belonging to the current slice.
- Stop immediately after writing the handoff so the next chat begins with a fresh context window.

## Definition of Done

- Scoped task changes are minimal and verified with exact command outputs (or explicit `NOT RUN` reasons).
- `HANDOFF.md` (or `docs/HANDOFF.md`) follows the required 8-section template cleanly.
- No unauthorized commits or `git push` executed; next task is clearly queued without being started.

## Brief Report Format

- **Task Status**: completed slice vs remaining blockers.
- **Files & Git**: changed paths + `git status` / commit state.
- **Verification**: exact commands run and `NOT RUN` items.
- **Handoff Target**: updated `HANDOFF.md` path and recommended next chat task.

