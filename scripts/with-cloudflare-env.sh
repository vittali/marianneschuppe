#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
credentials="$repo_root/.env.cloudflare"

if [[ ! -f "$credentials" || -L "$credentials" ]]; then
  echo "Missing local Cloudflare credentials: $credentials" >&2
  exit 1
fi

set -a
# shellcheck disable=SC1090
source "$credentials"
set +a

: "${CLOUDFLARE_API_TOKEN:?CLOUDFLARE_API_TOKEN is required}"
: "${CLOUDFLARE_ACCOUNT_ID:?CLOUDFLARE_ACCOUNT_ID is required}"

exec "$repo_root/node_modules/.bin/wrangler" "$@"
