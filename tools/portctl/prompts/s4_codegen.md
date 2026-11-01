{{> _common}}

## Task {{task}}: {{lang_name}} country codegen (D3)

Write a generator in `ports/{{lang}}/` that reads `ports/data/` (see `ports/data/SCHEMA.md`) and emits
the source for all country packages: specs, alphabets, themes, tabulated `[D4-table]` resolvers,
assets references, and an index. Follow WEB_ARCH.md: each country is its own module and
entry point, and the index only maps ids to lazy imports, so a one-country build pulls in no other
country. Set `codegen` in `portctl.json` to the command that runs it.

For every `[D4-code]` unit (a Dart file such as `albania_plate/lib/src/albania_validators.dart`)
the generator must:

1. Emit, at `unit_path`, a STUB only if the file does not exist yet. Never overwrite an existing
   unit: those are hand-ported, partly by small local models. The stub has the final public
   signature and throws "not ported".
2. Emit, at `unit_test_path`, the unit's test, always regenerated. It runs
   `ports/vectors/validators/<Class>.json` / `resolvers/<name>.json` against the unit's classes.
3. Wire the generated specs to the unit's names.

Then hand-port two or three units yourself to prove the shape: pick a small validator and a small
resolver. They become the style the local models copy, so keep them minimal and idiomatic. Leave
`oracle_all` green except for tests of units that are still stubs. Make `compile` succeed with the
stubs.

Contract: {{contract}}
