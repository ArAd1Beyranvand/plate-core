{{> _common}}

## Task {{task}}: {{lang_name}} · {{what}}

Port into `ports/{{lang}}/`:

{{files}}

`TODO({{lang}})` notes on them:

{{todos}}

Where a note assumes a desktop toolkit (Qt/PySide6, JVM Swing/Compose Desktop), the browser target in
`claude/port/WEB_ARCH.md` wins: keep the behaviour the note asks for, on that target.

The model layer (S2) is done. `render` is pure: spec + theme + values + part frames → a display
list, tested against `ports/vectors/render/*.json`. The UI layer paints that display list and places
native inputs at slot boxes (D2). Keep the animation timing in the core timing model (H11). Give the
UI layer at least one headless test (construct, set values, read back, check the display list).

Contract: {{contract}}
