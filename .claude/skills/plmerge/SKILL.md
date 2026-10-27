---
name: plmerge
description: Find plate types of one country that can be merged into fewer specs (in the country package) and fewer entries (in plate_number_holder), then merge them. Usage /plmerge <country> [package]
---

Merge plate types for `$ARGUMENTS` (e.g. `afghanistan iranshahr_plate`). **Fewer lines in the packages is a primary goal** — every merge should shrink the package; reuse slots/groups from a sibling spec (`car.slots[0]`, `textGroups: car.textGroups`) instead of retyping them, and report the line delta.

Goal: one spec per *shape*, with everything that varies per vehicle as a **slot** and everything that varies by value as a **resolver**. Fewer specs, fewer holder entries, less code.

## 1. Read
- Package: `<pkg>/lib/src/<country>/*` (plates, themes, colors, alphabets, regions/provinces).
- Alphabets may live in `plate_alphabet/lib/src/countries/<country>_alphabets.dart`.
- Holder: `grep -rn "<Country>Plates\." plate_number_holder/lib` — usually `lib/screens/gallery/sources/<pkg-or-country>.dart`.
- **Reference material — decide per country whether to read it.** Read it when the country has many plates (Turkey, Iraq), when you can't tell from the code which values are legal or which colour goes with which class, or when a merge would change what's drawn. Skip it when the code's docs already quote the source and the merge is plain geometry.
  - `.plateref/<cc>/` (or `.plateref/<country>/`): the Wikipedia/Commons reference artwork and saved article HTML (`art.html`), plus measuring scripts. This is the ground truth for what each class prints.
  - `.plateref/before.log` / `after.log` / `before.txt`: earlier holder test runs (entry ids, which specs were rendered) — a "before" snapshot to diff your result against. `geometry.txt` dumps every spec's canvas/panel/rule boxes, so you can spot specs with identical geometry without reading code.
  - `wikipedia_plate_pages.txt`: the article URL per country, for WebFetch.
- **While reading the reference, list the region codes and the rules tied to them.** Most articles have a code table (governorates, provinces, cities) and rules that depend on it: a code range that adds a print (Iraq 21–24 → `KR` under `IRQ`), a range that changes the layout, colours or letters, codes reserved for one class, or regions with their own series. Note which rule is *read off the typed value* (→ resolver, one spec) and which is a different object (→ own spec). Put the code table in the package's region file and the validator, not in spec ids.
- Reference implementation of every technique below: `iran_plate` (`IranPlates.civil` + `IranThemes.civil`) and `iranshahr_plate/lib/src/afghanistan/`.

## 2. Find merge candidates — build this table first, show it to the user

| holder entry | spec | theme | country/region | sample values | differs from neighbour by |

Classify each difference:

