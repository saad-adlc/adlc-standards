# Observe — confirm, narrate, surface the live app (step 5)

The build runs asynchronously on GitHub (~15–20 min). Your job: confirm it actually started, narrate
honestly with whatever you can see, and at the end **hand the user a clickable link to their live,
deployed app.**

## First — probe what this connector can actually see (don't assume)

The transcript's worst failure was *assuming* it couldn't observe the build and giving up — without ever
searching for the tools. So **search the connector's tools** for:
- workflow-run / check-status reads (the Actions API), and
- issue/PR **comment reads** (e.g. list/get issue or PR comments).

Then **promise only what you found**:
- **Run-status + comment-read present** → narrate live (read the status comment each poll).
- **Only one of them** → narrate from what's available; set expectations to match.
- **Neither (issues/PRs only)** → say so plainly: *"It's filed and triggered. I can see when the PR appears,
  but not the live progress — I'll grab your live app link the moment it's posted. Ping me to check in."*

## Confirm it actually started (before you say "building")

- **Re-read the issue and confirm the `adlc-generate` label attached** — the label, not the issue, is the trigger.
- If a run-status tool exists: confirm a run named **ADLC Generate** is running and the legacy
  **ADLC — Generate Feature** shows *skipped* (exactly one generator — never both).
- If **nothing** started, the trigger didn't fire — re-check the repo and the exact label spelling, fix, and
  retry **before narrating anything**. Don't narrate a build that isn't running.

## Narrate — plain business language, one line per real change

Two signals drive liveness: **native GitHub events** (the PR appears, checks run, checks go green — they
arrive on their own) and, **if readable**, the single **status comment** (hidden marker `<!-- adlc-status -->`,
updated in place; relay its plain-English detail, use its stage to spot terminal states).

| What you observe | What you tell the user |
|---|---|
| run going, no PR yet | "Setting up your workspace and writing the app — tests first…" |
| a PR `feature/issue-<N>-<slug>` appears | "Built and packaged — running automated quality checks." |
| status reads `clean` then `deploying` | "Checks passed — publishing your live app…" |
| the 🔍 preview comment appears | **"It's live — here's your app: ‹link›"** (see below) |
| status `iterating` / an `adlc-iterate` label | "Making that change — attempt N of 3…" |
| status `escalated` / `deploy-failed` | stop; "I've hit a limit on this — engineering will take it from here." |

## Surface the live deployed app — the payoff

When the build succeeds, the pipeline **deploys the app to GitHub Pages** and posts the link in a dedicated
**🔍 preview comment** on the PR (pattern: `https://saad-adlc.github.io/adlc-dev/previews/pr-<N>-<slug>/`).
This is the whole point — the moment the user gets to **open and actually play with their deployed app.**

- **Read the link from that 🔍 preview comment and hand it over as a prominent, clickable link.** Make it the
  headline of the message — not a footnote.
- **Never hand-construct the URL.** If you can't read comments, point them to the source instead:
  *"Your live app link is in the latest comment on the PR — open it there."* (A guessed URL 404s if the deploy
  failed or the slug differs — so only ever surface the link the pipeline actually posted.)
- Surface it **once**, on the terminal **preview-deployed** state, then stop the loop.

## Turn budget + handoff

A full build is ~15–20 min, and a single chat turn barely moves the clock. Poll a handful of times, then hand
off a short **status card** (where it is + what's next) and invite "how's it going?" — run the next round then.
Handing off mid-build is normal; don't loop forever saying "still working".

## Changes after the preview

If they want a tweak after seeing the live app, post a PR comment starting with `/adlc-iterate:` describing
the change in plain language, then resume this loop. A spec-level rethink starts a **new** issue (step 2).
