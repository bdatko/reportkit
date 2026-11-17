#!/usr/bin/env bash
# usage: steps/report.sh OUT.{md,docx,pptx} INPUT.md...     (format chosen by extension)
set -euo pipefail
out=$1; shift
d=$(mktemp -d); trap 'rm -rf "$d"' EXIT; tmp="$d/$(basename "$out")"
case $out in
  *.md) pandoc "$@" -t gfm --wrap=none -o "$tmp" ;;
  *)    pandoc "$@" -o "$tmp" ;;
esac
mv "$tmp" "$out"
