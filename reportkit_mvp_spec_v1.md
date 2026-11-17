reportkit/
├── pyproject.toml          # python >=3.14, no runtime dependencies; pytest as dev dependency
├── src/reportkit/
│   ├── __init__.py         # public API exports
│   ├── rows.py             # read_jsonl -> Rows, column checks
│   ├── spec.py             # tomllib parse, validation, nearest-match hints (difflib)
│   ├── render.py           # render_iter, escapers, Raw
│   ├── templates.py        # file-template compiler (Formatter().parse, line-by-line)
│   ├── blocks.py           # Block protocol, REGISTRY, TableBlock, PerRowBlock, TextBlock
│   └── cli.py              # argparse: cols | check | build
├── tests/
│   ├── fixtures/           # rows.jsonl, brazil.jsonl, hostile.jsonl
│   ├── templates/          # ok, bad-braces, bad-spec, unknown-field, bad-template
│   └── golden/             # table.md, letter-brazil.md, report.md
└── examples/countries/     # countries.tsv, Makefile, spec.toml, templates/letter.md.tmpl