# Port roadmap: plate_core, plate_alphabet, plate_keypad, countries → Python / TypeScript / Kotlin

Register for the `TODO(py)`, `TODO(ts)`, `TODO(kt)` comments in the Dart. A TODO cites an id;
the rationale lives here once. Ids are stable: refine wording, never renumber.

## Decisions

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
  the others — an input + display plate widget, running in the browser under Pyodide (WEB_ARCH.md).
  Core + `render` in pure Python (stdlib only); UI = `plates.ui`: SVG from the display list
  (`svg.py`) plus `<input>`s placed at slot boxes (`dom.py`, the TS model), animation on
  `requestAnimationFrame` through the same seam; no holder window — the gallery embeds it.
  (Superseded: PySide6. Dart `TODO(py)` notes naming Qt keep their behaviour, on the DOM.)
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
  + key events; Python: DOM keys through `plates.ui.dom`, like TS (`keypadFirst` and IME modes may be N/A — say so).
- **D9 · Conformance vectors.** The Dart is the reference. A Dart tool will emit JSON test vectors
  (input sequence → values, `isCompleted`, `rejection`, validation reason, `text()`, section
  `layout()`, `PlatePartId.allOf`, stagger delays, later the display list). All three ports run the
  same vectors. In P5, mark each existing test `TODO(py|ts|kt)` only where it can't become a vector.
- **D10 · Port order.** TS first (Dart semantics are closest: same RegExp flavour, UTF-16 strings,
  similar async), then Kotlin (Compose ≈ Flutter mental model, Skia text), then Python.

## Hazards

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
  (SVG/CSS want RGBA, so every port's SVG writer converts).
- **H11** `Duration`/`Curve` (`Curves.easeInOutCubic` …) — ports need a curve table with
  cubic-bezier control points identical to Flutter's; durations as integer ms.
- **H12** Text metrics: `fontSize = slotHeight * 0.72`, `height: 1.0`, strut, `TextPainter`
  measuring. Baselines differ per engine; parity is "within tolerance", not pixel-exact.
- **H13** Path ops: `Path.combine(difference)` (rings, crescents), path-length measuring for the
  border/divider `draw` effect. SVG: `fill-rule="evenodd"` + `stroke-dasharray`/`getTotalLength`;
  every port (TS, Kotlin js/wasm, Python on Pyodide) emits the same SVG, so the same trick applies.
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
- **H21** Ordered maps. `PlateAlphabet.canonical` folds a shared glyph to the first key in
  `glyphs` insertion order. TS plain objects move integer-like keys (`'5'`) to the front — use
  `Map`; Kotlin `mapOf` / `LinkedHashMap` keep order (`HashMap` does not); Python `dict` does.
- **H22** Pattern alphabets (`include: 'A-Z'`) expand a three-code-point `X-Y` token over code
  points. TS `String.fromCodePoint`; Kotlin common has no `appendCodePoint` — write a two-line
  UTF-16 encoder; Python `chr`. Codegen should emit the expanded list anyway (D3).
- **H23** Validation without asserts. `specProblems(spec)` returns the problem list; ports call
  it from tests and a debug flag (Python `-O` strips asserts, TS has none). Export runs it on
  every spec and refuses to write a broken one.
- **H24** Length units. `String.length` is UTF-16 code units in Dart, TS and Kotlin, code points
  in Python. Every `.length` on user text must be read as either code units (only safe for
  ASCII, e.g. `isDigitsOfLength`) or `runes.length`; the TODO says which.

## Inventory

`dart run tools/port_inventory.dart` (from the repo root) rewrites `claude/port/inventory.csv`.
Text-level counts, not an analyzer pass. Classes:

- `A` data only.
- `B` data plus at most two validators or a few resolvers — ported with the data (D4).
- `C` hand port: a `CustomClipper` (H1), a raster `AssetImage` decal (H2), or more than two
  validators / `RegExp`s (D4-code, H9).

`multiCodePoint` counts short literals of several code points in alphabet files (H7: entries a
code-point loop would split); `combining` counts literals holding combining marks (grapheme
clusters); `nonBmp` counts literals outside the BMP (UTF-16 surrogate pairs in TS/Kotlin).
`plate_alphabet` gets its own row because most countries take their alphabets from it.

## Holder spec

One screen per language, nothing else. Reference: `plate_number_holder/lib/minimal/main.dart` and
`lib/newdesign/plate/live_plate.dart` (`LivePlate`, `SlotKeypad`, `verdictOf`, `firstEmpty`).

1. **Country list → spec list.** Two pickers from the exported catalogue (D3): countries, then that
   country's specs. Switching spec calls `adoptSpec` with `PlateSpecTransition(keepIdentical: true,
   morphBackground: true)`: stagger out, swap at the midpoint, stagger in.
2. **The plate.** Editable slots placed at the slot boxes (D2/D8), the region caption under it when the
   spec has a `resolveRegion` (line height reserved, 200 ms cross-fade).
3. **Animation buttons.** "Play in" / "Play out" → `PlateAnimationController.comeInAll/goOutAll`;
   "Stagger" → `PlateStagger.sequence(spec, step: 60 ms, reverse: out)`, cue length = out + in.
4. **Keypad.** The language's own keypad (`plate_keypad` port): digit grid in the digit alphabet,
   letters grid in the focused slot's alphabet, the focused slot's alphabet disables the rest; letters
   panel only while the next slot takes a letter. Chosen alphabets (Persian series letter, provinces)
   open a picker that returns the canonical character.
5. **Verdict line under the plate.** `verdictOf`: entry validator, else restriction verdict, else valid.
   Incomplete plate → "Type <n digits|a letter A–Z> to start / Now <…>" from `describeSlots`; refused
   keystroke → 1.8 s hint "Slot k takes …"; complete → "Valid · <name>" or "Not valid · <reason>".
   Validators report only; they never bar a key.
6. **Out of scope:** landing page, gallery, playground, hero tour, code samples, theme tokens.
