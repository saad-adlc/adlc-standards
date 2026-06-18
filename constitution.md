# ADLC Constitution

Authoritative, non-negotiable principles for every ADLC pipeline run. The `steering/` files and the Spec-Kit phases inherit these. **On any conflict, this file wins.**

## Principles

1. **Spec before code.** No implementation without an approved spec/plan/tasks. The spec is the source of truth; code serves it.
2. **Tests first.** Failing tests before implementation (red → green → refactor). Coverage ≥ 80% lines.
3. **Least privilege.** Agents are read-only by default. Every write is an explicit, scoped, gated action.
4. **No direct merge to `main`.** A human approval gate is required before a PR is merge-eligible. Agents never approve or merge.
5. **Deterministic enforcement.** Protected-path, secret, and merge rules are enforced by hooks/CI — never left to model judgment.
6. **Scope discipline.** Changes stay inside the target `workspaces/<slug>/`. No edits to workflows, root config, or other workspaces. Smallest change that satisfies the spec.
7. **Approved stack only.** See `steering/approved-stack.md`. No new dependencies or stacks without sign-off.
8. **Auditability.** Spec/plan/tasks and agent actions are git-tracked. No secrets in code or logs.
9. **Stop and ask.** On ambiguity after 2 clarification rounds, any security decision, or shared-infra changes — stop and escalate.

## Precedence
`constitution.md` > `steering/*` > workflow prompts > model judgment.
