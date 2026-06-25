# Preview — a clickable HTML wireframe (step 3)

Give the business user something they can **see and click right in the chat**, before a single CI minute
is spent. This is the moment the idea becomes real to them.

## What to produce

- **One self-contained HTML document**, delivered as a **rendered artifact**: all CSS and JS **inline**,
  any visual as **inline SVG**. It must **render and be clickable** in the chat panel — a wireframe they
  can poke at, prefilled with the Build Card's sample data, showing the layout and the key interaction working.
- It is a **throwaway mock to react to** — *not* the product. Say so plainly: the real, tested
  React + TypeScript app comes out of the pipeline; this is just so you can both agree on what we're building.

## Hard rules — this is exactly where it has failed before

- **NEVER** hand the user a `.jsx` / `.tsx` / React / "code"-type artifact, or anything that needs a build
  step, `npm`, or an IDE to view. **A business user cannot open code.** A `.jsx` file in an editor is a failure.
- **Self-check before you send it:** if the artifact shows as **source code** instead of a rendered,
  clickable screen, you picked the wrong artifact type — **redo it as a plain rendered HTML artifact.**
- Keep it **light** — a wireframe, not a polished build. It only has to communicate the layout and the core
  interaction. Don't gold-plate a mock you're about to throw away.

## Iterate

Adjust the wireframe to the user's reactions — sample data, labels, layout, an extra behavior. When they're
happy **and** the Build Card (`interview.md`) is approved, proceed to file the issue (SKILL.md step 4).
