{{> _common}}

## Task {{task}}: {{lang_name}} independent per-country builds

Make every country an independently buildable and deployable {{lang_name}} component (WEB_ARCH.md
"Build and deploy"). Add to `ports/{{lang}}/portctl.json`:

- `"web_build"`: builds one country into `deploy/components/{country}/{{web_lang}}/` (an `index.html`
  plus that country's entry; shared assets go to `deploy/shared/{{web_lang}}/<hash>/`, never copied per
  country).
- `"web_build_all"`: every country. Incremental: skip countries whose inputs did not change.
- `"web_out"`: `"deploy"` (relative to the repo root).

Then run `python3 ports/web/registry.py` so the new components appear in `components/index.json`. Build
germany and india, and check that germany's entry has no trace of india. portctl's smoke test checks
this independently after you finish.
Contract: {{contract}}
