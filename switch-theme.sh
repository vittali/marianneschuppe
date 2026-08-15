#!/bin/zsh
if [ -z "$1" ]; then
  echo "Usage: ./switch-theme.sh <theme-name>"
  echo "Available themes: manuscript, warmth"
  exit 1
fi
if [ ! -f "themes/$1.css" ]; then
  echo "Theme '$1' not found. Available themes:"
  ls themes/*.css | sed 's|themes/||;s|\.css||'
  exit 1
fi
cp themes/$1.css current-theme/theme.css
echo "Switched to theme: $1"
