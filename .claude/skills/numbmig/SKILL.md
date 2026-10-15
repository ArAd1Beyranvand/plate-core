---
name: numbmig
description: "Re-examine an existing country package against its real plates and fix its structure — fields of N characters instead of N single cells, wrong categories, wrong geometry. Invoke with /numbmig <country>."
---

> Use `/plate_creator` to build a country from nothing. Use this when a package already exists and
> *looks* plausible but its structure is off. Worked on so far: `iran_plate` (fixed-length fields),
> `yemen_plate` (min/max fields), `algeria_plate`, `angola_plate`, `benin_plate`.

## Checklist (one country = one pass through this)

1. Read `lib/src/*_plates.dart`, the validators, the serial generator, `test/golden_test.dart`, and
   `plate_number_holder/lib/screens/gallery/sources/<country>.dart`.
2. Decide each group's field: fixed `length`, or `minLength`..`length` (§2, §2b). The validator
   often states the range ("up to three digits" → `minLength: 1, length: 3`).
3. Replace every `plateRegister`/`plateRegisterAcross` group with one `PlateSlot` (§2); renumber
   `textGroups` to one index each.
4. Fix the generator (one string per slot) and anything indexing `values[i]`.
5. Rewrite sample values. Tests and gallery often pass `'A B 1 2 3 4'.split(' ')`, one character per
   slot — make it one token per field: `'AB 1234'`.
6. Remove the old (§3b), regenerate goldens, **look at every one** (§4), fix the gallery (§3c).
7. Analyze + test the package, plate_core (if touched) and the gallery; report (§6).

# Reworking an existing plate package

The question is never "does it compile and render". It is: **does the editable structure match how
the real plate is printed and typed?** Find that out yourself from the references; do not wait to be
told "the first field should be two digits".

## 1. Find the real structure

1. Read the package's specs (`lib/src/*_plates.dart`) and its `textGroups`.
2. Fetch the Wikipedia article (see `plate_creator` Phase 1) and **open every plate image**, one per
   category — including the odd ones (historic, motorcycle, protocol, temporary).
3. For each category write down, from the *image*, the sequence of fields: `2 digits | letter |
   3 digits | 2 digits`. A field is a run that is printed as a unit and typed as a unit.
4. Compare with the spec's `slots`. Mismatches to look for:
   - N adjacent identical single-character cells that are really one field (`plateRegister` of 2
     digits → one `PlateSlot(length: 2)`).
   - Missing structure: dividers, a second row, a panel photo, a stripe the article mentions in
     prose ("white on brown, flag **and a picture** of X") but the spec lacks.
   - Prose vs picture disagreements: the picture wins; say so in a comment.

## 2. Fields: `PlateSlot.length` and `spacing`

`plate_core` slots can hold a run: `PlateSlot(alphabet:, box:, length: 2, spacing: 22)`.

- One slot = one box, one focus stop. Its value is the run typed so far (`'1'`, then `'12'`).
- `box` spans the whole field (first cell's left to last cell's right).
- `spacing` is extra letter spacing so the run sits at the printed pitch instead of the font's
  advance. Use `max(0, pitch - 0.6 * 0.72 * height)` (import `dart:math`) and check it in a
  real-font golden. From measured centres: `box.left = firstCentre - pitch / 2`,
  `box.width = count * pitch`.
- plate_core pads the run's leading edge by `spacing` (Flutter's letter spacing also trails the last
  glyph), so a spaced run is centred on its box. A run shifted left by half a pitch means that
  compensation is missing.
- A run wider than its box is scaled down as a whole (`FittedBox`), never clipped per cell.
- Focus advances only when the run is full; backspace removes one character, then steps back.
- Chosen (picker) alphabets stay `length: 1`.
- `textGroups` index **slots**, not characters: collapsing cells renumbers every group, so
  `[0,1]`, `[2]`, `[3,4,5]` becomes `[0]`, `[1]`, `[2]`. `valueOfGroup`, restrictions, validators
  and label resolvers read groups, so they keep working; anything indexing `values[i]` or
  `slotCount` does not.
- Keep `plateRegister` for cells that are genuinely drawn apart (separate boxes, dividers between).

## 2b. Variable fields: `minLength` .. `length`

Learned on Yemen. A field that legally holds "1 to 2" or "4 to 6" digits is **one slot**, not one
spec per length:

```dart
PlateSlot(alphabet: digits, box: <whole field span>, length: 6, minLength: 4)
```

- `length` is the maximum, `minLength` the minimum (defaults to `length`, i.e. fixed).
- `isFull` (= `length`) drives focus advance: below the max the user may keep typing.
- `isComplete` (= `minLength`) drives `PlateController.isCompleted`: a plate is complete once every
  field reaches its minimum.
- Smell to look for: `car4`/`car5`/`car6` specs, `carGeometries` maps keyed by digit count,
  `car({numberDigits})` lookups. Collapse them all into one spec per *form* (car, moto) and delete
  the maps and lookups — "should be a single one, not different classes".
- Size the box for the **longest** run (height from the max-length variant) so it fits the span;
  text is centred, so shorter runs sit in the middle. `spacing` is a fixed pitch, so leave it 0 on
  a variable field unless the plate prints a fixed pitch regardless of length.
