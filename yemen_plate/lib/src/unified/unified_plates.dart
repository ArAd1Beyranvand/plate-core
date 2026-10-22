import 'package:flutter/widgets.dart';
import 'package:plate_core/plate_core.dart';

import '../common/yemen_alphabets.dart';
import '../common/yemen_country.dart';

/// System A, the unified plate: white for every usage, with the usage in the
/// blue panel's captions, which come from the country passed at render time
/// (`YemenCountry.unifiedFor(usage)`; each spec defaults to the private one).
/// The vehicle number is one field of 4–6 digits.
///
/// The car is 1024 x 292, measured from an issued plate; the motorcycle is
/// unmeasured, with the car's ratios. Digits are shorter than the photograph
/// (0.46 against 0.557 of the height) because Roboto is wider than FE-Schrift.
abstract final class YemenUnifiedPlates {
  static const double _carWidth = 1024;
  static const double _carHeight = 292;
  static const double _motoWidth = 289; // CALIBRATE: no photo
  static const double _motoHeight = 288; // CALIBRATE: no photo
  static const double _borderRatio = 0.035; // CALIBRATE: matches theme ratio

  // The car's zones, left to right (comments give the measured fractions):
  //   A  name labels    x  28 ..  283   (0.027 .. 0.276)
  //   B  vehicle number x 292 ..  832   (0.285 .. 0.812)
  //   C1 stipple strip  x 838 ..  847   (0.818 .. 0.827)
  //   C2 blue panel     x 847 .. 1024   (0.827 .. 0.987)

  // Zone C2 runs under the frame to the edge so scaling leaves no seam. The
  // padding puts the caption at y 0.590 .. 0.775.
  static const PlatePanel _carPanel = PlatePanel(
    box: PlateBox(847, 0, 177, _carHeight),
    flagScale: 0,
    captionScale: 1.6,
    padding: EdgeInsets.fromLTRB(22, 172, 16, 66),
  );

  // Last column, so the frame draws over its edge.
  static const PlateSection _carBackground = PlateSection.columns(<PlatePart>[
    PlatePart(PlateSection.plain, end: 847),
    PlatePart(PlateSection.fill(PlateFill.panel)),
  ]);

  // Zone A: two labels, so each keeps its own bidi direction. The Arabic is
  // taller for its ascender and tail.
  static const List<PlateLabel> _carLabels = <PlateLabel>[
    PlateLabel(text: 'اليمن', box: PlateBox(28, 60, 255, 96), glyphHeight: 118),
    PlateLabel(text: 'YEMEN', box: PlateBox(28, 156, 255, 76), glyphHeight: 100),
  ];

  // Zone C1: the strip is measured, the 12-unit dot pitch is not; 24 dots
  // reproduce the photograph's near-solid look.
  static final List<PlateRule> _carStipple = plateStipple(
    count: 24,
    left: 838,
    top: 1,
    width: 9,
    height: 7,
    stepY: 12, // CALIBRATE: dot pitch
  );

  // Measured x 0.876 .. 0.947, widened to 104 to fit Roboto digits around the
  // measured centre (x 933).
  static const PlateSlot _carSideCode = PlateSlot(
    alphabet: YemenAlphabets.digits,
    box: PlateBox(881, 14, 104, 124),
    length: 2,
  );

  // The height is the six-digit one, so the longest number fits the span.
  static const PlateSlot _carNumber = PlateSlot(
    alphabet: YemenAlphabets.digits,
    box: PlateBox(292, 31, 540, 215),
    length: 6,
    minLength: 4,
  );

  // Motorcycle: the same content on a square canvas. Zone A is a top band, C2 a
  // bottom band (side code left, usage right), and the stipple runs horizontally.

  static const PlatePanel _motoPanel = PlatePanel(
    box: PlateBox(0, 206, 289, 82),
    flagScale: 0,
    captionScale: 2.0, // CALIBRATE
    padding: EdgeInsets.fromLTRB(96, 12, 12, 12), // CALIBRATE
  );

  static const PlateSection _motoBackground = PlateSection.rows(<PlatePart>[
    PlatePart(PlateSection.plain, end: 206),
    PlatePart(PlateSection.fill(PlateFill.panel)),
  ]);

  static const List<PlateLabel> _motoLabels = <PlateLabel>[
    PlateLabel(text: 'اليمن', box: PlateBox(16, 14, 110, 42), glyphHeight: 42),
    PlateLabel(text: 'YEMEN', box: PlateBox(150, 20, 120, 30), glyphHeight: 30),
  ];

  // 22 dots on the car's pitch.
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

  // The validator reads these by key.
  static const List<PlateTextGroup> _groups = <PlateTextGroup>[
    PlateTextGroup(<int>[0], key: 'number'),
    PlateTextGroup(<int>[1], key: 'sideCode'),
  ];

  /// The car plate.
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

  /// The motorcycle plate; unverified.
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
