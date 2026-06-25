# Approved Stack

## Active (MVP truth)

The only approved stack for generated applications:

- **React** + **TypeScript**
- **Vite** (build/dev)
- **Vitest** + Testing Library (tests, coverage ≥ 80% lines)
- **ESLint** (flat config), `tsc --noEmit` (typecheck)

The authoritative, machine-readable **package allow-list** is `approved-packages.json` (this
directory) — it adds the Orix-approved app libraries (`react-router-dom`, `axios`, `zustand`,
`@tanstack/react-query`), installed **on demand** when a spec needs them (controlled installs,
WS8), and is enforced **default-deny** by `adlc-ci`. Detailed React/global coding rules live in
`ai-dev/rules/`.

No database, no external integrations in generated apps (MVP scope).

## Banned

- `moment` (use `Intl`/`date-fns` only if the spec requires dates)
- full `lodash` (import specific functions if genuinely needed)
- any package **not on `approved-packages.json`** (default-deny — `adlc-ci` rejects unlisted deps)

## Future (not active)

Multi-stack support (Angular, .NET/C#, Java/Spring Boot) is documented in
`ai-dev/rules/` for future expansion but is NOT active in the MVP. Generated
apps are React + TypeScript + Vite + Vitest only until this section is promoted.