| Difference | Merge with | Core API |
|---|---|---|
| Field/ink colour follows a letter or code (taxi letter → yellow) | one spec + `resolveTheme` | `PlateSpec.resolveTheme`, `PlateThemeResolver`; animates via `_Livery` |
| Only the serial length differs (3/4/5 figures) | one spec, variable field | `plateField(minLength:)` / `PlateSlot.minLength` |
| Region/province/city block differs (name, code) | a slot with a chosen alphabet keyed by code, glyphs = local name; second line as a `PlateMirror` with its own alphabet | `PlateAlphabet(characters:, glyphs:, input: AlphabetInput.chosen)` |
| Fixed letter/word that names the class (`ر`, `م`, `TAXI`) printed as a label | a slot of a class alphabet; Latin twin as a mirror | `PlateSlot` + `PlateMirror(alphabet:)` |
| Emblem/flag colour follows the field | spec-level default `country`, one per ink | e.g. `AfghanistanPanelInk.light.country` |
| Panel/flag-block colour differs per class (white `TJ` on blue police) | one block with transparent panel + `panelTextColor: null` (text takes theme ink) | `PlateCountry.panelTextColor` nullable |
| A fixed label that is a legal value of a neighbouring field *with the same length* (`TT` in a 2-letter field) | fold into that field and resolve the theme from it | `resolveTheme` on the group |
| A printed caption/word names the class and each class has its own field colour (Kuwait's 9 service captions) | caption becomes a chosen slot (characters = the caption strings) + `resolveTheme` from a `Map<caption, theme>`; alphabet = `map.keys` | chosen `PlateAlphabet`, `resolveTheme` |
| Region inferable from typed characters but not printed | keep spec, add `resolveRegion` | `PlateSpec.resolveRegion` |
| A region code range adds/changes a fixed print (Iraq 21–24 → `KR`) | one spec; labels for both variants with `resolve:` returning `''` (hide) or `null` (keep text) from the code group. Multi-line labels work | `PlateLabel.resolve` |
| Class shown only by a colour that nothing typed decides (Iraq's band) | one spec; holder entry gets `bands:` chips that swap the `PlateCountry` | `GalleryEntry.bands` |

**Check the real value set first** (Wikipedia page from `wikipedia_plate_pages.txt` / the package docs). Never widen a field (`minLength:`, a broader alphabet) just to make two classes fit: the keypad then offers combinations that don't exist and the cursor jumps on ambiguous lengths. If the classes are a closed list of codes, make a chosen slot of exactly those codes (like Afghanistan's class letters).

**Do not merge** when: the slot length/count differs (Tajik police has 1 letter, private 2); canvas size differs; the flag/country block is present on one and absent on the other; slot/label geometry differs (extra hyphens, a missing register); the plate prints in two inks (labels with `color:`); a value is fixed by law to one region (then use labels, as `kabul6` does). Two specs that differ only by theme *and* no letter on the plate tells them apart stay separate specs or one spec with two holder themes — don't invent a selector slot. For a band/panel colour, use the holder's `bands:` chips instead of one entry per colour.

## 3. Package refactor
- Keep public spec names that survive; delete merged ones and update `all`.
- Put a variable region last in the slot list so existing value indices stay stable; document the value order on the spec (`values are [serial, class, province]`).
- Derive alphabets from the region enum (`for (final p in values) p.code`) instead of retyping lists.
- When the panel loses its text lines, shrink `PlatePanel.box` to the emblem's band so it doesn't overlap the slots.
- Factor repeated `PlateSpec(...)` boilerplate into one private builder (`_plate(id, slots:, mirrors:, ...)`).
- Resolver: copy `IranThemes.civil` — `switch (group('<key>'))` → theme, then `base.copyWith(...)` of colours only. The group key must exist in `textGroups`.

## 4. Holder refactor
- One `GalleryEntry` per remaining spec; `sampleValues` must match `spec.slotCount` (checked by `test/*_gallery_render_test.dart`).
- Drop `country:` when the spec default is right.
- Entries that differ only by `country:` (band colour) collapse into one entry with `bands: [(label, PlateCountry), …]`; the playground shows them as chips.
- Look for duplicated sections (umbrella source + per-country source): share one top-level `_<country>Section()` function returning a fresh `GallerySection` (entries are resolved by identity, so don't share instances).
- Rewrite the section note to match the new count; no "now"/"previously".

## 4b. Remove what the merge orphaned — automatically, don't ask
After the merge, grep the whole repo for every removed name (`grep -rn "<Country>Plates\.<old>\|'<old spec id>'" --include=*.dart --include=*.md .`, skipping `build/` and `.dart_tool/`) and delete each hit:
- holder entries for removed specs, then `python3 plate_number_holder/tool/gen_spec_names.py`;
- `tools/migration_analyzer/registry.g.dart` records for removed members (prune by hand; add the new spec);
- now-unused `<Country>Country`/theme/alphabet constants, `_Layout` values and private builders (`flutter analyze` flags unused private ones, but public ones need grep);
- tests and golden cases of removed specs, and their `.png` files in `test/goldens/` that no test writes any more;
- README/CHANGELOG/doc lines that list the old specs, and spec-count notes ("Nine designs…").
Report what was removed.

Never run `dart format` on a directory outside the files you touched — `plate_core` rules forbid reformatting, and its width differs from the packages'.

## 5. Verify
- `flutter analyze` in the package and holder (0 errors/warnings).
- `flutter test` in the package; holder `test/<pkg>_gallery_render_test.dart`.
- Render goldens (`test/<country>_golden_test.dart`, Noto/DejaVu loaded as in `kuwait_golden_test.dart`) for each merged variant and **look at them**. Goldens already failing on text anti-aliasing across all countries are an environment issue, not yours — compare against your own new goldens only — check the region slot, emblem placement, and that the resolver flips the colour.

## 6. Learn
Append to "Lessons" anything this country taught (a new merge pattern, a trap). Keep the table in §2 authoritative.

## Lessons
- Afghanistan: 15 holder entries → 8. `car` covers private/duplicate/taxi/bus/lorry × 3–5 figures; `T`/`B` resolve to the yellow livery. Province became a slot (`AfghanistanProvince.names`) + code mirror (`.codes`); `PlateCountry` now carries only the emblem.
- An emblem-only `PlateCountry` draws its flag at the top of the panel box — confine the box to the middle band.
- `iranshahr.dart` had every country section twice (umbrella + per-country); extracting `_xSection()` functions removed ~500 lines.
- Editable mirrors wrap instead of shrinking: size `glyphHeight` to the box width (≈0.4 × width for a 5-digit Iranian run). Read-only mirrors scale down (core `_MirrorBinding`).
- A second lettered slot (province) needs the holder's `SlotKeypad` to show the *focused* slot's alphabet, not the spec's first lettered one.
- Multi-character tokens (`'HRT'`) need `renderAll` to look up the whole value first; keypad keys must scale down for word-length glyphs.
- Tajikistan: 9 specs → 8. Private + public transport merged: `TT` is a value of the 2-letter field, `TajikistanThemes.byLetters` picks amber. **Mistake:** police (1 letter) was first folded in with `minLength: 1` — the keypad offered every 1–2-letter combo and the cursor left after one letter. Police stays its own spec, sharing `car.slots`/`textGroups`. The three per-class flag blocks became one transparent block whose `TJ` prints in theme ink. Foreign (no flag), diplomatic and governmental (own slot layout) stay separate — the user's intuition for this split was right; ask yourself "same geometry + a value on the plate tells them apart?".
- Kuwait (user's idea): 16 specs → 8. Nine `_standard` specs differing only by caption + colour became `KuwaitPlates.standard` with the caption as a chosen slot in the caption's box; `KuwaitThemes.byCaption` maps caption → livery, and that one map also builds the alphabet. Their eight `KuwaitCountry` constants were dead (noPanel) and deleted. National guard (no band), police (two labels) and the other sizes stay. −79 package lines. Look for a private builder (`_standard(caption:)`) called many times: its parameters are your merge candidates.
- Turkey: too many plates to judge from code alone — read `.plateref/tr/` and `geometry.txt` first, then propose a table before touching anything.
- Iraq: 5 specs → 3, 10 holder entries → 3. `largeKurdistan`/`smallKurdistan` folded into `large`/`small` via `PlateLabel.resolve` on the governorate group (`IraqGovernorates.isKurdistan`): the KR stack and the plain stack are two labels, each hidden by the other's condition. The five band classes became `bands:` chips. Core fix: resolved labels drew `maxLines: 1`, cutting `I\nR\nQ` to `I` — check multi-line resolved labels in the golden. `tools/migration_analyzer/registry.g.dart` lists every public spec: prune removed ones (full regeneration currently fails on unrelated deps).
