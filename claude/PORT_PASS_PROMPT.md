# One pass over the whole `plate` monorepo: port roadmap TODOs + make it shorter

You are going to walk this monorepo **once**, top to bottom, and leave it in a state where three
later projects — a **Python**, a **TypeScript** and a **Kotlin** version of `plate_core`,
`plate_alphabet`, `plate_keypad`, every country package, and a small animated holder per
language — can be done mechanically, without anyone re-reading the Dart to rediscover the hard
parts. At the same time you make the Dart itself shorter.

No Python, TypeScript or Kotlin code is written in this pass. The outputs are:

1. `TODO(py)`, `TODO(ts)`, `TODO(kt)` comments in the Dart, at the exact places a porter will
   trip.
2. `claude/port/ROADMAP.md` — the decisions and hazards register those TODOs cite.
3. `claude/port/inventory.csv` — one row per country package, its portability class.
4. Shorter Dart: behaviour-preserving cuts, each its own commit.
5. `claude/port/PROGRESS.md` — the ledger that makes this pass resumable across sessions.

---

## 0. Overrides to `CLAUDE.md` for this pass

`plate_core/CLAUDE.md` still applies (no widget-returning functions, variation is data, fixed
canvas layout, analyzer clean, tests green, commit per unit). Two of its rules are suspended,
because this task is the survey:

- "Don't survey the repo / read only files named" → you **must** read every file in scope.
- "Modify only the files the prompt names" → every file in scope is named by this prompt.

Everything else stands. In particular: no progress narration, no summaries of what you read.

---

## 1. Scope and order

Work in this order. Each step ends with analyzer clean, tests green, commit, ledger updated.

| Phase | Target | How |
|---|---|---|
| P0 | Whole repo, read-only | Write `ROADMAP.md` skeleton (sections 3 and 4 below, refined by what you see), write and run `tools/port_inventory.dart`, produce `inventory.csv`. |
| P1 | `plate_core/lib/src/model`, `theme`, `validators` | Shorten, then annotate, file by file. |
| P2 | `plate_core/lib/src/input` | Same. |
| P3 | `plate_core/lib/src/animation` | Same. |
| P4 | `plate_core/lib/src/widgets` | Same. `plate_canvas.dart` (≈1.7k lines) last, in several commits. |
| P5 | `plate_core/test` | Annotate only: which tests become shared conformance vectors (see D9). |
| P6 | `plate_alphabet` | Shorten, annotate. |
| P7 | `plate_keypad` | Shorten, annotate. |
| P8 | Country packages | In batches (section 7). |
| P9 | `plate_number_holder` | Annotate only what the three small holders must reproduce; list dead code in the report, delete nothing without my confirmation. |

Within each file: **shorten first, commit, then annotate, commit.** TODOs must sit on the final
code, and the two kinds of change must be revertable separately.

---

## 2. TODO format

```dart
// TODO(ts): [H3] equality is by id only; never compare specs structurally — key Maps by spec.id.
// TODO(kt): [H3] not a data class: override equals/hashCode on id, or the generated ones break it.
// TODO(py): [H3] @dataclass(eq=False) + __eq__/__hash__ on id.
```

Rules:

- Exactly three tags: `TODO(py)`, `TODO(ts)`, `TODO(kt)`. Nothing else (`TODO(all)` does not exist).
- One line each, ≤ 110 chars. Start with a register id in brackets (`[D4]`, `[H12]`) when one applies,
  so the rationale lives once in `ROADMAP.md` and the comment stays short.
- A note that is the same for all three languages is written three times, but then it almost
  always belongs in `ROADMAP.md` as a new `H` entry, and the three TODOs just cite it.
- Placement: on the declaration (class, field, method, top-level function, const) the note is
  about, directly above its doc comment. Not inside method bodies unless it is about one line.
- Density: only where translation is **not** obvious. A `final double width` needs nothing.
  A `CustomClipper<Path>` field, a `TextDirection`, a `ValueNotifier`, an id-based `==`, a rune
  loop, a `SchedulerBinding` hack, a RegExp — those need one.
- Say **what to do**, not that something is hard. Bad: `TODO(kt): careful with this`.
  Good: `TODO(kt): [H7] iterate codePoints(), not chars — Persian/Hangul are fine, emoji/astral are not.`
