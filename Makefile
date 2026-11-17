.RECIPEPREFIX = >
.DELETE_ON_ERROR:
COUNTRY ?= Brazil

all: report.md report.docx
.PHONY: all clean

build/rows.jsonl: data/countries.tsv steps/rows.sh
> steps/rows.sh $< $@

build/table.md: build/rows.jsonl steps/table.sh lib/suppress_repeat.mlr lib/align.lua
> steps/table.sh $< $@

build/letters.md: build/rows.jsonl steps/letters.sh lib/letter.mlr
> steps/letters.sh "$(COUNTRY)" $< $@

report.md: prose/intro.md build/table.md build/letters.md steps/report.sh
> steps/report.sh $@ prose/intro.md build/table.md build/letters.md

report.docx: prose/intro.md build/table.md build/letters.md steps/report.sh
> steps/report.sh $@ prose/intro.md build/table.md build/letters.md

clean:
> rm -rf build report.md report.docx
