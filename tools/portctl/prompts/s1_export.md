{{> _common}}

## Task {{task}}: Dart exporter (S1, D3)

Write `plate_number_holder/test/port_export_test.dart` (the holder already depends on every country
package). Run it from `plate_number_holder` with `flutter test --no-pub test/port_export_test.dart`; pub
is offline here, so `--no-pub` is required.

It writes JSON (UTF-8, 2-space indent, stable key order) to `ports/data/` (relative to the repo root):

- `countries/<package>.json`, one per `*_plate` package: every spec it exports (all layouts,
  sections, slots, alphabets by id, restrictions, theme, assets, region data, metadata). It is
  everything a port needs to rebuild the spec without code.
- `alphabets.json`: every alphabet in `plate_alphabet` and the country alphabets, glyphs as code
  points as well as strings (H19, H21).
- `themes.json`, if themes are shared.
- `index.json`: package → country ids and spec ids.

`[D4-table]` resolvers (functions of a finite key domain) are tabulated: enumerate the domain and
store the table. `[D4-code]` logic is NOT exported; record its class/function name so codegen can
reference the hand-ported unit.

Assert `specProblems(spec)` is empty for every exported spec. Fail loudly on anything you cannot
serialise rather than skipping it. Document the JSON shape in `ports/data/SCHEMA.md`, since codegen in
three languages reads it.
