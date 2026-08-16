# Site editing manual

See [README.md](README.md) for production architecture, deployment, DNS, migration,
credentials, and rollback details.

## Quick start

```bash
fnm use
bundle install
npm ci
npm run build
npm run preview
```

Preview serves the clean `dist/` publication through local Wrangler. Do not serve
or deploy the repository root.

## Editing content

Section sources live in `<section>/doc/*.adoc`. Generated section HTML is build
output and should not be hand-edited. The root `index.html` is the deliberate
exception: it is handcrafted and must be edited directly. Never generate
`doc/index.adoc` over it.

### Add a Colline sur livre recording

Edit `csl/doc/index.adoc` and add an entry such as:

```asciidoc
.15.2.2026
audio::15-2-26.mp3[]
```

Place the audio in `csl/doc/images/`, then run `npm run build`. Files larger than
25 MiB fail validation and must be compressed appropriately, hosted externally,
or split losslessly at MP3 frame boundaries with consecutive players added to the
source. Do not split arbitrary byte ranges.

### Add an image

Place it in the section's `doc/images/` directory and reference it with:

```asciidoc
image::filename.jpg[alt text, width=50%, align="center"]
```

For a clickable full-size image:

```asciidoc
image::filename.jpg[link=images/filename.jpg, width=50%, align="center"]
```

Prefer images no larger than 1400 px on the longest side and JPEG quality around
80 unless the work requires otherwise.

## Add a section

Create:

```text
newsection/
  doc/
    index.adoc
    docinfo.html
    docinfo-footer.html
    images/
    pdf/
```

The production build discovers top-level directories containing `doc/*.adoc`, so
there is no central section array to edit. Copy a current section's Asciidoctor
header, update navigation in `doc/docinfo-footer.html`, propagate the shared
docinfo files with the existing styling utility if needed, then run `npm run build`.

## Themes and shared styling

The active stylesheet is `current-theme/theme.css`; theme candidates live under
`themes/`. Switch using the existing theme utility, then build and preview:

```bash
./switch-theme.sh manuscript
npm run build
npm run preview
```

Section sources link `/current-theme/theme.css`, so only the active stylesheet is
published. Shared `docinfo.html` and `docinfo-footer.html` files supply page-level
styling and navigation. The `inkscape/` directory is published because those
styles use `/inkscape/3-22-1.svg` as a watermark.

## Release procedure

1. Run `npm run build` and resolve every validation error.
2. Run `npm run preview` and inspect affected desktop/mobile pages and media.
3. Commit source, asset, build-script, and documentation changes only; never
   commit `dist/`, `.env.cloudflare`, `node_modules/`, or unrelated files.
4. Push `master` to `origin`.
5. Verify the GitHub Actions deployment and its immutable `*.pages.dev` URL.
6. Verify the canonical `www` URL, apex redirect, TLS, and affected media.

Manual `npm run deploy` exists for recovery but routine production deployments
should go through GitHub Actions.
