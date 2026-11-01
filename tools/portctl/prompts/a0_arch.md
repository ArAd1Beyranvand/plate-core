{{> _common}}

## Task {{task}}: web architecture: analysis and migration plan (no code)

Read `claude/port/WEB_SPEC.md` in full: it is the user's new direction. One central Flutter gallery
(`plate_number_holder`) and every country × language plate built as an independent web app,
lazy-loaded into an iframe only when the user selects it. This task only analyses and proposes. Do not
edit the gallery, the Dart packages or `ports/`. Delete nothing.

Investigate, citing files and line numbers:

1. How the gallery works: entry points (`lib/main.dart`, `lib/minimal`, `lib/newdesign`,
   `lib/screens`), routing (`#/plates/<country>`), country pages, the playground, and how its
   `pubspec.yaml` pulls in all ~180 `*_plate` packages.
2. How country pages import and render plate components. Find the single place where a page goes
   from a country id to a widget, because that is where the iframe host plugs in.
3. The port work so far: `claude/port/ROADMAP.md` (D2 targets, the holder spec), `ports/ts`, `ports/py`,
   `ports/data`, `ports/vectors`, and the portctl plan (`tools/portctl/DESIGN.md`, `plan.py`).
4. What of that work is reusable as an independent component app. The S5 "holder" per language is
   replaced by a one-country embed shell.
5. The architecture: the registry (its format, where it lives, and how it is generated from build
   outputs instead of hand-edited), the deploy URL layout, the iframe host in Flutter Web
   (`HtmlElementView` / `package:web`, created on tab select, disposed on switch), and the
   postMessage protocol (message types, versioning, origin checks, sandbox flags, auto-height,
   loading and error states, theme/locale handoff).
6. Browser limits, measured or sourced, not guessed:
   - Python: Pyodide is decided and proven (`ports/py/web/check.mjs`, `plates.ui.dom`). Cover
     startup cost, the runtime shared and cached across countries, and how a country's modules are fetched.
   - Kotlin: Kotlin/Wasm vs Kotlin/JS, Compose Multiplatform for Web vs a plain canvas/DOM layer, and
     bundle size per country.
   - TypeScript: Vite multi-entry or one library plus per-country entries, and shared chunk hashing.
   - Flutter: per-country builds (each a separate `flutter build web` with its own `main`,
     CanvasKit/skwasm from a shared CDN path) vs deferred imports in the gallery. Weigh the build time
     of ~180 × builds.
7. Building without duplication: a shared runtime chunk per language (core + keypad + render) that is
   cached once, plus a thin per-country entry. Build one country, all countries, or only the changed
   ones (dirty detection from git).
8. Migration in reversible steps, keeping the gallery working at every step: Flutter tab = today's
   in-app widget first; iframe languages behind the registry; the Flutter per-country builds last.

Deliverable: `claude/port/WEB_ARCH.md` with these sections, in this order:
`## Current gallery`, `## Reuse`, `## Decisions` (numbered **W1**, **W2**, … each one line of decision +
one line of why, in the ROADMAP style), `## Registry`, `## Protocol`, `## Browser limits`,
`## Build and deploy`, `## Migration`, `## Open questions`.
Also write `claude/port/web/components.schema.json` (JSON Schema of the registry) and
`claude/port/web/protocol.md` (message table). Both are drafts for the user to approve at this
phase's gate. Keep it tight: decisions, not essays.
