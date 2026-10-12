import 'package:plate_core/plate_core.dart';
import 'package:flutter/widgets.dart';

import '../common/yemen_alphabets.dart';
import '../common/yemen_country.dart';

/// System A — the unified plate. White for every usage; colour-coding lives in
/// [YemenThemes]. Usage varies the blue panel captions (country block), passed at render time.
/// Vehicle number is one field of 4–6 digits ([PlateSlot.minLength] 4, length 6).
///
/// Car canvas: 1024 x 292 (aspect 3.51), measured from an issued plate.
/// Four zones: country block (x 0.027 .. 0.276), vehicle number (x 0.285 .. 0.812),
/// stipple strip (x 0.818 .. 0.827), blue panel (x 0.827 .. 0.987 + overlap under frame).
/// Motorcycle: 289 x 288, not measured (no photo available); ratios carried from car.
/// Digits shorter than photo (0.46 vs 0.557) because Roboto is wider than FE-Schrift.
abstract final class YemenUnifiedPlates {
  // Shared geometry: car (measured), motorcycle (// CALIBRATE).
  // Coordinates given as units; comments show measured fractions.
  static const double _carWidth = 1024;
  static const double _carHeight = 292;
  static const double _motoWidth = 289; // CALIBRATE: no photo
  static const double _motoHeight = 288; // CALIBRATE: no photo
  static const double _borderRatio = 0.035; // CALIBRATE: matches theme ratio

  // --- Car: the four zones, left to right on a 1024-wide canvas. ------------
  //
  //   A  country block   x  28 ..  283   (0.027 .. 0.276)
  //   B  vehicle number  x 292 ..  832   (0.285 .. 0.812, widened — see above)
  //   C1 stipple strip   x 838 ..  847   (0.818 .. 0.827)
  //   C2 blue panel      x 847 .. 1024   (0.827 .. 0.987, run to the edge)

  // Zone C2: blue slab down right edge (x 0.827 .. 0.987 + overlap under frame to 1024).
  // Panel overlaps frame to avoid seams when scaled. Padding places caption at y 0.590 .. 0.775.
  static const PlatePanel _carPanel = PlatePanel(
    box: PlateBox(847, 0, 177, _carHeight),
    flagScale: 0, // No flag
    captionScale: 1.6,
    padding: EdgeInsets.fromLTRB(22, 172, 16, 66), // Top 172 = 0.590 * 292
  );

  // Zone C2 as the plate's last column, so the frame is drawn over its edge.
  static const PlateSection _carBackground = PlateSection.columns(<PlatePart>[
    PlatePart(PlateSection.plain, end: 847),
    PlatePart(PlateSection.fill(PlateFill.panel)),
  ]);

  // Zone A: اليمن (x 0.027 .. 0.276) and YEMEN, separate labels (not joined via newline).
  // Separate to keep bidi isolated. اليمن's height is larger (includes ascender/tail).
  static const List<PlateLabel> _carLabels = <PlateLabel>[
    PlateLabel(text: 'اليمن', box: PlateBox(28, 60, 255, 96), glyphHeight: 118),
    PlateLabel(
      text: 'YEMEN',
      box: PlateBox(28, 156, 255, 76),
      glyphHeight: 100,
    ),
  ];

  // Zone C1 — stippled strip left of blue panel (x 0.818 .. 0.827). Not a primitive
  // in plate_core; built as a column of short
  /// rules, one per dot. This one wins because it is *data*: the dots are where
  // Stipple strip x 0.818 .. 0.827 (838 wide 9), measured. Pitch 12 units is not measured;
  // 24 dots at that pitch reproduce the photograph's near-solid reading. Built with [plateStipple].
  static final List<PlateRule> _carStipple = plateStipple(
    count: 24,
    left: 838,
    top: 1,
    width: 9,
    height: 7,
    stepY: 12, // CALIBRATE: dot pitch
  );

  // Side code: measured x 0.876 .. 0.947, 40-unit pitch per digit. Widened to
  // 104 units to fit Roboto digits; kept the measured centre (x 933).
  static const PlateSlot _carSideCode = PlateSlot(
    alphabet: YemenAlphabets.digits,
    box: PlateBox(881, 14, 104, 124),
    length: 2,
  );