- Editable mirrors over a variable field: one `PlateMirror` per field spanning the whole field;
  plate_core copies the source slot's `length`/`minLength`/`spacing` into the mirror's field.
- Update everything that knew the lengths: validator min/max constants (match the field —
  the user's stated range wins over the old validator), serial generators (draw a random length
  between `minLength` and `length`, write one string per slot), docs, example, CHANGELOG.
- Test it: a value at `minLength` completes, one below does not; goldens at both ends of the range.

## 3. Everything that has to move with a restructure

Grep for the package's name and `slotCount`/`values[`/`setAt(` across the workspace:

- specs and `textGroups`
- the package's own tests (`slotCount`, slot indices, `setAt(index…)`, sample value lists)
- `plate_number_holder/lib/screens/gallery/sources/<country>.dart` sample values (a value is now one
  string per slot: `['12', null, '345', '11']`)
- goldens (`flutter test --update-goldens`) and the README if it names a spec
- `pubspec.yaml` `assets:` for any new decal

## 3b. Remove the previous tests and code — every country, every time

A migration is not done while the old structure is still around. After migrating a country:

- Delete the old specs, private helpers (`_carGov2Serial5`, `_carEcho(count, …)`, per-length
  groups), geometry maps and lookup functions outright. No `@Deprecated` shims for them.
- Delete or rewrite tests pinned to the old structure: per-cell slot counts, "eleven specs",
  "register ends flush at 530", lookup-returns-same tests. Replace with tests of the new contract
  (field min/max, completion, generator round-trip).
- Delete stale goldens (`rm test/goldens/<old names>.png`) before `--update-goldens`, so renamed
  cases do not leave orphans, and delete `test/failures/`.
- Grep the workspace for every removed name and fix the callers: example app, README/library docs,
  `plate_number_holder`, and the generated registries — regenerate them, don't hand-edit:
  `python3 plate_number_holder/tool/gen_spec_names.py` and
  `python3 tools/migration_analyzer/analyzer/gen_registry.py`.
- Add a CHANGELOG entry listing what was removed.

## 3c. Adding to / fixing the gallery

Each country has `plate_number_holder/lib/screens/gallery/sources/<country>.dart`, a
`GallerySource` with `sections` of `GalleryEntry(id, label, spec, country, theme, validator,
sampleValues)`.

- One entry per spec × livery worth showing; usages that only swap a caption share a spec.
- `sampleValues` is one string per **slot** (`['12', null, '345', '11']`), or from the package's
  serial generator with a seeded `Random` so the page is stable.
- Entry ids are stable strings; `lib/newdesign/landing/sections.dart` and `hero.dart` reference
  some ids/specs directly — grep them.
- `highlights` must return the *same objects* as in `sections` (`catalogue_highlights_test`).
- A new country: add the source, register it in the catalogue, add the package to the app's
  `pubspec.yaml`, regenerate `spec_names.g.dart`.
- Verify: `flutter analyze --no-pub` in the app, and run `test/catalogue_highlights_test.dart`,
  `test/catalogue_stats_test.dart`, `test/newdesign/live_plate_test.dart`.

## 4. Geometry: measure, don't eyeball

Follow `plate_creator` Phase 2 (`scripts/measure.py`). For a quick pass, normalise the reference to
the canvas and take run extents with numpy; positions in canvas units = pixel × canvas/ref width.
Dividers are `PlatePart(..., end: <centre>, divider: <thickness>)` in `background`, never boxes.

Limits found the hard way:
- `flutter test` draws glyphs as boxes unless the test loads a font. Some packages (algeria,
  angola, benin) already load DejaVu Sans Bold in `setUpAll` with a `FontLoader`; their goldens
  show real Latin glyphs — use them to judge spacing and centring. Packages without one (iran,
  yemen) pin geometry only; say so.
- The shell is blocked from the system font directory ("sensitive path" — even a command whose
  text mentions it is refused). Do not work around it; only an existing test loader reads it.
  DejaVu has no plate-style Persian/Arabic face, so RTL ink stays unverified.
- DejaVu Bold is wider than most plates' condensed faces: a run that fills its box in a golden may
  have air on the real plate. Judge positions (centres, gaps to dashes), not tightness.
- Existing specs sized digits so that box height ≈ reference ink height; follow that convention
  unless you can measure otherwise.
- The test font draws every glyph a full em wide (~2× a real digit), so a 6-digit run looks like
  it overflows in goldens. Check fit by arithmetic (`0.72 × height × ~0.56 × length ≤ width`),
  not by the golden.

## 5. Decals

A building photo or crest cannot be drawn from boxes: crop it from the reference into
`assets/`, register it in `pubspec.yaml`, use `PlateDecal`. Note the source file's licence for the
user to confirm. In goldens, a decal decodes off the test clock:

If a decal is missing from a golden, the test lacks this wait — add it (Benin's did):

```dart
await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
await tester.pump();
```

## 6. Verify and report

`flutter analyze --no-pub` and `flutter test --no-pub` in the package, `plate_core`, and the gallery
file. If `pub get` fails in the sandbox use `flutter pub get --offline`. Look at every golden.

Report: what structure the references showed, what changed, what was **not** verified (fonts,
licence), and anything the user's wording was ambiguous about.
