# VENDOR.md — vendored building blocks

This repo (`adlc-standards`) is the **source of truth** for the ADLC pipeline. Every external building block named in `9_ADLC_Solution.md` is **forked-and-owned**: vendored here at a **pinned version**, with **no runtime dependency on upstream**. The scheduled `vendor-sync` bot (PLAN WS1) watches each upstream and opens a reviewable PR when a newer version exists — upgrades are adapted deliberately, never pulled live.

**Last synced:** 2026-06-16 · **Synced by:** Saad Anwar

## Pins

| Block | Upstream | URL | License | Pin (tag / commit) | Vendored at |
|---|---|---|---|---|---|
| spec-kit | `github/spec-kit` | https://github.com/github/spec-kit | MIT | **v0.10.3** (`217730a8cdaa842322035648f226acd5b9573454`) | `vendor/spec-kit/` (full, minus `.git`) |
| gh-aw | `github/gh-aw` | https://github.com/github/gh-aw | MIT | **v0.79.8** (`8b02ab336d100a5746e9f53b8bc2b22878278a6f`) | `vendor/gh-aw/` (curated — see note) + `gh` extension pinned to v0.79.8 |
| grill-me | `mattpocock/skills` | https://github.com/mattpocock/skills | MIT | `694fa30311e02c2639942308513555e61ee84a6f` | `skills/grill-me/` (from `skills/productivity/grill-me/`) |
| handoff | `mattpocock/skills` | https://github.com/mattpocock/skills | MIT | `694fa30311e02c2639942308513555e61ee84a6f` | `skills/handoff/` (from `skills/productivity/handoff/`) |
| tdd-verification | `obra/superpowers` | https://github.com/obra/superpowers | MIT | `8cf39006140a743dce31ba4046fceab90cc214e6` | `skills/tdd-verification/` (from `skills/test-driven-development/` + `skills/verification-before-completion/`) |
| review-agent-governance | — (in-house) | — | Orix ADLC (internal) | n/a | `skills/review-agent-governance/` (authored in WS6; **no upstream**) |

> **No moving `latest`:** every external block is pinned to a concrete tag and/or commit SHA above. The `gh aw` CLI extension is installed with `--pin v0.79.8`. Nothing in the pipeline resolves `@latest` at build or runtime.

## Per-block notes

- **gh-aw (curated, not full source):** the upstream repo is ~323 MB / 5,328 files (Go monorepo; `docs/` alone is a 219 MB Astro site). Vendoring all of it would bloat this repo with no benefit. We vendor the **LICENSE + top-level authoring docs (`README.md`, `SKILL.md`, `create.md`, `install.md`, `package.md`, `DEVGUIDE.md`, `AGENTS.md`, `CHANGELOG.md`) + `schemas/`**. Runtime independence is provided two ways that do **not** need the source: (1) the `gh aw` extension pinned to **v0.79.8** is used only at *author/compile* time; (2) the compiled **`*.lock.yml`** committed in `adlc-dev/.github/workflows/` runs in GitHub Actions with **zero** gh-aw dependency. The full source remains reproducible from the pin above.
- **tdd-verification** = two superpowers skills under one block (see `skills/tdd-verification/README.md`).
- **grill-me + handoff** both come from one MIT repo (`mattpocock/skills`) at the same commit. `mattpocock` is the canonical origin (other `grill-me` repos are forks of it). The differently-licensed `ykdojo/claude-code-tips` handoff (NOASSERTION) was deliberately **not** used.
- **review-agent-governance** has no external upstream; it is authored in-house. The sync-bot skips it.

## How to re-vendor / bump a pin

1. The `vendor-sync` bot opens a PR when an upstream advances past the pin here.
2. To bump by hand: clone the upstream, `git checkout <new-tag-or-sha>`, copy the same paths over the vendored dirs, update the row above (tag + SHA + Last synced), and run the pipeline smoke test before merging.
3. MIT requires the upstream `LICENSE` to travel with the code — each vendored skill folder keeps its upstream `LICENSE`; `vendor/spec-kit/LICENSE` and `vendor/gh-aw/LICENSE` are preserved.
