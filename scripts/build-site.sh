#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
publish_dir="$repo_root/dist"
sections=(bridge contact csl extend int_essay mentor now path recording review works)

cd "$repo_root"

if [[ "${SKIP_ASCIIDOCTOR:-0}" != "1" ]]; then
  for section in "${sections[@]}"; do
    while IFS= read -r source; do
      bundle exec asciidoctor -D "$section" "$source"
    done < <(find "$section/doc" -maxdepth 1 -type f -name '*.adoc' | sort)

    for asset_dir in images pdf; do
      if [[ -d "$section/doc/$asset_dir" ]]; then
        mkdir -p "$section/$asset_dir"
        rsync -a "$section/doc/$asset_dir/" "$section/$asset_dir/"
      fi
    done
  done

  # These pages reuse assets from their legacy source sections.
  rsync -a extend/images/ works/images/
  rsync -a extend/pdf/ works/pdf/
  rsync -a bridge/pdf/ works/pdf/
fi

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
mkdir "$publish_dir"

cp index.html "$publish_dir/"
for root_asset_dir in current-theme images pdf; do
  if [[ -d "$root_asset_dir" ]]; then
    cp -R "$root_asset_dir" "$publish_dir/"
  fi
done

for section in "${sections[@]}"; do
  mkdir "$publish_dir/$section"
  find "$section" -maxdepth 1 -type f -name '*.html' -exec cp {} "$publish_dir/$section/" \;
  for asset_dir in images pdf; do
    if [[ -d "$section/$asset_dir" ]]; then
      cp -R "$section/$asset_dir" "$publish_dir/$section/"
    fi
  done
done

node scripts/check-dist.mjs
