#!/usr/bin/env bash
# usage: steps/rows.sh IN.tsv OUT.jsonl      (run from the repo root)
set -euo pipefail
in=$1; out=$2; tmp="$out.tmp"
mkdir -p "$(dirname "$out")"; trap 'rm -f "$tmp"' EXIT
mlr --itsv --implicit-csv-header --ojsonl label country,area,pop,continent \
  then put '$den = 1000 * $pop / $area' \
  then sort -f continent -nr den "$in" > "$tmp"
[ -s "$tmp" ] || { echo "error[no-rows]: $out would be empty; check the input" >&2; exit 1; }
mlr --ijsonl --ojsonl put -q 'asserting_present($continent); asserting_present($country); asserting_present($pop); asserting_present($area); asserting_present($den)' "$tmp"
mv "$tmp" "$out"; trap - EXIT
