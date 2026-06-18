# Approved Stack (MVP)

The ADLC pipeline generates exactly one stack today. Do not introduce others without sign-off.

## Supported
- **React 18 + TypeScript + Vite + Vitest** (frontend only)
- Testing: Vitest + `@testing-library/react`; coverage ≥ 80% lines
- Lint: ESLint (flat config), zero warnings

## MVP boundaries
- **No database / persistence.**
- **No external integrations or network calls** in generated apps.
- Self-contained workspace; no shared `node_modules`.

## Banned
- `moment`, full `lodash` (use `date-fns` / `lodash-es` per-function if truly needed)
- `eval`, hardcoded secrets, disabled security middleware

## Future (documented only — NOT generated today)
Angular, .NET/C#, Java/Spring. Do not claim support for these.
