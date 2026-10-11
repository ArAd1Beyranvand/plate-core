# migration_analyzer

Produces a per-country report for the slot → field migration (TYPE 1: merge
adjacent slots into one field of length n; TYPE 2: collapse specs that differ
only in a register's cell count into one spec with a min..max field). A local
Ollama model judges; deterministic facts come from the prepass and are never
replaced by model output.

Nothing here touches any package. Run everything from this folder.

## 1. Dump the specs (Dart)

```sh
python3 analyzer/gen_registry.py   # discovers packages + public catalogues → pubspec.yaml, registry.g.dart
flutter pub get
flutter test dump_specs.dart       # → out/specs/<country>.json, out/validators/<country>.txt
```

`flutter test` is only the runner: plate_core imports `dart:ui`, which
`dart run` cannot load. Specs discovery could not reach (lookup functions with
`int`/`String` parameters, private caches, empty packages) are listed in each
dump's `warnings`.

## 2. Prepass (Python, no model)

```sh
python3 analyzer/prepass.py [country ...]   # → out/prepass/<country>.json
```

## 3. Run the model

Start Ollama (`ollama serve`) with a model pulled (an instruction-tuned 7–14B
model with JSON output works; e.g. `ollama pull qwen3:14b`). Use num_ctx ≥ 8192:
prompts are capped at about 6k tokens.

```sh
python3 analyzer_gui.py
# or headless:
python3 analyzer_cli.py --list-models
python3 analyzer_cli.py --country yemen --model qwen3:14b
python3 analyzer_cli.py --model qwen3:14b --skip-done      # all countries, resume
```

The GUI's "Rebuild dumps/prepass" runs steps 1–2.

## Output

```
out/specs/<country>.json       dump (step 1)
out/validators/<country>.txt   validator source, as a hint
out/prepass/<country>.json     facts: type1 runs, type2 clusters, near misses
out/units/<country>/<unit>.json  one cached model answer per unit
out/reports/<country>.md|.json written as each country finishes
out/reports/INDEX.md           all countries so far
out/progress.log               one line per finished country
```

## Resume

Each unit's answer is cached as soon as it arrives, so a crash or Stop loses
at most the unit in flight. Rerunning a country reuses cached successes and
redoes only failed units and the synthesis ("Re-run failed"). The GUI asks on
startup whether to skip countries that already have a report; `--redo`
(CLI) or answering "No" (GUI) discards the cache.