- A Flutter-only mechanism with no port counterpart gets `TODO(xx): drop — <why>`, so its absence
  in the port is a decision, not an omission.
- Write like a human engineer. No "Note that", no "It's important to", no restating the code.

---

## 3. Decisions register (pre-filled — keep the ids; refine wording, add D-entries if needed)

Treat these as decided unless the code proves one wrong; if it does, change the entry and say
why in the final report. Copy them into `ROADMAP.md`.

- **D1 · Three layers in every language.**
  `model` (pure: spec, alphabet, box, shapes, section layout, restriction, validator, controller
  logic, layout builders, animation timing model) → `render` (spec + theme + values + part frames →
  a **display list** of rects, rounded rects, paths, text runs, images; still pure) → `ui` (a thin
  per-platform painter over the display list, plus native input fields placed at slot boxes).
  The Dart today mixes the second layer into widgets; mark every place where layout math lives
  inside a widget with `[D1]` — that math moves to `render` in every port.
- **D2 · Targets.**
  TS: framework-free core (`model`, `render`) + SVG painter + DOM inputs absolutely positioned over
  the SVG `viewBox` (the same `FittedBox > SizedBox > Stack > Positioned` model, in CSS); holder =
  Vite + vanilla TS. Kotlin: Kotlin Multiplatform, core in `commonMain` (no `java.*`), UI in Compose
  Multiplatform, holder runs on Desktop (JVM) first, Android second. Python ≥ 3.12: same goal as
  the others — an input + display plate widget. Core + `render` in pure Python; UI = PySide6
  (`QPainter` over the display list, `QLineEdit`s placed at slot boxes, animation on
  `QVariantAnimation`); holder = a PySide6 window. An SVG painter comes free from the display list.
- **D3 · One source of truth for country data.** ~190 countries × 3 languages cannot be hand-ported.
  Plan: a Dart exporter walks every `PlateSpec`/`PlateAlphabet`/`PlateCountry`/`PlateTheme` and
  writes JSON; per-language codegen turns JSON into const-like source. Everything a spec holds
  that is not JSON-able must therefore get a portable form — see H1–H4. Annotate each such
  place `[D3]`.
- **D4 · Logic that cannot be data is hand-ported, but small.** Validators, label/theme/region
  resolvers. Where a resolver is really a lookup table (letter → theme, code → caption), mark it
  `[D4-table]`: it becomes declarative data in the export. Where it is real logic, `[D4-code]`.
- **D5 · Packaging.** Not 190 packages per language. Python: one distribution, `plates.countries.<name>`
  submodules, assets via `importlib.resources`. TS: one npm package, subpath exports per country
  (tree-shakable). Kotlin: core module + one `countries` module, package per country. Annotate
  pubspec `flutter: assets:` blocks with how each language ships the file.
- **D6 · Assets.** Flags: prefer converting SVG flags to `PlateDrawing` shapes / path data at export
  time (no runtime SVG dependency; Compose has no built-in SVG). Raster decals stay files.
  Fonts: the glyph style uses the platform default font today — each port must bundle explicit
  fonts per script (Latin, Arabic/Persian, CJK, Hangul, Devanagari, Myanmar, Thai/Lao, Ethiopic…)
  or plates will look different on every platform. Mark every text-style site `[D6-font]`.
- **D7 · Reactivity.** `ChangeNotifier`/`ValueNotifier`/`ValueListenable` → Python: a minimal
  observable (subscribe/unsubscribe callbacks, no framework); TS: tiny signal/store with
  `subscribe()` compatible with `useSyncExternalStore`; Kotlin: `StateFlow` in core, collected in
  Compose. The three listening grains (per slot, completed, whole) must survive.
- **D8 · Input.** `PlateInputMachine` is half pure state machine (active index, submit, backspace,
  advance, focus-first-empty) and half Flutter focus/`TextEditingController`. The pure half is
  ported; focus is a per-platform adapter. `PlateInputSource`/`SlotBehavior` semantics map to:
  web `inputmode`/`virtualkeyboardpolicy`; Compose `KeyboardOptions` + `LocalSoftwareKeyboardController`
  + key events; PySide6 hardware keys only (`keypadFirst` and IME modes may be N/A — say so).
