import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:plate_core/plate_core.dart';

import 'lebanon_alphabets.dart';
import 'lebanon_colors.dart';
import 'lebanon_country.dart';
import 'lebanon_regions.dart';

/// [oneLine] (1040×220, band left) and [twoLine] (520×288, band top). The
/// number is one slot of one to six digits.
///
/// The one-line band text runs vertically on the real plate; here it prints
/// horizontally (core limitation).
abstract final class LebanonPlates {
  static const double _borderRatio = 0.022; // CALIBRATE
  static const int standardDigits = 6;

  static const double _oneLineWidth = 1040;
  static const double _oneLineHeight = 220;

  static const PlatePanel _oneLinePanel = PlatePanel(
    box: PlateBox(0, 0, 126, _oneLineHeight),
    flagScale: 0.62,
    captionScale: 1.1, // CALIBRATE
    padding: EdgeInsets.fromLTRB(10, 86, 8, 10), // CALIBRATE
  );

  /// The band as the first column, run out under the frame.
  static const PlateSection _oneLineBackground =
      PlateSection.columns(<PlatePart>[
        PlatePart(PlateSection.fill(PlateFill.panel), end: 126),
        PlatePart(PlateSection.plain),
      ]);

  static const List<PlateLabel> _oneLineLabels = <PlateLabel>[
    PlateLabel(
      text: 'لبنان',
      box: PlateBox(10, 14, 106, 56),
      glyphHeight: 50,
      color: LebanonColors.bandInk,
    ),
  ];

  /// Letter cell, wider to accommodate `MP` (two glyphs).
  static const PlateSlot _oneLineLetter = PlateSlot(
    alphabet: LebanonAlphabets.letters,
    box: PlateBox(160, 34, 110, 152),
  );

  static const double _twoLineWidth = 520;
  static const double _twoLineHeight = 288;

  static const PlatePanel _twoLinePanel = PlatePanel(
    box: PlateBox(0, 0, _twoLineWidth, 88),
    flagScale: 0.85,
    captionScale: 1.9, // CALIBRATE
    padding: EdgeInsets.fromLTRB(236, 16, 16, 16), // CALIBRATE
    direction: Axis.horizontal,
  );

  static const PlateSection _twoLineBackground = PlateSection.rows(<PlatePart>[
    PlatePart(PlateSection.fill(PlateFill.panel), end: 88),
    PlatePart(PlateSection.plain),
  ]);

  static const List<PlateLabel> _twoLineLabels = <PlateLabel>[
    PlateLabel(
      text: 'لبنان',
      box: PlateBox(16, 18, 130, 52),
      glyphHeight: 46,
      color: LebanonColors.bandInk,
    ),
  ];

  static const PlateSlot _twoLineLetter = PlateSlot(
    alphabet: LebanonAlphabets.letters,
    box: PlateBox(26, 116, 84, 140),
  );

  /// One slot of up to [standardDigits] digits, at least one; the text
  /// centres in the box.
  static PlateSlot _digits(PlateBox box, double pitch) => PlateSlot(
    alphabet: LebanonAlphabets.digits,
    box: box,
    length: standardDigits,
    minLength: 1,
    spacing: max(0, pitch - 0.6 * 0.72 * box.height),
  );

  static const List<PlateTextGroup> _groups = <PlateTextGroup>[
    PlateTextGroup(<int>[0], key: 'letter'),
    PlateTextGroup(<int>[1], key: 'serial'),
  ];

  static PlateSpec _spec({
    required String id,
    required double width,
    required double height,
    required PlatePanel panel,
    required PlateSection background,
    required List<PlateLabel> labels,
    required PlateSlot letter,
    required PlateSlot digits,
  }) => PlateSpec(
    id: id,
    country: LebanonCountry.private,
    canvasWidth: width,
    canvasHeight: height,
    panel: panel,
    background: background,
    slots: <PlateSlot>[letter, digits],
    labels: labels,
    textGroups: _groups,
    resolveRegion: LebanonRegions.captionOf,
    borderWidthRatioOverride: _borderRatio,
  );

  static final PlateSpec oneLine = _spec(
    id: 'lb.oneLine',
    width: _oneLineWidth,
    height: _oneLineHeight,
    panel: _oneLinePanel,
    background: _oneLineBackground,
    labels: _oneLineLabels,
    letter: _oneLineLetter,
    digits: _digits(const PlateBox(320, 34, 6 * 113, 152), 113),
  );

  static final PlateSpec twoLine = _spec(
    id: 'lb.twoLine',
    width: _twoLineWidth,
    height: _twoLineHeight,
    panel: _twoLinePanel,
    background: _twoLineBackground,
    labels: _twoLineLabels,
    letter: _twoLineLetter,
    digits: _digits(const PlateBox(120, 116, 6 * 62, 140), 62),
  );

  static List<PlateSpec> get all => <PlateSpec>[oneLine, twoLine];
}