  // Vehicle number: one field of four to six digits over x 292 .. 832. The
  // height is the six-digit one, so the longest number still fits the span.
  static const PlateSlot _carNumber = PlateSlot(
    alphabet: YemenAlphabets.digits,
    box: PlateBox(292, 31, 540, 215),
    length: 6,
    minLength: 4,
  );

  // Motorcycle: same content reflowed into square canvas. Zone A becomes full-width
  // top band (اليمن + YEMEN side by side), Zone B the middle, Zone C2 a full-width
  // bottom band (side code left, usage labels right). Zone C1's stipple rotates vertical.

  static const PlatePanel _motoPanel = PlatePanel(
    box: PlateBox(0, 206, 289, 82),
    flagScale: 0,
    captionScale: 2.0, // CALIBRATE
    padding: EdgeInsets.fromLTRB(
      96,
      12,
      12,
      12,
    ), // CALIBRATE: big left inset aligns caption right
  );

  static const PlateSection _motoBackground = PlateSection.rows(<PlatePart>[
    PlatePart(PlateSection.plain, end: 206),
    PlatePart(PlateSection.fill(PlateFill.panel)),
  ]);

  static const List<PlateLabel> _motoLabels = <PlateLabel>[
    PlateLabel(text: 'اليمن', box: PlateBox(16, 14, 110, 42), glyphHeight: 42),
    PlateLabel(text: 'YEMEN', box: PlateBox(150, 20, 120, 30), glyphHeight: 30),
  ];

  // Horizontal stipple above bottom band: 22 dots on car's 12-unit pitch (inherited // CALIBRATE).
  static final List<PlateRule> _motoStipple = plateStipple(
    count: 22,
    left: 15,
    top: 197,
    width: 5,
    height: 5,
    stepX: 12, // CALIBRATE dot pitch
  );

  static const PlateSlot _motoSideCode = PlateSlot(
    alphabet: YemenAlphabets.digits,
    box: PlateBox(16, 214, 59, 60), // CALIBRATE
    length: 2,
  );

  static const PlateSlot _motoNumber = PlateSlot(
    alphabet: YemenAlphabets.digits,
    box: PlateBox(16, 82, 257, 92), // CALIBRATE
    length: 6,
    minLength: 4,
  );

  // Side code after the number (different zone). Keys restore the semantics;
  // the validator reads by key.
  static const List<PlateTextGroup> _groups = <PlateTextGroup>[
    PlateTextGroup(<int>[0], key: 'number'),
    PlateTextGroup(<int>[1], key: 'sideCode'),
  ];

  // Each spec names `YemenCountry.unifiedPrivate` as its own `country`, so a
  // caller that passes no override gets the ordinary case rather than an
  // uncaptioned panel. If you are tempted to give a usage its own colour, read
  // `YemenThemes`.
  // ---------------------------------------------------------------------------

  /// The car plate. Usage is not a field: it selects the country block,
  /// passed at render time — `country: YemenCountry.unifiedFor(usage)`.
  static final PlateSpec car = PlateSpec(
    id: 'ye.unified.car',
    country: YemenCountry.unifiedPrivate,
    canvasWidth: _carWidth,
    canvasHeight: _carHeight,
    panel: _carPanel,
    background: _carBackground,
    slots: const <PlateSlot>[_carNumber, _carSideCode],
    rules: _carStipple,
    labels: _carLabels,
    textGroups: _groups,
    borderWidthRatioOverride: _borderRatio,
  );

  /// The motorcycle plate. Unverified — no photograph was available.
  static final PlateSpec moto = PlateSpec(
    id: 'ye.unified.moto',
    country: YemenCountry.unifiedPrivate,
    canvasWidth: _motoWidth,
    canvasHeight: _motoHeight,
    panel: _motoPanel,
    background: _motoBackground,
    slots: const <PlateSlot>[_motoNumber, _motoSideCode],
    rules: _motoStipple,
    labels: _motoLabels,
    textGroups: _groups,
    borderWidthRatioOverride: _borderRatio,
  );
}
