---
name: regcode
description: "Add a region/state/city readout to a country's plates: read the country's Wikipedia article (text only), decide whether the plate number encodes a region, pick where on the plate to show it, and wire it so it fades in/out after every keystroke. Invoke with /regcode <country>."
---

> **Model:** Opus · **extended thinking:** on. One country per run.

# Region code for a country's plates

The reference implementation is Iran. Read it before anything else:

- `iran_plate/lib/src/iran_regions.dart` — `IranRegions.lookup` / `captionOf`
- `iran_plate/lib/src/iran_regions_data.dart` — generated table, header cites the source
- `iran_plate/lib/src/iran_plates.dart` — the `PlateLabel(text: 'ایران', resolve: _squareCaption)`
- `iran_plate/test/iran_regions_test.dart`
- `plate_core/lib/src/model/plate_spec.dart` — `PlateLabelResolver`, `PlateLabel`, `PlateTextGroup`

Two mechanisms, both driven by the same lookup. Use the first when the plate has a label or
blank to put the caption on; use the second when it does not (digits fill the plate, as on
Algeria and Barbados).

1. **On the plate.** A `PlateLabel` with a `resolve` callback. The resolver reads typed text
   through `PlateTextGroup` keys and returns a caption, or `null` to fall back to the label's
   own `text`. `PlateCanvas` re-runs it on every keystroke and cross-fades the change.
2. **Beside the plate.** `PlateSpec.resolveRegion` (same `PlateLabelResolver` signature), read
   through `PlateController.regionCaption`. The gallery's `RegionCaption` widget shows it under
   the plate. Reference: `algeria_plate/lib/src/algeria_regions.dart`,
   `barbados_plate/lib/src/barbados_regions.dart`.

**No new widget, painter or bloc code in a country package.**

Argument: `$ARGUMENTS` is the package name without `_plate` (e.g. `colombia`, `india`).

---

## Step 1 — Find the article

Look up `$ARGUMENTS` in `.claude/skills/regcode/wiki_pages.json`. That map was built once from
https://en.wikipedia.org/wiki/Vehicle_registration_plate plus the Wikipedia API; **do not
re-scrape the index page.** If the key is missing or `null`, resolve
`Vehicle registration plates of <Country>` through
`https://en.wikipedia.org/w/api.php?action=query&redirects=1&titles=...`, then add it to the
JSON so the next run has it.

## Step 2 — Read the article (text, not images)

```
curl -sL -A "plate-regcode/1.0" "https://en.wikipedia.org/w/index.php?title=<Title>&action=raw"
```

**Actually read it.** Do not grep for "region" and stop. Read every section and table: region
codes often hide in "Format", "History", "Series" or "Codes" tables, in a `{{Main|…}}` /
`{{See also|…}}` sub-article, or in a template. Follow those links too. Also check the native
language Wikipedia via `prop=langlinks` — Iran's table came from fa.wikipedia.

Write down, before coding:

1. **Does a filled plate encode where it was issued?** Which characters, positions, plate types
   (current format, and legacy formats the package implements)?
2. **Granularity:** country → state/province → city. Can a *partial* prefix already tell the
   state before the city is known?
3. **Ambiguity:** shared codes, codes needing another character, unissued or reassigned codes.
   These must return `null`.
4. **Plate types where it does not apply** (diplomatic, military, personalised, national series).

### Decision A — is the data there?

- **Complete table found** → Step 3.
- **Plate encodes region, but Wikipedia's table is missing/partial** → `WebSearch` for the
  official registry or a reliable list (also in the local language). **Do not implement from
  these.** Stop and report: what is missing, which sites have it, how authoritative each looks,
  with URLs. The user decides.
- **Plate does not encode region** → stop, quote the sentence of the article saying so.

Never invent a code. Every row must trace to a source cited in the data file header.

## Step 3 — Where on the plate does the caption go

Read the package's goldens (`<country>_plate/test/goldens/*.png`) and specs
(`lib/src/*_plates.dart`). Per spec, in order of preference:

