# Flag handling across the plate packages

Scope: only packages that actually render a flag. Packages with no flag at all
(Afghanistan, Qatar, Mali, Indonesia, Nicaragua, Palestine's five non-flag
countries, ...) are left out. Sizes are bytes on disk.

## 1. How flags reach the screen today

There are four routes. Only the first two ship image files.

| Route | Mechanism | Format | Where |
|---|---|---|---|
| A | `PlateCountry.flag` is a `SvgPlateAsset`, drawn by `PlateFlag` through `flutter_svg` | SVG | most packages |
| B | `PlateSpec.decals` holds a `PlateDecal(image: AssetImage(...))` | PNG only, because `PlateDecal.image` is an `ImageProvider` | Tanzania, Kazakhstan, Kyrgyzstan, Turkmenistan, Tunisia (military), flag-map decals |
| C | Painted in code on the plate background | none | Gambia (stripes 6:1:4:1:6), Ukraine (`_Flag`/`_Band`), Qatar (`QatarFlagEdgeClipper`) |
| D | No flag (`flag: null`) | none | Afghanistan (emblem), Palestine ×5, Mali, Indonesia, Nicaragua, Qatar block |

`PlateAsset` (`plate_core/lib/src/model/plate_asset.dart`) is sealed with only
`SvgPlateAsset` and `RasterPlateAsset`. There is no code-drawn variant, so every
flag that is not in route C has to be a file.

Route B is the expensive one. `PlateDecal` cannot take an SVG, so the SVG gets
rasterised to a big PNG and both files are shipped.

## 2. What each flag costs

### Trivial geometry (stripes, bands, simple shapes)

| Flag | Package | File | Bytes |
|---|---|---|---|
| Germany | germany_plate | Flag_of_Germany.svg | 237 |
| Bahamas | bahamas_plate | Flag_of_the_Bahamas.svg | 240 |
| Madagascar | madagascar_plate | Flag_of_Madagascar.svg | 244 |
| Senegal | senegal_plate | Flag_of_Senegal.svg | 255 |
| Tunisia | tunisia_plate | Flag_of_Tunisia.svg | 278 |
| Niger (stripes + disc) | niger_plate | niger_flag.svg | 296 |
| Qatar | iranshahr_plate | Flag_of_Qatar.svg | 310 (and not even used: the clipper draws it) |
| Algeria | algeria_plate | Flag_of_Algeria.svg | 311 |
| Norway | norway_plate | Flag_of_Norway.svg | 319 |
| Tanzania | tanzania_plate | flag_of_tanzania.svg **+ .png** | 320 + **34,945** |
| England / Scotland | united_kingdom_plate | two SVGs | 247 / 221 |
| Armenia | iranshahr_plate | Flag_of_Armenia.svg | 582 |
| Cape Verde (stripes + 10-star ring) | cape_verde_plate | Flag_of_Cape_Verde.svg | 602 |
| Union Jack | united_kingdom_plate | flag_of_the_united_kingdom.svg | 641 |
| Malaysia | malaysia_plate | Flag_of_Malaysia.svg | 683 |
| Bahrain (zigzag) | iranshahr_plate | Flag_of_Bahrain.svg | 782 |
| Namibia | namibia_plate | Flag_of_Namibia.svg | 788 |
| Palestine ×2 | palestine_plate | two SVGs | 986 / 978 |
| Uzbekistan | iranshahr_plate | Flag_of_Uzbekistan.svg | 1,243 |
| Azerbaijan | iranshahr_plate | Flag_of_Azerbaijan.svg | 1,303 |
| South Korea | north_korea_plate | flag_of_south_korea.svg | 589 |

Sum is about 12 KB. Converting all of these to code saves almost nothing in
bytes; see section 4.

### The EU flag, shared

`Flag_of_Europe.svg` is used by Spain, Italy, Malta, Portugal, Ireland,
Slovakia, Slovenia, Sweden, Greece (all via `plate_core`, 1,765 B) and Finland,
Netherlands (each with their own 791 B copy). It is a blue field plus 12 stars
on a circle, so it is the best single candidate for code: one painter, 11
consumers, and two redundant copies disappear.

### Mid-complexity (emblem or ornament)

| Flag | File | Bytes | Note |
|---|---|---|---|
| Belarus | Flag_of_Belarus.svg | 2,040 | ornament strip |
| Mongolia | mongolia_flag.svg + soyombo.png | 1,526 + PNG | Soyombo is a decal PNG |
| Brazil | Flag_of_Brazil.svg | 4,243 | globe + 27 stars |
| Mauritania (white map outline) | Mauritania_map.svg | 5,025 | a map, not a flag |
| Iran | Flag_of_Iran.svg | 6,927 | emblem; leave as SVG |
| Kazakhstan | kazakhstan_flag.svg **+ .png** | 9,668 + **103,505** | plate uses the PNG |
| Tajikistan | Flag_of_Tajikistan.svg | 11,431 | crown + stars |
| Kyrgyzstan | kyrgyzstan_flag.svg **+ .png** | 15,581 + **127,879** | plate uses the PNG |
| Wales | flag_of_wales.svg | 16,201 | dragon |

### Heavy

| Flag | File | Bytes |
|---|---|---|
| Bolivia | Flag_of_Bolivia_state.svg (699 paths, coat of arms) | **254,777** |
| Turkmenistan | flag.svg 75,449 + flag.png 168,567 + strip.png 267,966 + crescent.png 11,121 | **~523 KB** |
| Belize | Flag_of_Belize.svg (92 paths, coat of arms) | **71,903** |

### Flag-shaped maps (Benin, Gabon, Guinea, Burkina Faso, Niger)

