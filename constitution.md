# ADLC Project Constitution

> Spec-Kit project constitution for the Orix ADLC pipeline. This is the
> top-level law every agent run is bound by. Steering files in `steering/`
> and the deny hook in `hooks/` operationalise it. `CLAUDE.md` defers here.

## Purpose

Turn business intent into a reviewed pull request — never a direct merge.
Every generated change is scoped, tested, audited, and human-approved before
it can reach `main`.

## Non-negotiable security

- No hardcoded secrets, keys, tokens, or passwords in any file or command.
- No logging of PII, tokens, or passwords.
- No `eval()` in JavaScript / TypeScript.
- Parameterised queries only — never string-concatenated SQL.
- Input validation on every external boundary.
- These are enforced deterministically by `hooks/pretooluse-deny.sh`, not by
  model judgement.

## No direct merge to main

- Agents are read-only by default; every write is a permission-scoped safe output.
- No agent may push or merge to `main`/`master`, or run `gh pr merge`.
- A pull request becomes merge-eligible only after required checks pass, at
  least one CODEOWNERS review, and the `adlc/business-approval` gate is green.
- A human performs the merge. Nothing auto-merges.

## Deterministic enforcement

- A `PreToolUse` deny hook blocks, before execution and regardless of
  permission mode: writes outside the assigned `workspaces/<slug>/`, any write
  to `.github/` or root config, push/merge to protected branches, secret-like
  literals, and dangerous shell commands.
- The hook fails closed: if it cannot evaluate a call, it denies.

## Scope discipline

- Work stays inside the assigned `workspaces/<slug>/`.
- Smallest change that satisfies the spec; no unrelated refactors, no new
  dependencies unless the spec requires them.
- Surface assumptions and ambiguity before implementing.

## Audit trail

- Every feature commits `spec.md`, `plan.md`, and `tasks.md` as a portable,
  git-tracked record of intent → design → tasks.
- The governance reviewer writes a signed audit-log entry per agent action.

## Definition of done

A change is done only when ALL hold:
- Tests written first (TDD), and passing; new-code coverage ≥ 80% lines.
- `npm run ci` (typecheck + lint + tests+coverage) is green.
- No banned packages, no secrets, no TODO comments, no `any` without justification.
- A PR is open to `main` (never auto-merged) with spec/plan/tasks committed.
- Business user has approved via the `adlc/business-approval` gate.
