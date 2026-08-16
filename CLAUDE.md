# Repository guidance

Read [README.md](README.md) before changing build, deployment, DNS, domains, or
repository configuration. Use [MANUAL.md](MANUAL.md) for content-editing steps.

## Non-negotiable conventions

- This is a static Asciidoctor site deployed to Cloudflare Pages from
  `vittali/marianneschuppe`, branch `master`.
- Build with `npm run build`; deploy only `dist/`, never the repository root.
- Section sources are `<section>/doc/*.adoc` and are discovered automatically.
- Root `index.html` is handcrafted. Never overwrite it by generating
  `doc/index.adoc`.
- Preserve the existing bilingual structure, generated-page conventions, themes,
  assets, and quiet literary design.
- Use Node 24 from `.node-version`, Ruby from `.ruby-version`, locked Bundler
  dependencies, `npm ci`, and project-local Wrangler only.
- Never commit `.env.cloudflare` or any credential value. GitHub Actions uses
  `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID` repository secrets.
- Keep deployable files below 25 MiB. Existing oversized audio was split at MP3
  frame boundaries; do not recombine it in the publication.
- Preserve the old `mschuppe/mschuppe.github.io` repository as the historical
  archive. Its GitHub Pages site is unpublished.
- Registrar changes, DNS changes, and Cloudflare custom-domain changes are not
  ordinary site edits and require explicit targets, rollback points, and approval.
- Do not modify the `sysadmin` repository.
- Do not commit unrelated `.gradle/` content.

## Verification

```bash
npm run build
npm run validate
npm run preview
```

The build stages output in `.dist.XXXXXX`, validates it, and only then replaces
`dist/`. Validation rejects source/development files, symlinks, files over 25 MiB,
and broken local HTML/media/CSS references.
