import 'package:flutter/widgets.dart';
import 'package:plate_alphabet/plate_alphabet.dart';
import 'package:plate_core/plate_core.dart';

import 'cayman_islands_colors.dart';
import 'cayman_islands_country.dart';

/// Where the ink sits, in millimetres on the 300×152 plate the infobox gives.
///
/// The offline stage flattened each photo to 152×71 units (aspect 2.15; the
/// artwork is 2.01, the infobox 1.97). Positions are those units scaled to
/// the physical size: x × 300/152, y × 152/71.
///
/// * `orange`: digits y 12.8..49.5 (ink 36.7 units), "131" x ~13..61 and
///   "996" x ~91..146; caption ink y 52.5..60.5, x 24..129.5.
/// * `hire` (CHECK, cropped on the left): digits y 13.8..49.5, caption
///   y 52.8..65.2 x 8.2..131.8.
/// * `taxi`: digits y 14.8..54, fields x 13.2..70.8 and 81.8..139; "TAXI"
///   y 4.8..11.5 x ~67..86; blue caption y 56.8..63.5 x 35.5..117.2.
/// * `graphic`: five digits y 13.8..46 x 27.2..123.8; caption y 50.2..59.8
///   x 17..135.5.
///
/// **Under-height ink, accepted.** The reference digits are ~77 mm tall
/// (`orange`); `glyphStyle` yields ink of ~0.55 of the slot height and a run
/// wider than its box is scaled down whole, and DejaVu Bold's digits are far
/// wider than the plate's condensed face. Each field box is sized to the
/// run's natural width (3 × 0.6 × 0.72 × height), centred on the measured
/// field centre, so the ink is ~59 mm (76%), and the five-digit plate's
/// ~66 mm (95% of 69). The boxes are wider than the printed fields.
///
/// **Fields, not cells.** Each printed run is one `PlateSlot`.
///
/// Not implemented: the governor's crown plate (front only, no characters),
/// the 2003 quincentennial "Q" plates (not current), and the stars and
/// turtle printed in the taxi plate's corners.
abstract final class _Layout {
  static const double width = 300;
  static const double height = 152;

  // 3 + 3 plate: orange/hire average, fields centred ±73 about the middle.
  static const double pairHeight = 108;
  static const double pairBoxWidth = 140;
  static const double pairCentreOffset = 73;
  static const double pairDigitCentreY = 67.2;
  static const double pairCaptionCentreY = 121;
  static const double pairCaptionGlyph = 28;

  // Taxi: digits ink 39.2 units, lower, fields centred ±67.
  static const double taxiHeight = 103;
  static const double taxiBoxWidth = 134;
  static const double taxiCentreOffset = 67;
  static const double taxiDigitCentreY = 73.6;
  static const double taxiCaptionCentreY = 128.9;
  static const double taxiCaptionGlyph = 22;
  static const double taxiMarkCentreY = 17.4;
  static const double taxiMarkGlyph = 22;

  // Five-digit private plate.
  static const double singleHeight = 120;
  static const double singleBoxWidth = 259;
  static const double singleDigitCentreY = 64;
  static const double singleCaptionCentreY = 117.7;
  static const double singleCaptionGlyph = 30;

  static const double captionBoxWidth = 240;
  static const double captionBoxHeight = 30;
  static const double centreX = width / 2;
}

/// The Cayman Islands' plate geometries. The livery is the theme's.
///
/// [pair] (`123 456`, fields `first` and `second`) serves private, disabled,
/// heavy-goods and hire plates; [taxi] adds the "TAXI" mark and a blue,
/// lower caption; [single] (`12345`, field `serial`) is the five-digit
/// private plate.
abstract final class CaymanIslandsPlates {
  static const List<PlateTextGroup> _pairGroups = <PlateTextGroup>[
    PlateTextGroup(<int>[0], key: 'first'),
    PlateTextGroup(<int>[1], key: 'second'),
  ];

  static PlateSlot _field(
    double centreX,
    double centreY,
    double width,
    double height,
    int length,
  ) => PlateSlot(
    alphabet: CaymanIslandsAlphabets.digits,
    box: PlateBox(centreX - width / 2, centreY - height / 2, width, height),
    length: length,
  );

  static PlateLabel _caption(double centreY, double glyph, {Color? color}) => PlateLabel(
    text: 'CAYMAN ISLANDS',
    box: PlateBox(
      _Layout.centreX - _Layout.captionBoxWidth / 2,
      centreY - _Layout.captionBoxHeight / 2,
      _Layout.captionBoxWidth,
      _Layout.captionBoxHeight,
    ),
    glyphHeight: glyph,
    color: color,
  );

  static PlateSpec _spec(
    String id,
    List<PlateSlot> slots,
    List<PlateLabel> labels,
    List<PlateTextGroup> groups,
  ) => PlateSpec(
    id: id,
    country: CaymanIslandsCountry.cayman_islands,
    canvasWidth: _Layout.width,
    canvasHeight: _Layout.height,
    noPanel: true,
    panel: const PlatePanel(box: PlateBox(0, 0, 0, _Layout.height)),
    slots: slots,
    labels: labels,
    textGroups: groups,
  );

  static final PlateSpec pair = _spec(
    'ky.pair',
    <PlateSlot>[
      for (final double side in <double>[-1, 1])
        _field(
          _Layout.centreX + side * _Layout.pairCentreOffset,
          _Layout.pairDigitCentreY,
          _Layout.pairBoxWidth,
          _Layout.pairHeight,
          3,
        ),
    ],
    <PlateLabel>[_caption(_Layout.pairCaptionCentreY, _Layout.pairCaptionGlyph)],
    _pairGroups,
  );

  static final PlateSpec taxi = _spec(
    'ky.taxi',
    <PlateSlot>[
      for (final double side in <double>[-1, 1])
        _field(
          _Layout.centreX + side * _Layout.taxiCentreOffset,
          _Layout.taxiDigitCentreY,
          _Layout.taxiBoxWidth,
          _Layout.taxiHeight,
          3,
        ),
    ],
    <PlateLabel>[
      PlateLabel(
        text: 'TAXI',
        box: PlateBox(_Layout.centreX - 50, _Layout.taxiMarkCentreY - 12, 100, 24),
        glyphHeight: _Layout.taxiMarkGlyph,
      ),
      // The label's colour is meant for bands; here it is the one blue ink.
      _caption(
        _Layout.taxiCaptionCentreY,
        _Layout.taxiCaptionGlyph,
        color: CaymanIslandsColors.blue,
      ),
    ],
    _pairGroups,
  );

  static final PlateSpec single = _spec(
    'ky.single',
    <PlateSlot>[
      _field(
        _Layout.centreX - 1,
        _Layout.singleDigitCentreY,
        _Layout.singleBoxWidth,
        _Layout.singleHeight,
        5,
      ),
    ],
    <PlateLabel>[_caption(_Layout.singleCaptionCentreY, _Layout.singleCaptionGlyph)],
    const <PlateTextGroup>[
      PlateTextGroup(<int>[0], key: 'serial'),
    ],
  );
}
