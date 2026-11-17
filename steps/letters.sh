#!/usr/bin/env bash
# usage: steps/letters.sh COUNTRY ROWS.jsonl OUT.md
set -euo pipefail
country=$1; in=$2; out=$3; tmp="$out.tmp"
mkdir -p "$(dirname "$out")"; trap 'rm -f "$tmp"' EXIT
mlr --ijsonl --ojsonl filter -s c="$country" '$country == @c' then put -q -f lib/letter.mlr "$in" > "$tmp"
[ -s "$tmp" ] || { echo "error[no-rows]: no rows for country '$country' in $in" >&2; exit 1; }
mv "$tmp" "$out"; trap - EXIT
