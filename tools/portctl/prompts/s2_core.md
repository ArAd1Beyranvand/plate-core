{{> _common}}

## Task {{task}}: {{lang_name}} core · {{what}}

Port these Dart files from `plate_core` into `ports/{{lang}}/` (core package, layout as in
`portctl.json`):

{{files}}

Their `TODO({{lang}})` notes, which are requirements:

{{todos}}

Earlier core parts are already ported; build on them, don't duplicate them. Add tests that run the matching
`ports/vectors/core/*.json` vectors. Pure logic only (D1): no UI framework in core.

Contract: {{contract}}
