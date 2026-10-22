import 'package:flutter/widgets.dart';
import 'package:plate_core/plate_core.dart';

import 'palestine_alphabets.dart';
import 'palestine_country.dart';
import 'palestine_slots.dart';

/// Gaza plates (3·DDDD·DD) with a flag in place of the identity block.
/// Dimensions are provisional (CALIBRATE), copied from the West Bank plates.
abstract final class PSGazaPlates {
  static const List<PlateTextGroup> _groups = [
    PlateTextGroup([0], key: 'prefix'),
    PlateTextGroup([1], key: 'serial'),
    PlateTextGroup([2], key: 'usage'),
  ];

  // Same cells as PSWestBankPlates.legacyCar.
  static final List<PlateSlot> _sevenCellSlots = [
    const PlateSlot(alphabet: PSAlphabets.gazaPrefix, box: PlateBox(20, 9, 47, 92)),
    psRun(
      alphabet: PSAlphabets.digits,
      count: 4,
      left: 95,
      top: 9,
      cellWidth: 47,
      height: 92,
      pitch: 51,
    ),
    psRun(
      alphabet: PSAlphabets.digits,
      count: 2,
      left: 323,
      top: 9,
      cellWidth: 47,
      height: 92,
      pitch: 51,
    ),
  ];

  static const List<PlateLabel> _sevenCellLabels = [
    PlateLabel(text: '-', box: PlateBox(64.9, 36.6, 32.2, 36.8), glyphHeight: 50.6),
    PlateLabel(text: '-', box: PlateBox(292.9, 36.6, 32.2, 36.8), glyphHeight: 50.6),
  ];

  /// 2012–2021: the flag rotated, filling the right strip.
  static final PlateSpec car2012 = PlateSpec(
    id: 'ps.gz.2012.car',
    country: PSCountries.gaza2012,
    canvasWidth: 520,
    canvasHeight: 110,
    panel: PlatePanel(box: PlateBox(455, 0, 55, 110), flagScale: 1, padding: EdgeInsets.zero),
    borderWidthRatioOverride: 0.027,
    slots: _sevenCellSlots,
    labels: _sevenCellLabels,
    textGroups: _groups,
  );

  /// A raster, since decals cannot be SVG, pre-faded to ~12% grey. Decals paint
  /// under the slots.
  static const PlateDecal _watermark = PlateDecal(
    image: AssetImage('assets/marks/palestine_watermark.png', package: 'palestine_plate'),
    box: PlateBox(10, 9, 380, 92),
  );

  // CALIBRATE — proportions from the car layout.
  static final List<PlateSlot> _motoSlots = [
    const PlateSlot(alphabet: PSAlphabets.gazaPrefix, box: PlateBox(14, 9, 48, 92)),
    psRun(
      alphabet: PSAlphabets.digits,
      count: 4,
      left: 74,
      top: 9,
      cellWidth: 48,
      height: 92,
      pitch: 52,
    ),
    psRun(
      alphabet: PSAlphabets.digits,
      count: 2,
      left: 290,
      top: 9,
      cellWidth: 48,
      height: 92,
      pitch: 52,
    ),
  ];

  static const List<PlateLabel> _motoLabels = [
    PlateLabel(text: '-', box: PlateBox(56, 36.6, 18, 36.8), glyphHeight: 50.6),
    PlateLabel(text: '-', box: PlateBox(272, 36.6, 18, 36.8), glyphHeight: 50.6),
  ];

  /// One-line motorcycle with the upright flag and watermark.
  static final PlateSpec moto = PlateSpec(
    id: 'ps.gz.moto',
    country: PSCountries.gaza2021,
    canvasWidth: 520,
    canvasHeight: 110,
    panel: PlatePanel(box: PlateBox(400, 27.5, 110, 55), flagScale: 1, padding: EdgeInsets.zero),
    borderWidthRatioOverride: 0.027,
    slots: _motoSlots,
    labels: _motoLabels,
    decals: [_watermark],
    textGroups: _groups,
  );

  // Two-line plates carry the flag as a band across the top.
  static const PlatePanel _twoLinePanel = PlatePanel(
    box: PlateBox(4, 4, 292, 40),
    flagScale: 1,
    padding: EdgeInsets.zero,
  );

  // Same lines as PSWestBankPlates.legacyCarTwoLine.
  static final List<PlateSlot> _twoLineSlots = [
    const PlateSlot(alphabet: PSAlphabets.gazaPrefix, box: PlateBox(16.5, 53, 34, 42)),
    psRun(
      alphabet: PSAlphabets.digits,
      count: 4,
      left: 70.5,
      top: 53,
      cellWidth: 34,
      height: 42,
      pitch: 37,
    ),
    psRun(
      alphabet: PSAlphabets.digits,
      count: 2,
      left: 80.5,
      top: 101,
      cellWidth: 34,
      height: 42,
      pitch: 37,
    ),
  ];

  static const List<PlateLabel> _twoLineLabels = [
    PlateLabel(text: '-', box: PlateBox(49.5, 65.6, 21, 16.8), glyphHeight: 23.1),
  ];

  /// Car 2012–2021 on two lines.
  static final PlateSpec car2012TwoLine = PlateSpec(
    id: 'ps.gz.2012.car2l',
    country: PSCountries.gaza2021,
    canvasWidth: 300,
    canvasHeight: 150,
    panel: _twoLinePanel,
    borderWidthRatioOverride: 0.027,
    slots: _twoLineSlots,
    labels: _twoLineLabels,
    textGroups: _groups,
  );

  /// [car2012TwoLine] with the watermark.
  static final PlateSpec car2021TwoLine = PlateSpec(
    id: 'ps.gz.2021.car2l',
    country: PSCountries.gaza2021,
    canvasWidth: 300,
    canvasHeight: 150,
    panel: _twoLinePanel,
    borderWidthRatioOverride: 0.027,
    slots: _twoLineSlots,
    labels: _twoLineLabels,
    decals: [
      PlateDecal(
        image: AssetImage('assets/marks/palestine_watermark.png', package: 'palestine_plate'),
        box: PlateBox(10, 50, 282, 96),
      ),
    ],
    textGroups: _groups,
  );

  static final List<PlateSpec> all = [car2012, car2012TwoLine, car2021TwoLine, moto];
}
