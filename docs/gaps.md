# Gap ledger

Phase 2 is not started. A gap is promoted to code only when it blocks real work
and the fix does not fit in a line or two of Miller or Lua. A display feature
should appear in three unrelated reports before it becomes a general feature.

| id | gap | class | seen in | status |
|---|---|---|---|---|
| G1 | Errors are tool-native (Miller/pandoc stderr); no nearest-match hint | checks | reference report | open — candidate for `reportkit check` |
| G2 | No thousands separator: `8358` instead of `8,358` | display | reference report | open — no workaround yet |
| G3 | `suppress_repeat` has no grouped-input check; removing the upstream sort is silently wrong | display | reference report | open — documented, test T7 skipped |
| G4 | No JSON error output for editor/agent integration | checks | reference report | open — deferred |
| G5 | Template is Miller `format()`: positional `{}`, no per-field specs | display | reference report | open — deferred |
| G6 | One table style per pandoc run; no subtotals | display | reference report | open — deferred |

## Deferred acceptance tests

- **T7** — unsorted `suppress_repeat` input is silently wrong; this is G3.
- **T8** — the `report.pptx` slide layout is deferred to the next slice.
- **T9** — `.docx` files are not byte-compared; only `report.md` determinism is
  tested. Pandoc metadata makes the docx hash change between builds, so
  `dvc.lock` can churn for that output.

## Notes

- G2 is visible in the reference report: the letter says `8358 thousand km²`.
  That is intentionally faithful to the current stack; it is not a typo.
- G3 is why `steps/rows.sh` must keep `sort -f continent` before
  `lib/suppress_repeat.mlr`. The filter only compares each value with the
  previous row.
- The likely Phase 2 order, if it happens, is checks first (G1, G3, G4), then
  format specs (G2, G5), then table layout (G6).
