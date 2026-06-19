# ADLC AI Development Instructions
# Orix Corporation USA | Multi-stack (Angular, React, .NET/C#, Java/Spring Boot)
# Pipeline: GitHub issue → Claude Code (Microsoft Foundry) → PR
# Baseline: Orix grounded-ai-dev-export (Angular + C#) + ADLC industry defaults (React + Java)

## Purpose
This file gives Claude Code shared project context, coding standards, and workflow guidance for the Orix ADLC pipeline.
Keep this file concise. Detailed framework rules live under `ai-dev/`.

## Role and context
You are an AI coding agent in the Orix ADLC pipeline.
Your job: receive a feature request → generate compliant code → open a PR.

Repos:
- `adlc-dev`       → write code here
- `adlc-stage`     → open PRs here (never push to main directly)
- `adlc-standards` → this file lives here; the workflow clones it before every agent run

## Governance — single source of truth

This file **defers to** the project constitution and steering set. Do not
duplicate rules here; read and follow:

- `constitution.md` — security, no-direct-merge, deterministic enforcement,
  audit trail, definition of done.
- `steering/AGENTS.md` — agent role and operating rules.
- `steering/approved-stack.md` — the approved stack (React+TS+Vite+Vitest).
- `steering/compliance-rules.md` — what the governance reviewer checks.

Deterministic enforcement is implemented by `hooks/pretooluse-deny.sh`.

## Project context (multi-stack)
The ADLC pipeline targets four stacks. Pick the right rule set per file type — do not mix.
- Angular (frontend)
- React (frontend)
- .NET / C# (backend)
- Java / Spring Boot (backend)

## Routing (apply by file type)

### Angular files (`.ts`, `.html`, `.css`, `.scss` in an Angular project)
Apply:
- `ai-dev/rules/angular/style.md`
- `ai-dev/validation/angular-validation.md`

### React files (`.tsx`, `.jsx`, React-flavored `.ts` / `.js`)
Apply:
- `ai-dev/rules/react/style.md`
- `ai-dev/validation/react-validation.md`

### C# / .NET files (`.cs`)
Apply:
- `ai-dev/rules/dotnet/style.md`
- `ai-dev/validation/dotnet-validation.md`

### Java / Spring Boot files (`.java`)
Apply:
- `ai-dev/rules/java/style.md`
- `ai-dev/validation/java-validation.md`

## Global rules (always apply)
- `ai-dev/rules/global/instruction-architecture.md`
- `ai-dev/rules/global/behavior.md`

## Slash commands (ADLC pipeline workflows)
Full definitions in `ai-dev/workflows/`. Brief reference:
- `/generate-feature <description>` — spec + code + tests. See `ai-dev/workflows/generate-feature.md`
- `/refactor-to-standards` — list violations, fix in batches. See `ai-dev/workflows/refactor-to-standards.md`
- `/create-pr <title>` — commit, push, open PR. See `ai-dev/workflows/create-pr.md`
- `/validate-output` — run compile + lint + tests. See `ai-dev/workflows/validate-output.md`
- `/iterate <pr-number> <feedback>` — apply PR review feedback. See `ai-dev/workflows/iterate.md`

## Commands
Use the target project repository's real commands from `package.json`, `*.sln`, `*.csproj`, `pom.xml`, and workflow files.
TODO: add exact build, test, lint, and format commands once a target project repo is wired in.

## Boundaries
- Do not invent commands, paths, or architecture details that are not in the repo.
- Do not mix Angular rules into React changes (or vice versa), or .NET rules into Java changes (or vice versa).
- Do not add new dependencies unless requested.
- Do not refactor unrelated code unless requested.

## Stop and ask a human when
- Requirement is still ambiguous after 2 clarification rounds.
- A dependency outside the approved list is genuinely needed.
- Any security decision is required (auth, encryption, permissions).
- Generated code would modify shared infrastructure.
- Tests fail and the fix is not clear within 2 iterations.
- Validation fails 3 times in a row on the same issue.

## Completion
Before returning work:
- confirm the output follows the relevant language rules
- confirm the change stays within scope
- confirm repo-specific validation steps were run, if defined
