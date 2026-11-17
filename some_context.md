Building and testing both orchestrators against the same step scripts before I rewrite the spec.

I wrote the updated spec as `reportkit-mvp-spec-v3.md`. It now has three layers: the tools (Miller, pandoc, one Lua filter), `steps/*.sh` scripts that hold all the commands, and a Makefile or `dvc.yaml` that only declares the graph. I ran both orchestrators over the same scripts, and they produced byte-identical `report.md`.

- **Pipeline contract:** one table of step, command, deps, output and params that both orchestrators translate from. The spec says to update the table, the Makefile and `dvc.yaml` together, and test T10 checks that the two orchestrators agree.
- **Step conventions:** run from the repo root, take positional arguments, use `set -euo pipefail`, write output atomically (temp file then `mv`), and report errors as `error[code]` on stderr.
- **Tested `dvc.yaml` and `params.yaml`:** the spec has the setup commands, plus a table of what reran for each kind of change:
  - changing only `params.yaml` reran just `letters` and the report stages;
  - editing a dependency whose output didn't change skipped the downstream stages;
  - a country with zero rows failed cleanly and left no partial file.
- **Phase 2 Python tool:** it replaces the body of one step script, so neither orchestrator changes. The spec also gives guidance for choosing Make or DVC and for translating the contract to Task, just, Snakemake or doit.

I only ran Make and DVC, so the other orchestrators' behavior comes from general knowledge and the spec flags that. I did not test:

- **Make and parameters:** Make ignoring a changed `COUNTRY` follows from its timestamp design, but I didn't run it.
- **pptx layout:** pptx builds, but I didn't check the layout.
- **docx byte-identity:** I only compare `report.md` byte-for-byte.

Two things I found while testing and added to the spec:
- DVC treats `${...}` as its own interpolation, so an unescaped `${field}` is a parse error and you have to write `\${...}`. Keeping Miller code in the scripts mostly avoids this.
- DVC deletes a stage's outputs before running it, so after a failure that stage's output is absent while downstream outputs stay stale until the next successful run.