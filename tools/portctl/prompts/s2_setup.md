{{> _common}}

## Task {{task}}: {{lang_name}} project scaffold

Create `ports/{{lang}}/` following ROADMAP D2 for {{lang_name}}. Use the toolchain that is installed:
Node 22 + npm, Java 21 (no global gradle: generate and commit a Gradle wrapper), and Python 3.10.12
on the host (Python itself ships to the browser as Pyodide, see `ports/py/web/check.mjs`).

- The browser target WEB_ARCH.md chose for {{lang_name}} (e.g. Vite, Kotlin/Wasm or JS, Pyodide),
  wired in now so later parts never use APIs that target lacks. Tests may still run on the host.
- A test runner wired to `ports/vectors` (a helper that loads a vector file by relative path).
- One smoke test that loads a vector file, so the oracle is green from the start.
- Package layout matching the later parts: core (values, alphabet, layout, input, timing),
  render, ui, keypad, countries/<country>/…, holder.
- `ports/{{lang}}/portctl.json`:
  ```json
  {
    "oracle_all":  "<command, run in ports/{{lang}}, that type-checks/compiles and runs every test>",
    "oracle_unit": "<command running one unit's tests; use {unit_test} for its path>",
    "compile":     "<compile/type-check only>",
    "codegen":     "<command that regenerates countries from ports/data (S4 fills it in; leave a no-op)>",
    "unit_path":      "<path of a hand-ported country unit, from {pkg} {country} {Country} {stem} {Stem}>",
    "unit_test_path": "<path of that unit's test>"
  }
  ```
  A unit is one Dart file holding `[D4-code]` (e.g. `albania_plate/lib/src/albania_validators.dart`
  → stem `albania_validators`). Choose paths idiomatic for {{lang_name}}.

The oracle commands must be non-interactive, offline after the first install, and fast.
