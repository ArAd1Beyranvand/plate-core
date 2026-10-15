## What is left for you

Everything above was produced offline: the article parsed into tables,
each photo fitted, flattened to plate units, measured and colour-balanced.
Trust the numbers over your own reading of a photo; open a photo only when
its fit says CHECK or the numbers contradict the article.

### Fields, not cells

A field is a run of characters printed and typed as a unit: `12 ب 345 11`
is four fields, not seven cells. Each field is **one** `PlateSlot`:

```dart
PlateSlot(alphabet: digits, box: <whole field span>, length: 3)              // fixed
PlateSlot(alphabet: digits, box: <span of the longest>, length: 6, minLength: 4) // "4 to 6 digits"
```

- The rows column lists each row's fields as `glyphs@x-span`; the local
  model's `fields=` names their kind. Use the photo's field split, and the
  article's format column for the length range ("up to three digits" →
  `minLength: 1, length: 3`). Prose vs picture: the picture wins; comment it.
- `box` spans the whole field. For a fixed field with a printed pitch, set
  `spacing: max(0, pitch - 0.6 * 0.72 * height)` (`dart:math`); leave it 0 on
  a variable field.
- Do not use `plateRegister`/`plateRegisterAcross` for a field. Keep them only
  for cells drawn apart (separate boxes, dividers between). Picker
  (chosen) alphabets stay `length: 1`.
- A field whose length varies is one slot with `minLength`, never one spec per
  length: no `car4`/`car5` specs, no geometry maps keyed by digit count.
- `textGroups` index slots: one index per field (`[0]`, `[1]`, `[2]`).
- Validators and serial generators work per field: min/max from the field,
  one string per slot, a random length between `minLength` and `length`.
- Sample values are one token per field: golden cases `'AB 1234'`, gallery
  `['12', null, '345', '11']` — never `'A B 1 2 3 4'`.

### Steps

0. Take the categories from "Pictures and their captions" and the
   tables, not from which photos happened to measure: a SKIPPED or NOT
   MEASURED picture whose caption names a current plate is still a
   category — open its original and measure it by hand.
1. Group the categories into designs (one builder per design). Use the
   rows column: same row count and fields means one design; plates that
   differ only in a field's length share a design (`minLength`).
2. Write `lib/src/{country}_plates.dart` — `_Layout` from the measured rows,
   one `PlateSlot` per field, one builder per design, glyph sizes from ink
   heights (glyph ≈ ink / 0.72).
3. Write the validators' rules per field from the table's format column.
4. Write the gallery labels and section notes.
5. Place the icons as "Icons — what to do with them" says.
6. Write the gallery source `plate_number_holder/lib/screens/gallery/sources/{country}.dart`
   and fill the cases map in `test/golden_test.dart` (one line per category,
   one token per field).

Already done, do not redo: pubspec, LICENSE, analysis_options, README
(only fix its summary line and the usage example), library export, the
golden test harness.

Done afterwards by `pk after`, do not do: gallery registration, the
gallery render test, goldens, the full test runs, the commit plan. To
check your code while writing, `python3 tools/platekit/pk.py analyze
<package>` is enough. Stop when the code above is written and analyzes
clean.
