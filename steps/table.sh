#!/usr/bin/env bash
# usage: steps/table.sh ROWS.jsonl OUT.md
set -euo pipefail
in=$1; out=$2; tmp="$out.tmp"
mkdir -p "$(dirname "$out")"; trap 'rm -f "$tmp"' EXIT
mlr --ijsonl --ocsv put -s col=continent -f lib/suppress_repeat.mlr \
  then put '$Density = fmtnum($den, "%.1f")' \
  then cut -o -f continent,country,pop,area,Density \
  then rename 'continent,Continent,country,Country,pop,Pop (M),area,Area (k km²)' "$in" \
  | pandoc -f csv -t gfm --lua-filter=lib/align.lua > "$tmp"
[ -s "$tmp" ] || { echo "error[no-rows]: $out would be empty" >&2; exit 1; }
mv "$tmp" "$out"; trap - EXIT
