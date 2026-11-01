{{> _common}}

## Task {{task}}: bring the existing {{lang_name}} port in line with WEB_ARCH.md

`ports/{{lang}}/` was scaffolded and partly ported (core, and render or more) before the web
architecture existed. It must end up as independently built, iframe-embedded one-country components
(`claude/port/WEB_SPEC.md`, decisions W1… in `claude/port/WEB_ARCH.md`). Fix now what would otherwise
break later. Do not port anything new.

1. Scaffold: wire in the browser target WEB_ARCH.md chose for {{lang_name}} (build tool, config,
   dependencies) next to the existing test setup. A trivial entry that imports the core must build.
2. Audit every existing source file for things that target can't run (threads, file or process I/O,
   native-only libraries, platform font or text APIs, and for Python anything not pure-Python or
   newer than the browser runtime's CPython). Fix them, or isolate them behind the seam WEB_ARCH.md
   names.
3. Module boundaries: core, keypad and render must import no country, and nothing may build a
   global list of countries eagerly. If a countries index exists, make it lazy.
4. `portctl.json`: keep every existing key and add `"web_check"`: the browser-target build of the
   trivial entry.

List what you changed and anything you deferred to S3/S4/S5 at the end. Leave `oracle_all` and
`web_check` green.
Contract: {{contract}}