1. **Replace an existing label** (country name, "ISSUED IN" caption, printed state name, slogan),
   as Iran replaces "ایران". Keep its box and glyph height; the original returns when the lookup
   is `null`.
2. **A real blank** — empty band, margin above/below the characters. Measure it
   (`.claude/skills/plate_creator/scripts/measure.py` or PIL), convert pixels to plate units
   (`canvasWidth / imageWidth`), leave padding so it never touches characters, border or bolts.
3. **Nowhere fits** → use `PlateSpec.resolveRegion` (the caption shows beside the plate, see
   above). Never move or shrink the plate's real characters. Set it only on the specs that carry
   the region characters (not diplomatic/army/etc. unless they do). The user chose this route for
   Algeria; do not ask again for a plate whose digits fill the canvas.

A new label's default `text` is `''`, so the plate looks unchanged until a region is known.

## Step 4 — Implement

Mirror Iran's layout:

- `lib/src/<country>_regions_data.dart` — `part of`, rows generated by a throwaway script from
  the wikitext (not retyped), header naming exact article/section/URL.
- `lib/src/<country>_regions.dart` — region class + `<Country>Regions.lookup(...)` and
  `captionOf(group)`.
- In the specs: `PlateTextGroup(..., key: ...)` for region-bearing slots if missing, then the
  `PlateLabel(resolve: <Country>Regions.captionOf)`.
- Export from `lib/<country>_plate.dart` as Iran does.
- Region keys (`'wilaya'`, `'region'`, `'area'`, `'letters'`) must be `PlateTextGroup` keys of
  the spec; `captionOf(group)` reads them with `group('<key>')`.
- Follow `plate_core/CLAUDE.md` (no widget-returning functions, variation is data).

### Partial input — the check runs after every character

`captionOf` runs on every keystroke, so `lookup` must be right for **every prefix**:

- Too short to determine anything → `null`.
- Pins the state but not the city → the state.
- Pins the city → the city.
- Matches several regions → `null` (or their common higher level).
- Deleting characters walks back the same way.
- Normalise digit scripts / case as the alphabet requires.

## Step 5 — Tests and goldens

- `test/<country>_regions_test.dart`: full-plate hit, each partial-prefix stage, every ambiguous
  code → `null`, an unissued code → `null`, a non-applicable plate type.
- Golden cases in `test/golden_test.dart` for a filled plate *with* the caption plus one partial.
  `flutter test --update-goldens`, then **Read the new PNGs** and check the caption sits in its
  box and overlaps nothing.
- `flutter analyze` and `flutter test` must pass. Report failures verbatim.

## Step 6 — Show it in `plate_number_holder`

Every plate in the gallery must show the region, with no per-country code:

- `lib/newdesign/plate/live_plate.dart` — `LivePlate` (playground, landing hero, sections) and
  `StaticPlate` (country page tiles and swap preview, region page, landing example cards,
  auto-typing plates) already render `RegionCaption(controller: ...)` under the plate. It reads
  `controller.regionCaption` and takes no space when the spec has no `resolveRegion`.
- So per country there is nothing to add **if** the specs carry `resolveRegion`; confirm instead:
  1. the country's gallery source (`lib/screens/gallery/sources/<country>.dart`) uses those
     specs and its `sampleValues` fill the region characters, so the auto-typing cards show a
     caption at the end (and a partial caption on the way);
  2. `flutter analyze --no-pub` on the gallery adds no new issues;
  3. run `flutter test --no-pub test/<country>_gallery_render_test.dart` if it exists.
- If a place that draws a plate is missing the caption (a new widget, not `LivePlate` /
  `StaticPlate`), add `RegionCaption` there rather than reading the resolver directly.
- Do not fix unrelated failing gallery tests; report them.

## Report

Sources used, coverage (N codes, which plate types), placement per spec, known gaps, and any
external sites from Decision A awaiting approval.
