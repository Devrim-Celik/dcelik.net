#!/usr/bin/env bash
# usage: ./publish-cheatsheet.sh 09_pivoting   (the .md and cheatsheets-src/ prefix are optional)
set -euo pipefail
name="${1:?usage: ./publish-cheatsheet.sh <name>}"
name="${name#cheatsheets-src/}"   # drop a leading cheatsheets-src/ (tab-completion)
name="${name%.md}"                # drop a trailing .md
src="cheatsheets-src/${name}.md"
dst="content/teaching/offensive-cybersecurity/ws2026/cheatsheets/${name}.md"
[ -f "$src" ] || { echo "no such source: $src"; exit 1; }

title=$(grep -m1 '^# ' "$src" | sed 's/^# *//')

# raw markdown, downloadable (served at /dl/cheatsheets/<name>.md)
mkdir -p static/dl/cheatsheets
cp "$src" "static/dl/cheatsheets/${name}.md"

{
  printf -- '---\n'
  printf 'title: "%s"\n' "$title"
  printf 'ShowToc: true\n'
  printf 'TocOpen: false\n'
  printf 'build:\n'
  printf '  list: never\n'
  printf -- '---\n\n'
  # top nav: back to the index (normal link) + download the raw markdown (forced via shortcode)
  printf -- '[← Cheat Sheets](../) · {{< download "/dl/cheatsheets/%s.md" "Download this sheet (.md)" >}}\n\n' "${name}"
  awk 'NR==1 && /^# /{next} {print}' "$src"
} > "$dst"

echo "published: ${dst}"
