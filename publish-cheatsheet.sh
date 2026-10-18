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

{
  printf -- '---\n'
  printf 'title: "%s"\n' "$title"
  printf 'ShowToc: true\n'
  printf 'TocOpen: false\n'
  printf 'build:\n'
  printf '  list: never\n'
  printf -- '---\n\n'
  awk 'NR==1 && /^# /{next} {print}' "$src"
} > "$dst"

echo "published: ${dst}"
