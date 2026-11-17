# reportkit

A reference implementation of the reportkit v3 pipeline. Deterministic tools
produce every fact and table; agents write only prose and small config. Make and
DVC are interchangeable graph-only orchestrators over the same step scripts.

This checkout is the single reference report: the countries example from the
AWK book, rendered as `report.md` and `report.docx`.

## Prerequisites

- [mise](https://mise.jdx.dev/) for the pinned toolchain, or install the tools
  yourself:
  - Miller `6.11.0`
  - pandoc `3.1.3`
  - DVC `3.67.1`
- GNU Make `3.82+` (the Makefile uses `.RECIPEPREFIX`)
  - Linux: the system `make` is usually fine.
  - macOS: `brew install make`, then use `gmake`.
- `bash` and `unzip`

With mise:

```sh
mise trust .mise.toml
mise install
```

Verify:

```sh
mlr --version
pandoc --version | head -1
dvc --version
make --version | head -1
```

## Build

With Make:

```sh
make clean
make
```

With DVC:

```sh
dvc repro
```

Force a full rebuild:

```sh
make clean && make
# or
dvc repro -f
```

Outputs:

- `build/rows.jsonl` — ordered facts
- `build/table.md` — Markdown table fragment
- `build/letters.md` — Markdown prose for the selected country
- `report.md` — final Markdown report
- `report.docx` — Word version of the same report

Generated files are ignored by git. The checked-in target is
`tests/golden/report.md`.

## Test

```sh
tests/run.sh
```

While iterating on the steps or Makefile without DVC:

```sh
tests/run.sh --no-dvc
```

On macOS with Homebrew GNU Make:

```sh
MAKE=gmake tests/run.sh
```

The suite covers the clean build, determinism, docx alignment, loud failures,
hostile-value escaping, and Make/DVC equivalence. T7–T9 are deliberately
skipped; see `docs/gaps.md`.

## Changing the country

With Make, the parameter is not tracked by timestamps. Rebuild cleanly:

```sh
make clean
make COUNTRY=India
```

With DVC, edit `params.yaml` and let the graph decide:

```yaml
country: India
```

```sh
dvc repro
```

## Layout

This is the v3 single-report layout at the repository root. When a second report
appears, move the report-specific directories under `reports/<name>/` and share
`steps/` and `lib/` across them.

```text
.
├── AGENTS.md                 rules for coding agents
├── Makefile                  orchestrator A (graph only)
├── dvc.yaml, params.yaml     orchestrator B (graph only)
├── data/countries.tsv        raw input; read-only
├── steps/                    every pipeline command lives here
├── lib/                      Miller and Lua support files
├── prose/intro.md            agent-written narrative
├── tests/                    fixtures, golden output, acceptance suite
├── build/                    generated
├── report.md, report.docx    generated
└── docs/
    ├── pipeline-contract.md  single source of truth for the graph
    └── gaps.md               Phase 2 candidate ledger
```

## Rules of the road

- Data values never get typed into Markdown, prose, or config. They come from
  `build/` or from a step.
- Logic lives in `steps/*.sh`. The Makefile and `dvc.yaml` contain no logic:
  only step name, dependencies, outputs, and parameters.
- Update `docs/pipeline-contract.md`, the Makefile, and `dvc.yaml` together.
- The step conventions are positional arguments, `set -euo pipefail`, atomic
  output, and `error[code]` on stderr.
- Do not add Python, extra filters, or new tools without a failing test that
  requires them. Phase 2 is deferred until a real gap demands it.

See `AGENTS.md` for the full agent rules.
