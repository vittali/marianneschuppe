#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
publish_dir="$repo_root/dist"
stage_dir="$(mktemp -d "$repo_root/.dist.XXXXXX")"

cleanup() {
  if [[ -n "${stage_dir:-}" && -d "$stage_dir" && ! -L "$stage_dir" ]]; then
    find "$stage_dir" -xdev -mindepth 1 -delete
    rmdir "$stage_dir"
  fi
}
trap cleanup EXIT

cd "$repo_root"

mapfile -t sections < <(
  find . -mindepth 2 -maxdepth 2 -type d -name doc -print \
    | sed -E 's#^\./##; s#/doc$##' \
    | while IFS= read -r section; do
        find "$section/doc" -maxdepth 1 -type f -name '*.adoc' -print -quit | grep -q . && printf '%s\n' "$section"
      done \
    | sort
)

if (( ${#sections[@]} == 0 )); then
  echo "No Asciidoctor sections found." >&2
  exit 1
fi

cp index.html "$stage_dir/"
for root_asset_dir in current-theme images inkscape pdf; do
  if [[ -d "$root_asset_dir" ]]; then
    cp -R "$root_asset_dir" "$stage_dir/"
  fi
done

for section in "${sections[@]}"; do
  section_output="$stage_dir/$section"
  mkdir -p "$section_output"

  while IFS= read -r source; do
    bundle exec asciidoctor -D "$section_output" "$source"
  done < <(find "$section/doc" -maxdepth 1 -type f -name '*.adoc' | sort)

  for asset_dir in images pdf; do
    if [[ -d "$section/doc/$asset_dir" ]]; then
      cp -R "$section/doc/$asset_dir" "$section_output/"
    fi
  done
done

# These pages intentionally reuse assets from their legacy source sections.
cp -R extend/doc/images/. "$stage_dir/works/images/"
cp -R extend/doc/pdf/. "$stage_dir/works/pdf/"
cp -R bridge/doc/pdf/. "$stage_dir/works/pdf/"

# Validate staging before replacing the last known-good publish directory.
node scripts/check-dist.mjs "$stage_dir"

# The home page is handcrafted and must never be generated from doc/index.adoc.
if [[ -L "$publish_dir" ]]; then
  echo "Refusing to replace symlinked publish directory: $publish_dir" >&2
  exit 1
fi
if [[ -e "$publish_dir" ]]; then
  [[ "$publish_dir" == "$repo_root/dist" ]] || exit 1
  find "$publish_dir" -xdev -mindepth 1 -delete
  rmdir "$publish_dir"
fi
mv "$stage_dir" "$publish_dir"
stage_dir=""
