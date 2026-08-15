# Visual Design Notes

## visual-1 — Score-fragment drawings as visual softeners

### Intent

The site was text-only, which serves the literary character of the work but creates a certain emotional distance. The goal was to introduce a small visual presence — not decoration, but a trace of the compositional process — without disrupting the minimal aesthetic.

### What was added

**Homepage (`doc/index.adoc`)**
A fragment of Inkscape drawing `3-22-1.svg` (March 2022) appears between the introductory paragraph and the Bridging / Extending / Sharing axis section. Only the top portion of the A4 drawing is visible (clipped to ~7em height), showing a curved notation arc. It sits centered, at 45% opacity, as a visual breath between the two text blocks.

**All pages (`doc/docinfo.html`, propagated)**
The same drawing appears as a faint watermark anchored to the bottom-right corner of every page — rendered at approximately 5% opacity using a layered CSS background:

```css
body {
  background:
    linear-gradient(rgba(255,254,249,0.95), rgba(255,254,249,0.95)),
    url(/inkscape/3-22-1.svg) right bottom / 30em auto no-repeat,
    #fffef9;
}
```

No new image files were added. All drawings are sourced from the existing `inkscape/` directory, which is served by GitHub Pages at `/inkscape/`.

### How to adjust

| What | Where | How |
|---|---|---|
| Which drawing | `doc/index.adoc` and `doc/docinfo.html` | Change `3-22-1.svg` to any file in `inkscape/` |
| Homepage fragment size | `doc/index.adoc` `<style>` block | Adjust `max-width` / `max-height` on `.score-fragment img` |
| Homepage fragment opacity | Same | Adjust `opacity` on `.score-fragment img` |
| Watermark opacity | `doc/docinfo.html` | Change `0.95` in `rgba(255,254,249,0.95)` (lower = more visible) |
| Watermark position | `doc/docinfo.html` | Change `right bottom` to e.g. `right center` or `center bottom` |
| Watermark fixed to viewport | `doc/docinfo.html` | Add `background-attachment: fixed` (note: disabled on iOS) |
| Propagate changes to all sections | — | Run `./propagate-style.sh` then `./build.sh` |

### Available drawings

All in `inkscape/`, served at `/inkscape/`:

- `3-22-1.svg` — March 2022 ← current
- `3-22-2.svg` — March 2022
- `10-22-1.svg` — October 2022
- `14-08-24.svg` — August 2024
- `31-12-org.svg` — December 31 (also as `31-12.jpg`)

### Possible next steps

- Try different drawings per section (requires adding a body class per `.adoc` file)
- Add a second score-fragment after the axis section on the homepage
- Explore using the axis images (`bridging.png`, `extending.png`, `sharing.png`) in the axis table cells
- Hero portrait image (deferred from original proposal)
- Distilled intro text restructure (deferred from original proposal)