Country silhouette filled with the flag colours, shipped as SVG plus a rasterised
PNG decal (Benin 34K+9K, Gabon 26K+16K, Guinea 78K+12K, Burkina 21K SVG +
two roundel PNGs). These are not really flags. The silhouette path is what costs
the bytes, so code does not help here.

## 3. Problems found while auditing

1. **Kuwait references a file that does not exist.**
   `iranshahr_plate/lib/src/kuwait/kuwait_country.dart` points four countries at
   `assets/flags/Flag_of_Kuwait.svg`. The file is not on disk and is not in
   `iranshahr_plate/pubspec.yaml`. The Kuwait flag will fail to load. I did not
   run the app to see how it fails.
2. **`Flag_of_Qatar.svg` ships but nothing loads it.** It is only mentioned in
   comments; the clipper draws the shape. It is also not declared in the
   pubspec.
3. **PNG next to SVG for the same artwork.** About 740 KB of flag PNGs
   (Kazakhstan, Kyrgyzstan, Turkmenistan ×3, Tanzania, Tunisia military flag)
   exist only because `PlateDecal` takes an `ImageProvider`.
4. **Three copies of the EU flag** (one in `plate_core`, one each in Finland and
   Netherlands).
5. **The asset coupling is fragile by design.** `SvgPlateAsset` carries a
   `package:` string and each package has to list the file in its own pubspec.
   `iran_plate/pubspec.yaml` already has a comment warning about this. Items 1
   and 2 are the same class of bug.

## 4. Can code replace the files?

Honest answer on size first: a 237-byte Germany SVG is about as small as the
Dart that would draw it. Moving the trivial flags into code **does not make the
package meaningfully smaller**. The real byte savings are elsewhere.

### Where the bytes are

| Action | Saves (approx.) |
|---|---|
| Drop the PNG duplicates by letting decals draw SVG or a painter (Kazakhstan, Kyrgyzstan, Turkmenistan, Tanzania, Tunisia) | ~740 KB |
| Simplify the Bolivia SVG (255 KB, coat of arms with 699 paths) | 200 KB+ |
| Simplify the Belize SVG (72 KB) | 50 KB+ |
| Turkmenistan: the 75 KB SVG is mostly carpet detail at a size nobody sees on a plate | 50 KB+ |
| Run svgo on the rest | a few KB |

### Where code is better for reasons other than size

- No pubspec declaration, no `package:` string, no way to miss a file (Kuwait).
- No `flutter_svg` parse at runtime for the simple cases.
- Colours come from the country's colour class, so a theme can recolour the
  flag and it can never drift from `*Colors`.
- Matches the existing rule that variation is data: Gambia and Ukraine already
  do this ad hoc.

### Suggested model

Add a code-drawn variant beside `SvgPlateAsset`, as data, not a widget per
flag:

```dart
sealed class PlateFlagArt { ... }
class StripedFlag extends PlateFlagArt {   // weights + colours, horizontal/vertical
  final Axis axis; final List<(Color, double)> bands;
  // optional: triangle hoist, centre disc, star(s), canton
}
class SvgFlag ...        // today's SvgPlateAsset
class PaintedFlag ...    // a const CustomPainter for the few special ones (EU ring, zigzag)
```

and let `PlateDecal` accept the same type instead of only `ImageProvider`.

### Classification

| Treatment | Flags |
|---|---|
| **Striped data** (bands only) | Germany, Armenia, Madagascar, Senegal (+ star), Niger, Namibia, Palestine, Bahamas (+ triangle), Tanzania (diagonal), Gambia (already) |
| **Stripes plus a primitive** (disc, crescent, star, canton, cross) | Tunisia, Algeria, Azerbaijan, Uzbekistan, Malaysia, Norway, England, Scotland, Union Jack, Cape Verde (star ring), South Korea (taegeuk, medium) |
| **One painter, many users** | EU ring (11 packages), Bahrain/Qatar zigzag (a `PaintedFlag` already half exists as `QatarFlagEdgeClipper`) |
| **Keep SVG, but strip and minify** | Iran, Brazil, Belarus, Tajikistan, Mongolia, Kazakhstan, Kyrgyzstan, Wales, Lebanon cedar, flag maps |
| **Keep SVG and shrink the artwork** | Bolivia, Belize, Turkmenistan |

Iran stays as an SVG, as you said. I'd put Brazil, Tajikistan and Belarus in
the same bucket: the emblems are not worth hand-coding for a few KB.

## 5. Recommended order

1. **Fix Kuwait** (add the SVG and the pubspec entry, or point at the right
   file). This is a bug today.
2. **Let `PlateDecal` take an SVG** (or a painter) and delete the duplicate
   PNGs. Biggest win for the least work: ~740 KB.
3. **Shrink Bolivia, Belize, Turkmenistan** (simplified emblem; these are drawn
   at roughly 30 px tall).
4. **Add `PlateFlagArt` with `StripedFlag` and the EU painter.** Migrate the
   striped and stripe-plus-primitive flags, delete the Finland/Netherlands EU
   copies, delete `Flag_of_Qatar.svg`.
5. Leave the complex emblem flags as SVG and run svgo over them.

Steps 1 to 3 are where the size comes from. Step 4 is robustness and
consistency; do it if you want the pubspec/package coupling gone, not for
bytes.

## 6. Not verified

- I did not render anything. Where I say a flag is "drawn at ~30 px", that is
  inferred from the plate canvas sizes, not measured.
- The PNG savings assume the SVG decal can be drawn at the same quality;
  `PlateDecal` is painted inside the canvas, so check how the canvas paints
  decals before committing to option 2.
- `plate_number_holder/assets/packages/` holds copies of package assets (some
  stale, e.g. Bahrain/Azerbaijan under `iran_plate`). It lives in a submodule
  and I did not look at how it is generated.