- **D9 · Conformance vectors.** The Dart is the reference. A Dart tool will emit JSON test vectors
  (input sequence → values, `isCompleted`, `rejection`, validation reason, `text()`, section
  `layout()`, `PlatePartId.allOf`, stagger delays, later the display list). All three ports run the
  same vectors. In P5, mark each existing test `TODO(py|ts|kt)` only where it can't become a vector.
- **D10 · Port order.** TS first (Dart semantics are closest: same RegExp flavour, UTF-16 strings,
  similar async), then Kotlin (Compose ≈ Flutter mental model, Skia text), then Python.

---

## 4. Hazards register (seed list — add what you find, keep ids stable)

- **H1** `CustomClipper<Path>` in `PlateSection.fill(shape:)` and `PlatePanel.shape` — not data.
  Portable form: path in plate coordinates (SVG path string or `PlateShape` list).
- **H2** `ImageProvider` in `PlateDecal.image` — Flutter type. Portable form: asset reference
  (`package` + `path`), like `PlateAsset`.
- **H3** Identity equality by `id`/`code` on `PlateSpec`, `PlateAlphabet`, `PlateCountry`.
  Kotlin data classes and Python dataclasses generate structural equality; TS has none.
- **H4** Function-typed fields: `resolveTheme`, `PlateLabel.resolve`, `resolveRegion`,
  validators. Not serialisable (D3/D4).
- **H5** `const` canonicalisation and deep immutability. Python: frozen dataclasses, tuples,
  `MappingProxyType`; TS: `readonly` + `as const` + `Object.freeze`; Kotlin: `val`, read-only
  `List`, `object` singletons. The static `_expanded` cache of pattern alphabets → per-instance
  lazy (`by lazy`, lazy getter, `object.__setattr__` in `__post_init__` or `cached_property`).
- **H6** Lists built by `plateRegister` etc. make specs `static final`, not `const` — irrelevant in
  ports, but codegen must emit the expanded slots, not the call.
- **H7** Strings are iterated by **rune** (code point). JS/Kotlin strings are UTF-16: use
  `Array.from`/`for…of` and `codePoints()`. Python `str` is code points already. Check every
  alphabet for **grapheme clusters** (combining marks in Devanagari, Bengali, Myanmar, Thai, Lao,
  Khmer…): a code-point loop splits them. Record which alphabets are affected in the inventory.
- **H8** Case folding in `canonical()`: `toUpperCase` on `ß`, Turkish/Azeri dotted i, Greek final
  sigma. Python/JS/Kotlin each have edge cases; vectors must cover them.
- **H9** RegExp flavour. Dart ≈ JS. Python `re`: `\d`, `\w` match Unicode digits/letters unless
  `re.ASCII` — use explicit classes. Kotlin common `Regex` delegates to the platform engine (JVM vs
  JS vs Native differ). Annotate every `RegExp(` in validators.
- **H10** `TextDirection`, `Alignment` (x,y ∈ [-1,1]), `Axis`, `EdgeInsets`, `Offset`, `Size`,
  `Rect`, `Color(0xAARRGGBB)` — tiny value types each port defines once in `model`; Color is ARGB
  (CSS wants RGBA, Compose takes ARGB Long, Qt `QColor.fromRgba` ARGB).
- **H11** `Duration`/`Curve` (`Curves.easeInOutCubic` …) — ports need a curve table with
  cubic-bezier control points identical to Flutter's; durations as integer ms.
- **H12** Text metrics: `fontSize = slotHeight * 0.72`, `height: 1.0`, strut, `TextPainter`
  measuring. Baselines differ per engine; parity is "within tolerance", not pixel-exact.
- **H13** Path ops: `Path.combine(difference)` (rings, crescents), path-length measuring for the
  border/divider `draw` effect. SVG: `fill-rule="evenodd"` + `stroke-dasharray`/`getTotalLength`;
  Compose: `PathOperation`/`PathMeasure`; Qt: `QPainterPath.subtracted`/`percentAtLength`; Pillow:
  none — rasterise via `skia-python`/`cairo` or polygonise.
- **H14** `SchedulerBinding` post-frame notification hacks, `InheritedWidget` scopes,
  `RenderProxyBox`, `Material`/`ThemeData` selection theme — Flutter lifecycle artefacts. Ports drop
  them (`TODO(xx): drop — …`) or replace with an explicit context object.
