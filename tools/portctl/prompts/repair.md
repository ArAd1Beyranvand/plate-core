{{> _common}}

## Task {{task}}: repair {{n}} {{lang_name}} country units

Each unit below is one Dart file with `[D4-code]` logic. Port it into its target file so that its
test passes. Some come with a local model's rejected attempt and the oracle error. Others were too
large for the local model. Follow the style of the accepted exemplar `{{exemplar}}` (its port is at
the matching `unit_path`). Run each unit's test with `{{oracle_unit}}` (fill in `{unit_test}`) from
`ports/{{lang}}`.

{{units}}

Do not change generated files or tests; if a vector looks wrong, say so in your summary instead.
