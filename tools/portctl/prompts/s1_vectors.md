{{> _common}}

## Task {{task}}: conformance vectors (S1, D9)

Write `plate_number_holder/test/port_vectors_test.dart`, run it with
`flutter test --no-pub test/port_vectors_test.dart` from `plate_number_holder`, and have it write
`ports/vectors/`:

- `validators/<ClassName>.json` for EVERY class extending `PlateValidator`/`GatedPlateValidator` in
  every `*_plate` package: accept and reject cases, each with input slots and the exact expected
  result (reason strings byte-identical, H-notes). Generate cases from the regexps/alphabets, plus
  edge cases (empty, too long, wrong script, boundary values). Aim for ≥ 8 cases per class.
- `resolvers/<name>.json` for every `[D4-code]` resolver: input → output pairs over its domain or a
  representative sample.
- `core/*.json` for plate_core: layout boxes (H10, H17, H18), input-machine transitions (D7, D8),
  restriction/validation results, stagger/cue timings (H11), and glyph/cluster splitting (H21, H22).
  Group them as the S2 parts are: values, alphabet, layout, input, timing.
- `render/*.json`: display lists for a sample of specs × values × themes (D1).

Each file is `{"cases": [{"name", "input", "expect"}...]}` plus whatever a case needs. Describe the
format in `ports/vectors/FORMAT.md`. Every port's tests read these files directly, so they are the
oracle for all three languages.
