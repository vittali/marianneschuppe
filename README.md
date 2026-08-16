# marianneschuppe.com

Static Asciidoctor website for Marianne Schuppe, deployed from
[`vittali/marianneschuppe`](https://github.com/vittali/marianneschuppe) to
Cloudflare Pages.

The handcrafted root `index.html` is the home page. Section pages are generated
from `<section>/doc/*.adoc`; do not generate the root `doc/index.adoc` over the
handcrafted home page.

## Current production architecture

| Layer | Current owner or target |
|---|---|
| GitHub repository | `vittali/marianneschuppe`, production branch `master` |
| Git remote | `git@github.com-vittali:vittali/marianneschuppe.git` |
| Static hosting | Cloudflare Pages project `marianneschuppe` |
| Pages preview | <https://marianneschuppe.pages.dev> |
| Canonical site | <https://www.marianneschuppe.com> |
| Apex behavior | `marianneschuppe.com` redirects permanently to `www`, preserving path and query string |
| Cloudflare account ID | `788c7b26d4cea00429c2c0268a3ff576` |
| Cloudflare zone ID | `2e8dc41809dead792f0bd327a3f3bd36` |
| Authoritative nameservers | `penny.ns.cloudflare.com`, `porter.ns.cloudflare.com` |
| Registrar | GoDaddy, unchanged; the domain was not transferred to Cloudflare |
| Email | Legacy Google Workspace, with its existing records preserved |

The registrar can appear through the legacy Google Workspace domain-management
interface, but GoDaddy remains the registrar. Only authoritative DNS hosting was
moved from GoDaddy DNS to Cloudflare DNS. The registration expiry observed during
the migration was 21 December 2026.

## Prerequisites

- Node 24, selected from `.node-version` through the existing user-level `fnm`
- Ruby 3.3, selected from `.ruby-version`
- Bundler and the locked Asciidoctor 2.0.26 from `Gemfile.lock`
- Project-local npm dependencies from `package-lock.json`
- Project-local Wrangler 4.123.0; do not install Wrangler globally

Install dependencies reproducibly:

```bash
fnm use
bundle install
npm ci
```

## Build, validation, preview, and deployment

```bash
npm run build       # isolated Asciidoctor build followed by validation
npm run build:site  # build only; staging is still validated before promotion
npm run validate    # validate the existing dist/
npm run preview     # local Cloudflare Pages preview of dist/
npm run deploy      # manual production deployment using .env.cloudflare
```

The production build:

1. Discovers every top-level directory containing `doc/*.adoc`.
2. Creates an ignored `.dist.XXXXXX` staging directory.
3. Generates section HTML into staging without rewriting committed generated pages.
4. Copies only deployable root assets and section `doc/images`/`doc/pdf` assets.
5. Applies the intentional `extend` and `bridge` asset overlays used by `works`.
6. Validates file size, forbidden development files, symlinks, local HTML links,
   media references, and CSS `url(...)` references.
7. Replaces `dist/` only after staging passes validation.

`dist/` is the only publish directory. Never deploy the repository root: it
contains Asciidoctor sources, scripts, Git metadata, credentials, and development
files. Cloudflare's per-file limit is enforced locally at 25 MiB.

## Automated deployment

`.github/workflows/deploy.yml` runs on every push to `master` and by manual
`workflow_dispatch`. It uses the repository's Node and Ruby version files,
installs dependencies with Bundler and `npm ci`, builds `dist/`, and deploys only
that directory with `cloudflare/wrangler-action`.

The workflow requires these GitHub Actions repository secrets:

- `CLOUDFLARE_API_TOKEN`
- `CLOUDFLARE_ACCOUNT_ID`

Manage them in GitHub under **Repository → Settings → Secrets and variables →
Actions**. Never commit their values.

For an optional manual deployment, create ignored `.env.cloudflare` with those
same two variables and mode `0600`. `scripts/with-cloudflare-env.sh` rejects a
missing file or symlink and invokes the repository-local Wrangler. `.env` and all
`.env.*` files are ignored; there is intentionally no committed credential file.

## Content and assets

Sections are discovered automatically from `<section>/doc/*.adoc`. Current
sections are `bridge`, `contact`, `csl`, `extend`, `int_essay`, `mentor`, `now`,
`path`, `recording`, `review`, and `works`.

- Edit section content in `<section>/doc/*.adoc`.
- Put section media in `<section>/doc/images/` or `<section>/doc/pdf/`.
- Edit the handcrafted root `index.html` directly.
- Root deployable assets currently include `current-theme/`, `images/`,
  `inkscape/`, and `pdf/`.
- Keep individual deployable files below 25 MiB.

Four lossless, MP3-frame-boundary splits replaced oversized source files:

| Original legacy file | Published segments |
|---|---|
| `csl/images/9-1-25.mp3` | `9-1-25-part1.mp3`, `9-1-25-part2.mp3` |
| `int_essay/images/reflexe.mp3` | `reflexe-part1.mp3`, `reflexe-part2.mp3` |
| `int_essay/images/scelsi1.mp3` | `scelsi1-part1.mp3`, `scelsi1-part2.mp3`, `scelsi1-part3.mp3` |
| `int_essay/images/scelsi2.mp3` | `scelsi2-part1.mp3`, `scelsi2-part2.mp3` |

The Asciidoctor sources link the segments as consecutive players. The originals
remain recoverable from the legacy repository.

## Migration record (16 August 2026)

The site moved from GitHub Pages to Cloudflare Pages as follows:

- The old repository was `mschuppe/mschuppe.github.io`.
- The new repository is `vittali/marianneschuppe`.
- At the owner's request, the new repository started with a new root commit rather
  than copying the old branches and full history. The old repository remains the
  historical archive and rollback source.
- The local `legacy` remote points to the old repository through the existing
  `github.com-mschuppe` SSH overlay. `origin` uses the `github.com-vittali` SSH
  overlay.
- The old repository's GitHub Pages site was unpublished only after both
  Cloudflare custom domains, TLS, redirects, content, and mail DNS were verified.
- The old repository itself, its branches, files, and history were not deleted.
- The GitHub Pages `CNAME` was removed from the new repository after Cloudflare
  verification.

The original authoritative GoDaddy zone export contained 31 entries including
SOA: four GitHub Pages apex A records, `www` pointing to
`mschuppe.github.io`, one Google verification TXT record, five Google/Domain
Connect service CNAMEs, seven Google MX records, ten Jabber/XMPP SRV records, two
GoDaddy NS records, and the SOA. DNSSEC was off before delegation changed.
The complete verified pre-cutover inventory is archived at
[`docs/dns-before-cloudflare.zone`](docs/dns-before-cloudflare.zone). It is an
audit record, not a zone file to import into the current Cloudflare zone.

Cloudflare preserved the 23 non-web records exactly at TTL 3600:

- Google verification TXT at the apex
- `calendar`, `docs`, `mail`, and `start` CNAMEs to `ghs.google.com`
- `_domainconnect` CNAME to `_domainconnect.ss.domaincontrol.com`
- Google MX priorities 10/20/20/30/30/30/30
- Five `_jabber._tcp` and five `_xmpp-server._tcp` Google SRV records

No SPF, DKIM, or DMARC records were invented because none existed in the verified
authoritative export. The obsolete GitHub A records and `www` CNAME were replaced
by proxied Cloudflare Pages records for the apex and `www`. Both custom domains
are associated with the Pages project. A Cloudflare Single Redirect implements:

```text
https://marianneschuppe.com/*
  301 → https://www.marianneschuppe.com/${1}
```

“Preserve query string” is enabled. HTTP is first upgraded to HTTPS, after which
the canonical redirect applies.

## Rollback and safety boundaries

- Cloudflare retains previous Pages deployments; a known-good deployment can be
  promoted if a release regresses.
- The old GitHub repository is the content/history archive. Re-enabling its Pages
  configuration is possible, but DNS would also need an explicitly planned rollback.
- Do not change registrar nameservers, DNS records, Pages custom domains, or
  GitHub repository settings as part of an ordinary content deployment.
- Before any infrastructure mutation, identify the GitHub repository, Cloudflare
  account, Pages project, DNS zone/records, and rollback point.
- Do not modify the `sysadmin` repository as part of work on this site.
- Unrelated `.gradle/` content must remain untracked and excluded from commits.
