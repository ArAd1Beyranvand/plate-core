import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:plate_alphabet/plate_alphabet.dart';
import 'package:plate_core/plate_core.dart';

import 'bonaire_colors.dart';
import 'bonaire_country.dart';

/// Where the ink sits, in plate units.
///
/// Every reference is a photograph flattened to 2080×1024 and read here at
/// 520×256 (÷4; the article's 152×300 mm is 1.97, the flattening 2.03). Ink
/// extents come from the brief's row table; field spans that the table splits
/// into glyph runs were read off the flattened sheet (÷0.968 from sheet pixels).
/// The Saba plate is CHECK-fitted: it was read off its 330×168 original and
/// scaled by 1.576 (x) and 1.524 (y).
///
/// Reference ink is far taller than a slot can draw: the digits are ~110–145
/// tall on a 256 plate and narrow, but a slot's glyph is as wide as
/// `0.6 × 0.72 × box`, so a box tall enough for the height would overrun the
/// row. Boxes are sized by the measured digit pitch instead, and ink lands at
/// roughly 55–70% of the reference height.
abstract final class _Layout {
  static const double width = 520, height = 256;

  /// Glyph box height shared by the 2013 and 2005–2007 plates, from a digit
  /// pitch of ~58 (`58 / (0.6 × 0.72)` ≈ 134).
  static const double rowBox = 130;
  static const double rowCy = 113.5; // ink 58–169 (2013), 68.8–194 (navy)

  /// 2013: "V" ink x 58.8–135 (centre 97); dash centre 160; digits 179–402.
  static const double whitePrefixCx = 97, whiteDashCx = 160;
  static const double whiteNumber0 = 170, whiteNumberW = 240;
  static const double whiteSplit = 175; // landscape strip starts, y
  static const double whiteSeaTop = 238; // sea stripe under the landscape
  static const PlateBox whiteCaption = PlateBox(130, 14, 280, 30); // y17.8–41.2
  static const PlateBox whiteSlogan = PlateBox(160, 43, 220, 12);
  static const PlateBox whiteSticker = PlateBox(445, 57, 68, 119);

  /// Navy 2007: "V" 23–144 (centre 84); dash centre 168; digits 197–411;
  /// sticker 430–507 × 67–196.
  static const double bluePrefixCx = 84, blueDashCx = 168;
  static const double blueNumber0 = 185, blueNumberW = 240;
  static const PlateBox blueCaption = PlateBox(110, 14, 290, 36); // y17.8–51.5
  static const PlateBox blueFooter = PlateBox(110, 208, 290, 36); // y212.8–238
  static const PlateBox blueSticker = PlateBox(430, 67, 77, 129);

  /// St. Eustatius: "E" x 110–168, "30" x 343–466, ink y 62–207.
  static const double statiaBox = 150, statiaCy = 134.5;
  static const PlateBox statiaPrefix = PlateBox(104, 59.5, 72, statiaBox);
  static const PlateBox statiaNumber = PlateBox(330, 59.5, 160, statiaBox);
  static const PlateBox statiaCaption = PlateBox(110, 10, 300, 36);
  static const PlateBox statiaFooter = PlateBox(120, 218, 290, 22);

  /// Saba: "S" x 68–118, "240" x 265–457, ink y 79–186.
  static const double sabaBox = 150, sabaCy = 132.5;
  static const PlateBox sabaPrefix = PlateBox(60, 57.5, 66, sabaBox);
  static const PlateBox sabaNumber = PlateBox(245, 57.5, 232, sabaBox);
  static const PlateBox sabaSticker = PlateBox(8, 68, 35, 115);
  static const PlateBox sabaCaption = PlateBox(326, 192, 180, 26);
}

/// Bonaire's current plates (Caribbean Netherlands, 152 × 300 mm).
///
/// Groups `prefix` and `number`; the dash on [bonaire] and [blue] is a label.
/// Pair each with the theme of the same name in `BonaireThemes`.
///
/// Implemented: the 2013 plate ([bonaire]; `B` private, `V` trucks and the
/// other type letters share it), the navy 2005–2007 plate ([blue]), the
/// 2007 St. Eustatius plate ([statia]) and the 2011 Saba plate ([saba]).
/// Not implemented: the 1976 St. Eustatius, 1978 Saba and 1994 Bonaire plates
/// (long out of issue). Not drawn: the 2013 landscape's buildings and
/// flamingo, the St. Eustatius coat of arms and the Saba island and flag disc
/// (illustrations, no shape the spec can draw). The article names nothing
/// Israel-specific.
abstract final class BonairePlates {
  static final PlateSpec bonaire = _spec(
    'bq.bonaire',
    prefix: _field(
      BonaireAlphabets.letters,
      PlateBox(_Layout.whitePrefixCx - 57, _Layout.rowCy - _Layout.rowBox / 2, 114, _Layout.rowBox),
      length: 2,
      minLength: 1,
    ),
    number: _field(
      BonaireAlphabets.digits,
      PlateBox(
        _Layout.whiteNumber0,
        _Layout.rowCy - _Layout.rowBox / 2,
        _Layout.whiteNumberW,
        _Layout.rowBox,
      ),
      length: 5,
      minLength: 3,
    ),
    background: const PlateSection.rows(<PlatePart>[
      PlatePart(PlateSection.plain, end: _Layout.whiteSplit),
      PlatePart(PlateSection.fill(PlateFill.color(BonaireColors.sky)), end: _Layout.whiteSeaTop),
      PlatePart(PlateSection.fill(PlateFill.color(BonaireColors.sea))),
    ]),
    bands: _sticker(_Layout.whiteSticker, BonaireColors.black, BonaireColors.white),
    labels: <PlateLabel>[
      _dash(_Layout.whiteDashCx),
      const PlateLabel(
        text: 'BONAIRE',
        box: _Layout.whiteCaption,
        glyphHeight: 32,
        color: BonaireColors.caption,
      ),
      const PlateLabel(
        text: 'DIVERS PARADISE',
        box: _Layout.whiteSlogan,
        glyphHeight: 11,
        color: BonaireColors.caption,
      ),
    ],
  );

