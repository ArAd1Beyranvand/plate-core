{{> _common}}

## Task {{task}}: {{lang_name}} holder app

Build the holder in `ports/{{lang}}/` exactly as ROADMAP.md "Holder spec" describes (country/spec
list, plate with region caption, come-in/go-out buttons with a 60 ms stagger, keypad rules,
verdict line). Use the D2 holder target for {{lang_name}}. Add a headless test that loads every
country and builds its plate. Add the command that launches it to `portctl.json` as `"holder"`.

Contract: {{contract}}
