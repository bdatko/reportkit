#!/usr/bin/env bash
# Acceptance tests for the reportkit reference report.
#
# Usage:
#   tests/run.sh             # full suite, including Make/DVC equivalence
#   tests/run.sh --no-dvc    # step + Make tests only, while iterating
#   MAKE=gmake tests/run.sh  # macOS with GNU Make from Homebrew
set -euo pipefail

cd "$(dirname "$0")/.."

make_bin=${MAKE:-make}
run_dvc=1
for arg in "$@"; do
  case "$arg" in
    --no-dvc) run_dvc=0 ;;
    -h|--help)
      sed -n '2,7p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *)
      echo "unknown argument: $arg" >&2
      exit 2
      ;;
  esac
done

tmp=$(mktemp -d)
params_backup=""
cleanup() {
  if [ -n "$params_backup" ] && [ -f "$params_backup" ]; then
    cp "$params_backup" params.yaml
  fi
  rm -rf "$tmp"
}
trap cleanup EXIT

passed=0
failed=0
ok() { printf 'ok   %s\n' "$1"; passed=$((passed + 1)); }
bad() { printf 'FAIL %s\n' "$1" >&2; failed=$((failed + 1)); }
skip() { printf 'skip %s\n' "$1"; }

require() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "missing required tool: $1" >&2
    exit 2
  fi
}

require mlr
require pandoc
require unzip
require "$make_bin"
if [ "$run_dvc" -eq 1 ]; then
  require dvc
fi

# T1: clean build matches the checked-in golden output.
if "$make_bin" clean >/dev/null 2>&1 &&
   "$make_bin" >"$tmp/t1.log" 2>&1 &&
   cmp -s report.md tests/golden/report.md; then
  ok "T1 clean build matches golden"
else
  bad "T1 clean build matches golden"
  tail -50 "$tmp/t1.log" >&2 || true
  if [ -f report.md ]; then
    diff -u tests/golden/report.md report.md >&2 || true
  fi
fi

# T2: two clean builds are byte-identical.
if "$make_bin" clean >/dev/null 2>&1 &&
   "$make_bin" >/dev/null 2>&1 &&
   cp report.md "$tmp/t2-a.md" &&
   "$make_bin" clean >/dev/null 2>&1 &&
   "$make_bin" >/dev/null 2>&1 &&
   cmp -s "$tmp/t2-a.md" report.md; then
  ok "T2 repeated clean build is byte-identical"
else
  bad "T2 repeated clean build is byte-identical"
fi

# T3: docx table cells are right-aligned.
if [ -f report.docx ] &&
   unzip -p report.docx word/document.xml >"$tmp/document.xml" 2>/dev/null &&
   grep -q '<w:jc w:val="right" />' "$tmp/document.xml"; then
  ok "T3 docx contains right-aligned table cells"
else
  bad "T3 docx contains right-aligned table cells"
fi

# T4: a misspelled field in the asserting_present gate fails loudly.
sed 's/asserting_present(\$pop)/asserting_present($popp)/' steps/rows.sh >"$tmp/rows-bad.sh"
chmod +x "$tmp/rows-bad.sh"
if cmp -s steps/rows.sh "$tmp/rows-bad.sh"; then
  bad "T4 missing-field gate (test setup did not modify the script)"
elif "$tmp/rows-bad.sh" data/countries.tsv "$tmp/rows-bad.jsonl" \
       >"$tmp/t4.out" 2>"$tmp/t4.err"; then
  bad "T4 missing-field gate did not fail"
else
  if grep -q 'is_present type-assertion failed' "$tmp/t4.err" &&
     [ ! -e "$tmp/rows-bad.jsonl" ]; then
    ok "T4 missing-field gate fails and leaves no output"
  else
    bad "T4 missing-field gate produced the wrong failure"
    cat "$tmp/t4.err" >&2
  fi
fi

# T5: a country with no rows fails with error[no-rows], no partial output.
if steps/letters.sh Atlantis build/rows.jsonl "$tmp/letters-atlantis.md" \
     >"$tmp/t5.out" 2>"$tmp/t5.err"; then
  bad "T5 zero-row letters step did not fail"
else
  if grep -q 'error\[no-rows\]' "$tmp/t5.err" &&
     [ ! -e "$tmp/letters-atlantis.md" ]; then
    ok "T5 zero-row letters step fails and leaves no output"
  else
    bad "T5 zero-row letters step produced the wrong failure"
    cat "$tmp/t5.err" >&2
  fi
fi

# T6: hostile values are escaped by pandoc's CSV reader.
pandoc -f csv -t gfm tests/fixtures/hostile.csv >"$tmp/hostile.md"
if cmp -s "$tmp/hostile.md" tests/golden/hostile.md; then
  ok "T6 hostile CSV escaping matches golden"
else
  bad "T6 hostile CSV escaping matches golden"
  diff -u tests/golden/hostile.md "$tmp/hostile.md" >&2 || true
fi

# T7: known gap G3. The current suppress_repeat filter has no grouped-input
# check, so removing the upstream sort is silently wrong.
skip "T7 known gap G3: unsorted suppress_repeat input is silently wrong"

# T8: pptx is deferred to the next slice.
skip "T8 pptx layout deferred"

# T9: do not byte-compare docx files.
skip "T9 docx byte-identity intentionally not tested"

if [ "$run_dvc" -eq 1 ]; then
  # T10: Make and DVC produce the same Markdown.
  if "$make_bin" clean >/dev/null 2>&1 &&
     "$make_bin" >/dev/null 2>&1 &&
     cp report.md "$tmp/t10-make.md" &&
     NO_COLOR=1 dvc repro -f >"$tmp/t10.log" 2>&1 &&
     cmp -s report.md "$tmp/t10-make.md"; then
    ok "T10 Make and DVC produce identical report.md"
  else
    bad "T10 Make and DVC produce identical report.md"
    tail -50 "$tmp/t10.log" >&2 || true
  fi

  # T11: changing only params.yaml reruns letters and the report stages.
  t11_ok=1
  params_backup="$tmp/params.yaml.bak"
  cp params.yaml "$params_backup"
  sed 's/^country: .*/country: India/' "$params_backup" >params.yaml

  if ! NO_COLOR=1 dvc repro >"$tmp/t11.log" 2>&1; then
    t11_ok=0
  fi
  if ! grep -q "Running stage 'letters'" "$tmp/t11.log" ||
     ! grep -q "Running stage 'report_md'" "$tmp/t11.log" ||
     ! grep -q "Running stage 'report_docx'" "$tmp/t11.log" ||
     grep -q "Running stage 'rows'" "$tmp/t11.log" ||
     grep -q "Running stage 'table'" "$tmp/t11.log" ||
     ! grep -q '^## India$' report.md; then
    t11_ok=0
  fi

  # Restore the tracked parameter and rebuild the golden state.
  cp "$params_backup" params.yaml
  if ! NO_COLOR=1 dvc repro >"$tmp/t11-restore.log" 2>&1; then
    t11_ok=0
  fi
  if ! cmp -s report.md tests/golden/report.md; then
    t11_ok=0
  fi

  if [ "$t11_ok" -eq 1 ]; then
    ok "T11 params-only change reruns only letters and report stages"
  else
    bad "T11 params-only change reruns only letters and report stages"
    cat "$tmp/t11.log" >&2 || true
    cat "$tmp/t11-restore.log" >&2 || true
  fi
fi

printf '\n%d passed, %d failed\n' "$passed" "$failed"
[ "$failed" -eq 0 ]