- **H15** Theme cross-fade (`_ThemeTween`, `Color.lerp`) — ports need a lerp for every theme field.
- **H16** `defaultTargetPlatform` switch — per-platform default in each port.
- **H17** Dart records (`({leaves, dividers})`, `(PlateSection, Rect)`) → Python `NamedTuple`,
  TS object type, Kotlin small `data class` (structural equality is fine here).
- **H18** Sealed hierarchies (`PlateGraphic`, `PlateShape`, `PlateAsset`) → TS discriminated union
  with a `kind` tag (also what the JSON export uses), Kotlin `sealed interface`, Python union +
  `match`.
- **H19** `abstract final class X { static const … }` namespaces → Python module-level constants,
  TS `export const X = {…} as const`, Kotlin `object`.
- **H20** Package-relative asset resolution (`SvgPlateAsset(path, package:)`) — each port needs its
  own resolver (D5/D6).

---

## 5. Shortening — rules

Goal: fewer lines and fewer concepts, same behaviour. Allowed: deleting dead code, merging
duplicates, newer Dart syntax, collapsing tiny files, replacing a nullable-fields-plus-flags
class with a sealed hierarchy, turning asserts into a function that returns problems.

Hard limits:

- **Behaviour-preserving.** `flutter test` green in every touched package, goldens in country
  packages unchanged. If a golden moves, the change is wrong; revert it.
- Public API changes are allowed only when they shorten the 190 country packages too, and are
  applied to **all** of them in the same commit (codemod via a script in `tools/`, not by hand).
  Record each in `plate_core/CHANGELOG.md` under `Unreleased`. Don't bump versions.
- First check the SDK: `dart --version`; the workspace says `>=3.10.0`. Use a feature only after a
  one-file compile check proves it works here.
- Readability beats line count. Don't golf.
- One idea per commit: `shorten(core): <what>` / `todo(core): annotate <file>`.

