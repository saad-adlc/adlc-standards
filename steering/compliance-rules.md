# Compliance Rules (financial-services governance)

Read by the governance reviewer (`skills/review-agent-governance`) and enforced by the deny hooks (`hooks/`).

## Enforcement posture
- **Read-only by default;** writes only via scoped "safe outputs".
- **No direct merge to `main`** — branch protection + required `adlc/business-approval` check + ≥1 CODEOWNERS review.
- **Deterministic deny** (hooks, not model judgment): no push/merge to `main`; no writes outside `workspaces/<slug>/`; no secrets; no dangerous Bash.
- **Sanitization gates** must be green: CodeQL (SAST) + secret scanning (push protection) + Dependabot (SCA).

## Security — never violate
- No hardcoded secrets/keys/tokens/passwords; none in logs.
- No `eval()` in JS/TS. Parameterised queries only. Validate all inputs.
- No disabled framework security/CORS without written approval.

## Audit trail
- `spec.md` / `plan.md` / `tasks.md` committed per feature.
- Agent actions attributable; the governance review writes a signed log entry. Agents never approve or merge.
