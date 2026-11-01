{{> _common}}

## Task {{task}}: registry + embed protocol, shared by every language

Implement WEB_ARCH.md "Registry" and "Protocol" (W-decisions are binding) as the single source the
gallery and all four embed shells use:

- `ports/web/components.schema.json` (from the approved draft) and `ports/web/protocol.md`.
- A registry generator (Python, 3.10, stdlib only) at `ports/web/registry.py`. It scans the deploy
  output for built components and writes `components/index.json`. A missing country × language is simply
  absent, never an error. `--check` validates against the schema.
- Protocol fixtures `ports/web/protocol_vectors.json`: valid and invalid messages in both directions.
  Every embed shell and the Flutter host must pass them.
- A minimal TypeScript reference client `ports/web/embed-client/` (no framework, < 150 lines)
  implementing the component side of the protocol. Shells may copy or import it.

Verify with `python3 ports/web/registry.py --self-test` (add it) and leave it green.
