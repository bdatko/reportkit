# AGENTS.md

Rules for coding agents working in this repository.

- Never type data values into Markdown, prose, or config. Data comes from
  `build/` only.
- Edit: `prose/*.md`, `steps/*.sh`, `lib/*`, `tests/*`, `docs/*.md`, and the
  orchestrator graph (`Makefile`, `dvc.yaml`, `params.yaml`). Do not edit
  anything under `build/` or `report.*`.
- Logic lives in `steps/*.sh`. The Makefile and `dvc.yaml` contain no logic:
  only step name, dependencies, outputs, and parameters.
- When you add or change a step, update `docs/pipeline-contract.md`, the
  Makefile, AND `dvc.yaml` in the same change. Test T10 (orchestrator
  equivalence) must stay green.
- New or changed numbers come from a Miller step, never from your own
  arithmetic.
- Every column used in a display step must be listed in the
  `asserting_present` gate in `steps/rows.sh`.
- Steps follow the conventions in `docs/pipeline-contract.md`: positional
  arguments, `set -euo pipefail`, atomic output, and `error[code]` on stderr.
- Loop: run the build, read stderr, fix, rerun. Do not "fix" a failing gate by
  deleting it.
- After the build, diff `report.md` against `tests/golden/report.md`. If you
  change a golden, say why the old one was wrong.
- Do not add Python, extra filters, or new tools without a failing test that
  requires it. Phase 2 is deferred; see `docs/gaps.md`.
- To find a field name:
  `mlr --ijsonl --ojson head -n 1 build/rows.jsonl`
- In `dvc.yaml`, escape a literal `${...}` as `\${...}`.
- Run `tests/run.sh` before declaring the work done. Use
  `tests/run.sh --no-dvc` only while iterating on the step scripts or Makefile.
