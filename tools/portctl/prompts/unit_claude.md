{{> _common}}

## Task {{task}}: port one {{lang_name}} country unit

Dart: `{{dart_path}}` → `{{target_path}}` (replace the stub). Test: `{{test_path}}` (generated, do not
edit). Run `{{oracle}}` in `ports/{{lang}}` until it is green.

Exemplar: {{exemplar}}

Keep reason strings byte-identical (they are the contract) and honour the file's `TODO({{lang}})`
notes. Local models will copy this file's shape, so use plain constructs: no clever helpers, and the
imports the generated code expects.