Seed candidates (verify each; skip any that isn't a real win):

- **Dot shorthands** (Dart 3.10) across the const data: `.rtl`, `.chosen`, `.panel`, `.plain`,
  `.columns([...])`, `.fill(.panel)`, enum values in `PlateAnimationStyle.defaults`. This alone is
  the biggest cut in the country packages. Apply where the context type is obvious.
- **Null-aware elements** (`[?x]`) and **wildcards** (`_`) where they remove a branch or a name.
- `PlateFill`: private role enum + four nullable fields → sealed `PlateFill` with `color`,
  `stripes`, and three role singletons. Ports want exactly that shape (H18).
- `PlateSection`: nullable `fill`/`axis` → sealed leaf / split. Same reason.
- `PlateSpec.noPanel` + always-present `panel` → `PlatePanel? panel`, if callers can be fixed
  cheaply (check every country).
- `PlateController.fromValues` duplicates the main constructor.
- `PlateController.attach` re-implements `_notifyOutsideBuild`.
- Rune splitting is written three ways (`PlateSlot.accepts`, `PlateAlphabet._each`, the private
  `characters` extension in `plate_controller.dart`, which also shadows `package:characters`'
  name). One helper.
- `PlateNumber` vs `PlateController.values`/`plateNumber` — is `PlateNumber` still pulling weight?
  `PlateMode` living in `plate_number.dart`.
- `debugValidateSpec`: asserts → `List<String> specProblems(spec)` + an assert wrapper. Shorter
  tests, and it is what every port needs anyway (no asserts in Python `-O`, none in TS).
- `PlateInputMachine`: split the pure state machine (D8) from focus plumbing if it shortens both.
- `plate_alphabet` vs country packages: e.g. `iran_plate` imports a local `persian_alphabets.dart`
  while `plate_alphabet` also ships `persian_alphabets.dart`; `germany_alphabets.dart` is a 74-byte
  file. Find every duplicated or re-export-only alphabet file; keep one home.
- `plate_alphabet/lib/plate_alphabet.dart`: ~250 export lines — check whether consumers import
  per-country files directly; if so a shorter barrel or none.
- Per-country file layout: many packages split `*_country.dart`, `*_colors.dart`, `*_alphabets.dart`
  into tiny files. Pick **one** canonical layout (e.g. `src/<c>_plates.dart` holding country,
  colours and specs; `src/<c>_validator.dart`; `src/<c>_regions.dart` for big tables), apply it
  everywhere. Uniform layout is also what the exporter and codegen want.
- Stray files at repo root: `switzerland_colors.dart`, `switzerland_country.dart`,
  `switzerland_missions.dart`, `switzerland_themes.dart` — belong in `switzerland_plate` or are
  leftovers; check and move or delete.
- `PlateTheme`: `copyWith`/`==`/`hashCode`/`_props` boilerplate — keep unless a shorter,
  equally clear form exists.
- Root-level reports (`*_REPORT.md`, `REVIEW_GUIDE_FA.md`, …) and hidden scratch dirs (`.vf2`,
  `.vf4`, `.kwref`, `.plateref`): **list** them in the report with a keep/delete suggestion;
  don't delete.

---

## 6. Per-file checklist

For every file, ask in this order and act:

1. Is any of it dead (unexported and unreferenced, superseded, only used by a deleted path)? → delete.
2. Is any of it duplicated elsewhere? → merge.
3. Would newer syntax or a sealed type make it shorter without hiding intent? → rewrite.
4. Commit. Then:
5. Which declarations depend on Flutter (`widgets`, `foundation`, `scheduler`, `material`,
   `cupertino`)? For each: portable equivalent per language, or `drop — why`.
6. Which hold non-data (functions, clippers, image providers)? → H1/H2/H4, D3/D4.
7. Strings: rune loops, case folding, RegExp, directionality? → H7/H8/H9.
8. Equality, immutability, const, caches? → H3/H5.
9. Geometry, paths, text measuring, colours, curves? → H10–H13.
10. Is layout math living inside a widget? → `[D1]` on it.
11. Add the TODOs. Commit.

---

## 7. Country packages (P8)

First, `tools/port_inventory.dart` (written in P0) produces `claude/port/inventory.csv` with, per
package: spec count; uses of `resolveTheme` / `PlateLabel.resolve` / `resolveRegion`; validator
class count and `RegExp` count; `shape:` / `CustomClipper` count; decals (image vs drawing);
`PlateAsset` kinds; fonts; alphabets with multi-code-point entries, combining marks (H7) or
non-BMP characters; lines of code. And a **class** column:

- `A` pure data — exporter + codegen handle it, no TODOs needed beyond the barrel file.
- `B` data + table resolvers — `[D4-table]` TODOs.
- `C` hand-port needed — validators/resolvers with logic, clippers, raster decals.

Then process countries in batches of ~10, `C` first (they're where the knowledge is), `A` last
(those mostly get the shortening codemods and one TODO line each in the barrel). Use subagents per
batch if your context gets heavy; hand each one sections 2–6 of this prompt and the current
`ROADMAP.md`, and have it return only diffs + new H-entries. Commit per batch:
`shorten(countries): batch N` / `todo(countries): batch N`.

---

## 8. Holder (P9)

The three new holders are deliberately small: country list → spec list → the plate, with
"play in" / "play out" / "stagger" buttons (`PlateAnimationController.comeInAll/goOutAll`,
`PlateStagger.sequence`), a spec switch that runs `specTransition`, editable slots with the
language's keypad, and the validation verdict below the plate. Read `plate_number_holder` only
to extract that list (and anything I'd miss). Put it in `ROADMAP.md` under "Holder spec".
In the Dart holder, annotate only `minimal/main.dart` and the plate/live-plate widgets.
List what looks dead (`screens/gallery` vs `newdesign`, built web artefacts committed at the
package root, `*.zip`, `extract_comments.py`) in the report for me to decide.

---

## 9. Ledger and stopping

`claude/port/PROGRESS.md`: one line per file or batch — phase, path, `shortened: -N lines`,
`todos: py/ts/kt counts`, commit hashes. Update it in the same commit as the work. On a new
session, read it and continue from the first unfinished line.

Stop and ask me only when: a shortening needs a public API break you can't codemod safely; a
golden changes and you can't tell whether the old one was wrong; a decision in section 3 looks
wrong for a whole layer.

## 10. Final report (end of P9, short)

- Line count before/after per package group (core, alphabet, keypad, countries, holder).
- Inventory totals by class A/B/C.
- New or changed D/H entries and why.
- "Needs your call" list (deletions, API breaks, root clutter).
- `grep -rc "TODO(py)\|TODO(ts)\|TODO(kt)"` totals.
