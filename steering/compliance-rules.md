# ADLC Compliance Rules

Financial-services compliance rules. The governance reviewer
(`skills/review-agent-governance`) checks every ADLC PR against these.

## What the governance reviewer checks

- **Scope** — changes stay inside the target `workspaces/<slug>/`; no edits to
  workflows, root config, or other workspaces.
- **Security** — no hardcoded secrets/keys/tokens; no `eval`; input validation
  where applicable; no string-concatenated SQL.
- **Approved stack** — React+TS+Vite+Vitest only; no banned packages
  (see `steering/approved-stack.md`).
- **Tests** — tests exist, map to acceptance criteria, are not deleted or
  weakened; coverage ≥ 80% respected.
- **Spec fidelity** — the diff implements `spec.md`/`plan.md`/`tasks.md` and
  nothing out of scope.

## Reviewer posture

- Advisory: surfaces blocking vs advisory findings for the human approver.
- May request changes (feeding the iterate loop). **Never approves, never merges.**
- Never echoes a detected secret value.
