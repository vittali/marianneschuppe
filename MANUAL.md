# Site Manual — marianneschuppe.com

## Quick Start

```bash
./build.sh                        # build entire site
python3 -m http.server 8080       # serve locally at http://localhost:8080
```

## Themes

Four visual themes are available. The active theme lives in `current-theme/theme.css`.

| Theme        | Description                                      |
|--------------|--------------------------------------------------|
| `shore`      | Warm cream background, brown tones, Lora font    |
| `manuscript` | Near-white, small-caps headings, Crimson Text     |
| `silence`    | Pure white, gray tones, system fonts, wide margins|
| `dusk`       | Dark background, muted gold links, EB Garamond    |

### Switching themes

```bash
./switch-theme.sh manuscript
```

Reload the browser — no rebuild needed. The CSS is linked externally, so the change is instant.

To switch back:

```bash
./switch-theme.sh shore
```

### Editing a theme

Open any file in `themes/` with a text editor. The CSS is organized in labeled sections:

- **Body** — background color, text color, base font
- **Typography** — headings, links, paragraphs, line-height
- **TOC** — sidebar table of contents (appears on section pages)
- **Tables** — used heavily on the home page layout
- **Site navigation footer** — the cross-section nav bar
- **Print** — print-specific overrides

After editing, copy it to the active slot:

```bash
cp themes/shore.css current-theme/theme.css
```

Or create a new theme by copying an existing one:

```bash
cp themes/shore.css themes/my-theme.css
# edit themes/my-theme.css
./switch-theme.sh my-theme
```

## Building

| Command              | What it does                                  |
|----------------------|-----------------------------------------------|
| `./build.sh`        | Build all sections + home page                |
| `./build-top.sh`    | Build only the home page                      |
| `cd csl && ./build.sh` | Build a single section                     |
| `./propagate-style.sh` | Copy shared docinfo files to all sections  |

Run `./propagate-style.sh` before `./build.sh` whenever you change:
- `doc/docinfo.html` (head injections)
- `doc/docinfo-footer.html` (navigation footer)

## Editing Content

Content lives in `<section>/doc/index.adoc` files, written in Asciidoctor markup.

### Adding a new entry to Colline sur livre

Open `csl/doc/index.adoc` and add below the `[[colline]]` anchor:

```asciidoc
.15.2.2026
audio::15-2-26.mp3[]
```

Place the corresponding `.mp3` file in `csl/doc/images/`, then build:

```bash
cd csl && ./build.sh
```

### Adding an image

Place the image in the section's `doc/images/` directory, then reference it:

```asciidoc
image::filename.jpg[alt text, width=50%, align="center"]
```

For clickable full-size images:

```asciidoc
image::filename.jpg[link=images/filename.jpg, width=50%, align="center"]
```

Keep images under 1400px on the longest side and JPEGs at quality 80 to avoid bloating the site.

## Responsive Design

The site targets two reference screen sizes:

- **Desktop**: 16" laptop — navigation footer is fixed at the bottom with all links visible
- **Mobile**: 6.56" smartphone — navigation footer collapses behind a hamburger menu icon (pure CSS, no JavaScript)

The mobile breakpoint is 767px. The hamburger toggle uses a checkbox hack for CSS-only interactivity.

## Navigation Footer

Every page has a footer with links to all sections. To edit the links, modify `doc/docinfo-footer.html`, then:

```bash
./propagate-style.sh
./build.sh
```

## Adding a New Section

1. Create the directory structure:
   ```
   newsection/
     doc/
       index.adoc
       images/
     build.sh
   ```

2. Use this header in `doc/index.adoc`:
   ```asciidoc
   = Section Title
   :includedir: _includes
   :imagesdir: ./images
   :icons: font
   :toc: left
   :toc-title:
   :nofooter:
   :sectnums:
   :figure-caption!:
   :sectnums!:
   :docinfo: shared
   :linkcss:
   :copycss!:
   :stylesheet: theme.css
   :stylesdir: /current-theme
   ```

3. Copy `build.sh` from an existing section.

4. Add the section to:
   - `build.sh` (main build script)
   - `propagate-style.sh` (SECTIONS array)
   - `doc/docinfo-footer.html` (navigation)

5. Run `./propagate-style.sh && ./build.sh`

## File Overview

```
current-theme/theme.css    Active theme (do not edit directly)
themes/*.css               Theme files (edit these)
switch-theme.sh            Switch active theme
propagate-style.sh         Distribute shared files to sections
build.sh                   Build entire site
doc/docinfo-footer.html    Navigation footer HTML
doc/docinfo.html           Head injection (currently empty)
<section>/doc/index.adoc   Section content source
<section>/index.html       Generated output (do not hand-edit)
```
