{{> _common}}

## Task {{task}}: {{lang_name}} embeddable one-country component app

This replaces the old per-language holder: there is no {{lang_name}} gallery. Build in
`ports/{{lang}}/` the embed shell from WEB_ARCH.md, for the {{lang_name}} browser target it chose.
The shell is a page that shows ONE country's plate (spec selector, input, keypad, verdict line, all
reused from S2–S4) and speaks `ports/web/protocol.md`: it reads the initial config, reports loading,
ready, size changes, value changes and errors, and accepts the gallery's actions. It validates the
parent origin and passes `ports/web/protocol_vectors.json`.

The country is chosen at build time by its own entry point, not at run time from a bundled list.
Opening Germany must not download any other country's code (WEB_SPEC level 2). The language runtime
and shared core live in one content-hashed shared asset so the browser caches them across countries.

Loading (W11): `index.html` has an inline splash in plain HTML/CSS that paints at once, says what is
starting (e.g. "Starting Python…"), may post `progress`, and is removed at `ready`. Kotlin: `index.html`
picks the Wasm or JS build by WasmGC feature detection and fetches only that one.
Keep the splash a template with slots for title, description, canonical and an `<h1>` plus a short text
about the country (W13 fills them later from `ports/data`).

Add a headless test that boots the shell for two countries and runs the protocol handshake.
Contract: {{contract}}