  static final PlateSpec blue = _spec(
    'bq.blue',
    prefix: _field(
      BonaireAlphabets.letters,
      PlateBox(_Layout.bluePrefixCx - 64, _Layout.rowCy - _Layout.rowBox / 2, 128, _Layout.rowBox),
      length: 2,
      minLength: 1,
    ),
    number: _field(
      BonaireAlphabets.digits,
      PlateBox(
        _Layout.blueNumber0,
        _Layout.rowCy - _Layout.rowBox / 2,
        _Layout.blueNumberW,
        _Layout.rowBox,
      ),
      length: 5,
      minLength: 3,
    ),
    bands: <PlateBand>[
      PlateBand(
        box: _Layout.blueSticker,
        color: BonaireColors.cream,
        topCornerRadius: 4,
        bottomCornerRadius: 4,
      ),
    ],
    labels: <PlateLabel>[
      _dash(_Layout.blueDashCx),
      const PlateLabel(text: 'BONAIRE, N.A.', box: _Layout.blueCaption, glyphHeight: 40),
      const PlateLabel(text: "DIVER'S PARADISE", box: _Layout.blueFooter, glyphHeight: 34),
    ],
  );

  static final PlateSpec statia = _spec(
    'bq.statia',
    prefix: _field(BonaireAlphabets.letters, _Layout.statiaPrefix, length: 1),
    number: _field(BonaireAlphabets.digits, _Layout.statiaNumber, length: 4, minLength: 1),
    labels: const <PlateLabel>[
      PlateLabel(text: 'ST. EUSTATIUS', box: _Layout.statiaCaption, glyphHeight: 38),
      PlateLabel(text: 'THE HISTORIC GEM', box: _Layout.statiaFooter, glyphHeight: 18),
    ],
  );

  static final PlateSpec saba = _spec(
    'bq.saba',
    prefix: _field(BonaireAlphabets.letters, _Layout.sabaPrefix, length: 1),
    number: _field(BonaireAlphabets.digits, _Layout.sabaNumber, length: 4, minLength: 3),
    bands: const <PlateBand>[
      PlateBand(
        box: _Layout.sabaSticker,
        color: BonaireColors.sabaInk,
        topCornerRadius: 3,
        bottomCornerRadius: 3,
      ),
    ],
    labels: const <PlateLabel>[
      PlateLabel(text: 'SABA  THE UNSPOILED QUEEN', box: _Layout.sabaCaption, glyphHeight: 16),
    ],
  );

  static List<PlateSpec> get all => <PlateSpec>[bonaire, blue, statia, saba];

  /// One run of characters, printed and typed as a unit. Fixed pitch is
  /// `box.width / length`, so the glyph advance matches it.
  static PlateSlot _field(
    PlateAlphabet alphabet,
    PlateBox box, {
    required int length,
    int? minLength,
  }) => PlateSlot(
    alphabet: alphabet,
    box: box,
    length: length,
    minLength: minLength,
    spacing: max(0, box.width / length - 0.6 * 0.72 * box.height),
  );

  /// The sticker window: a rim with the field colour inset 5 units. It
  /// floats clear of the plate edge.
  static List<PlateBand> _sticker(PlateBox box, Color rim, Color fill) => <PlateBand>[
    PlateBand(box: box, color: rim, topCornerRadius: 8, bottomCornerRadius: 8),
    PlateBand(
      box: PlateBox(box.left + 5, box.top + 5, box.width - 10, box.height - 10),
      color: fill,
      topCornerRadius: 4,
      bottomCornerRadius: 4,
    ),
  ];

  static PlateLabel _dash(double cx) => PlateLabel(
    text: '-',
    box: PlateBox(cx - 20, _Layout.rowCy - _Layout.rowBox / 2, 40, _Layout.rowBox),
    glyphHeight: _Layout.rowBox,
  );

  static PlateSpec _spec(
    String id, {
    required PlateSlot prefix,
    required PlateSlot number,
    PlateSection background = PlateSection.plain,
    List<PlateBand> bands = const <PlateBand>[],
    List<PlateLabel> labels = const <PlateLabel>[],
  }) => PlateSpec(
    id: id,
    country: BonaireCountry.bonaire,
    canvasWidth: _Layout.width,
    canvasHeight: _Layout.height,
    panel: const PlatePanel(box: PlateBox(0, 0, 0, 0)),
    noPanel: true,
    background: background,
    bands: bands,
    slots: <PlateSlot>[prefix, number],
    labels: labels,
    textGroups: <PlateTextGroup>[
      PlateTextGroup(<int>[0], key: 'prefix'),
      PlateTextGroup(<int>[1], key: 'number'),
    ],
  );
}
