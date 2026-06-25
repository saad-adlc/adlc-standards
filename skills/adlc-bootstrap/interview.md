# Interview → Build Card (step 2)

Goal: get from a plain-language idea to a **small, concrete, testable** feature, with every assumption
made **explicit and approved** — before anything is filed.

## Opening move — their idea first

Open with **their** idea, not yours:
> "What would you like to build? Describe it in your own words — even a rough sentence is fine."

- If they give an idea → grill it (below).
- If they say "make something amazing" / ask for suggestions → **first get one line on their world**
  ("What's your role or domain — what do you spend your day on?"), *then* offer **2–3 ideas anchored to
  that domain**. A finance user gets finance tools, not generic demos. **Never lead with a menu of your own
  ideas before you know their domain** — that wastes the turn on ideas they'll discard.

## Grill — adaptive, one question at a time

Ask **one question at a time**, and **always include your recommended answer** so they can just say "yes".
Only ask where the answer genuinely changes the build — skip anything you can confidently infer. Walk down:

- What is it, in one sentence — who uses it, to do what?
- What's on the screen — inputs, buttons, a table, a visual?
- The exact behaviors **+ edge cases** — empty input, invalid value, nothing selected. Pin concrete numbers/examples.
- The **prefilled starting data**, so the preview isn't empty.
- "Done when…" — the handful of things that must be true.

Stop the moment you can write acceptance criteria a test could check. Don't over-interview a trivial app;
don't under-interview a vague one.

## The Build Card — the mandatory gate

Before filing anything, show **one screen** in plain language and get an explicit **"ship it"**:

```
🧾 Build Card — <feature name>

What it is:      <one sentence>
On the screen:   <inputs / buttons / table / SVG visual>
Key behaviors:   - <behavior, with concrete numbers>
                 - <edge case: empty / invalid / nothing-selected>
Prefilled data:  <the starting data>
Done when:       - <testable criterion 1>
                 - <testable criterion 2>

Assumptions I made (tell me if any are wrong):
  • <assumption 1>
  • <assumption 2>

Stack: React + TypeScript, no new dependencies, any visuals hand-drawn (SVG).
```

- **Every assumption is its own line the user can veto** — never bury an assumption inside prose narration.
  (This is the failure to avoid: filling a wall of text with silent assumptions instead of a clean approve-gate.)
- Pair the Card with the clickable preview (`preview.md`). Iterate the Card **and** the preview together until
  they say "ship it" (or equivalent).
- On "ship it", the Card becomes the issue body **verbatim** (SKILL.md step 4) — no rework, no drift.
