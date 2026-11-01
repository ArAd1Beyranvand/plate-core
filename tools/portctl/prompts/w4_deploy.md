{{> _common}}

## Task {{task}}: deploy pipeline and performance budget

Implement WEB_ARCH.md "Build and deploy" end to end:

- `tools/web/deploy.py`: build the gallery and every changed component (all four languages, through
  each `portctl.json` `web_build` and `tools/web/build_flutter.py`), regenerate `components/index.json`
  and assemble one static site in `deploy/`. Hashed shared assets get immutable cache headers, and
  `components/index.json` plus every component `index.html` get revalidate (emit `_headers` or the
  equivalent for the chosen host). Updating one component must not rebuild the gallery.
- `tools/web/perf_check.py`: serve `deploy/` locally and, with a headless browser if one is
  installed (fall back to static analysis of the gallery's and components' asset graphs), assert:
  the homepage fetches no `/components/` URL and no deferred country `*.part.js` (W14); germany + python fetches only germany/python and
  `shared/py`; the gallery's initial transfer size stays under a budget recorded in the script.
  Exit non-zero on a breach.

Run both for germany and india in all available languages and leave them green.
