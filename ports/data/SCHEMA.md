# ports/data

The Dart packages as data (D3), written by
`plate_number_holder/test/port_export_test.dart`; ports generate code from it.
Do not edit; re-export:

    python3 tools/port_export_names.py        # when a package gains or loses a public name
    cd plate_number_holder && flutter test --no-pub test/port_export_test.dart

UTF-8 JSON, 2-space indent, keys in a fixed order. Every file has `"format": 1`.

## Conventions

- **Colours** are ARGB32 ints (`0xAARRGGBB`).
- **Boxes** are `[left, top, width, height]` in plate units.
- **Refs.** Countries, themes and alphabets are stored once and referenced by a
  string ref: the first Dart name it is reachable under (`MaltaThemes.standard`),
  or `<stem>~<n>` when no name reaches it (stem: country code, `theme`).
  `names` lists every Dart name with that content. An alphabet's ref is its
  `id`, or `<id>~<n>` for a second, different alphabet with the same id
  (`me.letters` is Montenegro's, `me.letters~2` Melilla's) — always resolve a
  slot's alphabet through the ref, never through `id`.
- **Spec ids are unique within a package only.** Madeira re-exports Portugal's
  `pt.*` specs; South Ossetia (`russia_plate`) and Somalia both have
  `so.standard`. Key specs by `(package, id)`.
- **Ordered maps are pair lists** (`[[key, value], ...]`), because TypeScript
  reorders integer-like object keys (H21).
- **Strings that matter per code point** also come as code point lists (H7, H19, H24).
- `kind` tags every sum type (H18).

## index.json

    {"format": 1, "packages": {"<package>": {"countries": ["mt", ...], "specs": ["mt.standard", ...]}}}

## alphabets.json

    {"format": 1, "alphabets": {"<ref>": {
      "id", "characters": [str], "characterCodePoints": [[int]],
      "input": "typed" | "chosen" | ..., "isNumeric",
      "glyphs": [[from, to]], "glyphCodePoints": [[[int], [int]]],
      "direction": "ltr" | "rtl", "placeholder",
      "names": [[package, "Class.field"]]   // plate_alphabet or a country package
    }}}

## countries/&lt;package&gt;.json

One per `*_plate` package the holder depends on (`core_plate` is a deprecated
stub and has none).

    {
      "format": 1, "package",
      "pubspec": {"version", "description", "homepage"},
      "alphabets": [ref],                 // the ones its specs use
      "countries": {ref: Country},
      "themes": {ref: Theme},
      "specs": [Spec],
      "resolvers": {name: Resolver},
      "validators": [{"name", "file", "gated"}],   // PlateValidator subclasses; vectors are in ports/vectors
      "assets": [Asset],                  // every asset the file references
      "gallery": [GalleryEntry]
    }

There is no `themes.json`. Themes are stored with their package so that each
country file stands alone. When two packages have equal themes (29 cases,
mostly plain ink on white), each package keeps its own copy.

**Country**: `names, code, captionLines, headingLines, panelColor,
panelTextColor, flagAspectRatio, flag: Graphic?, flagBorderColor`.

**Theme**: `names, plateBackground, plateBorder, ink, dividerColor,
borderWidthRatio, plateRadiusRatio, activeColor, inactiveColor, alertColor`.

**Spec**:

    id, names,          // names is [] for a spec only a builder makes (reached via the gallery)
    country: ref, canvasWidth, canvasHeight,
    panel: {box, flagScale, captionScale, padding: [l, t, r, b]?, direction, shape: Clip?},
    noPanel,
    background: Section,
    bands:   [{box, color, topCornerRadius, bottomCornerRadius}],
    slots:   [{alphabet: ref, box, color?, length, minLength, spacing}],
    rules:   [{box}],
    labels:  [{text, box, glyphHeight, color?, rotated, lineHeight, fontFamily, fontPackage, resolve: resolver name?}],
    decals:  [{box, image: Asset?, drawing: Graphic?}],
    mirrors: [{source, box, glyphHeight, alphabet: ref?, editable}],
    textDirection, borderWidthRatioOverride, inkOverride,
    textGroups:   [{indices, prefix, key}],
    restrictions: [{group, values, reason}],
    resolveTheme: resolver name?, resolveRegion: resolver name?

**Section**: `{kind: "fill", fill: Fill, shape: Clip?}` or
`{kind: "columns" | "rows", parts: [{section, end, divider}]}`.

**Fill**: `{kind: "color", color}`, `{kind: "field" | "panel" | "divider"}` (the
theme's colour), or `{kind: "stripes", stripes: [Fill], stops, angle,
fog: {center: [x, y], radii: [w, h], opacity, plateau}?}`.

**Clip** (H1): a `CustomClipper` as the path it returns at `size` (the leaf's or
panel's), in local coordinates: `{clipper: class name, size: [w, h],
fillRule: "nonzero" | "evenodd", svg: "M x y L x y ... Z"}`. Curves are
polylines sampled every 0.05 units and thinned to within 0.002.

**Graphic**: `{kind: "drawing", width, height, shapes: [Shape]}` or an Asset.
**Shape** (all have `color`): `rect {left, top, width, height}`,
`polygon {points: [[x, y]]}`, `circle {cx, cy, radius}`,
`ring {cx, cy, radius, width}`, `crescent {cx, cy, radius, biteDx, biteRadius}`,
`star {cx, cy, radius, points, innerRatio, rotation}`,
`starRing {cx, cy, ringRadius, starRadius, count, points, innerRatio}`.

**Asset** (H2): `{kind: "svg" | "raster", package, path}`, relative to the
repo root (`<package>/<path>`); the exporter checks it exists. SVG flags stay
SVG (D6).

**Resolver** (D4), keyed by `Class.method`, or by the spec position
(`ie.standard/labels/0`) for a lambda written inside a spec:

    kind: "table" | "code", signature: "label" | "theme",
    file: source file?, tag: "D4-table" | "D4-code" | "",

A `code` resolver is only named; each port implements it by hand. A `table`
resolver (tagged `D4-table`, or untagged) also has:

    reads:   [group key],          // the groups it reads, in order
    cut:     {group key: n},       // a group matched on its first n code points only
    default: value,                // what every unlisted key gives
    table:   [[[group value per read], value]]

A lookup takes the value of each group in `reads` (cut to `n` code points where
`cut` says so) and returns the matching row's value, else `default`. The domain
is every concatenation of a group's slots, each empty, partly or wholly filled.
A `label` value is a string or null. A `theme` value is a patch: the theme
fields the resolver sets (`{}` keeps the host's theme unchanged).

**GalleryEntry**: the holder's pairing of a spec with what it shows it with:

    id, source, section, label, note, spec: spec id, theme: ref?, country: ref?,
    validator: class name?, sampleValues: [str],
    themeForValues: bool,     // the theme depends on the values; done in code, not exported
    bands: [{label, country: ref, theme: ref?}]
