import 'package:flutter/widgets.dart' show EdgeInsets;
import 'package:plate_alphabet/plate_alphabet.dart';
import 'package:plate_core/plate_core.dart';

import 'french_polynesia_colors.dart';
import 'french_polynesia_country.dart';

/// Where the ink sits, in plate units, measured off the article's photo
/// (`LpgenI.png`) flattened to 520×110.
///
/// The band geometry is France's (blue to x 52, 46×70.4 star panel). The
/// serial row is one ink run 7.5–102.2 tall: six digits in one field over
/// x 115–372 and the letter `P` over 417.5–455.5. Ink is about 55% of a box
/// and a box cannot leave the canvas, so the ~60 ink is 63% of the 94.7
/// reference.
///
/// Not drawn: the 1993 series photo (`123456 P` on yellow, the same format).
abstract final class _Layout {
  static const double width = 520, height = 110;
  static const double bandEnd = 52, bandCx = 26.75;
  static const double panelWidth = 46, panelHeight = 70.4;
  static const double fTop = 65.5, fHeight = 22, fGlyph = 39, fWidth = 20;

  static const double digitsLeft = 115, digitsWidth = 257;
  static const double letterLeft = 417.5, letterWidth = 38;
}

/// Groups `number` and `letter`. The EU band and its `F` come from the
/// background and the panel. One design serves the yellow front and white
/// rear; the colour is the theme's.
abstract final class FrenchPolynesiaPlates {
  static final PlateSpec regular = PlateSpec(
    id: 'pf.regular',
    country: FrenchPolynesiaCountry.french_polynesia,
    canvasWidth: _Layout.width,
    canvasHeight: _Layout.height,
    panel: PlatePanel(
      box: PlateBox(
        _Layout.bandCx - _Layout.panelWidth / 2,
        0,
        _Layout.panelWidth,
        _Layout.panelHeight,
      ),
      padding: EdgeInsets.zero,
    ),
    background: const PlateSection.columns(<PlatePart>[
      PlatePart(PlateSection.fill(PlateFill.panel), end: _Layout.bandEnd),
      PlatePart(PlateSection.plain),
    ]),
    slots: const <PlateSlot>[
      PlateSlot(
        alphabet: FrenchPolynesiaAlphabets.digits,
        box: PlateBox(_Layout.digitsLeft, 0, _Layout.digitsWidth, 110),
        length: 6,
      ),
      PlateSlot(
        alphabet: FrenchPolynesiaAlphabets.letters,
        box: PlateBox(_Layout.letterLeft, 0, _Layout.letterWidth, 110),
        length: 1,
      ),
    ],
    labels: <PlateLabel>[
      PlateLabel(
        text: 'F',
        box: PlateBox(
          _Layout.bandCx - _Layout.fWidth / 2,
          _Layout.fTop,
          _Layout.fWidth,
          _Layout.fHeight,
        ),
        glyphHeight: _Layout.fGlyph,
        color: FrenchPolynesiaColors.white,
      ),
    ],
    textGroups: const <PlateTextGroup>[
      PlateTextGroup(<int>[0], key: 'number'),
      PlateTextGroup(<int>[1], key: 'letter'),
    ],
  );

  static List<PlateSpec> get all => <PlateSpec>[regular];
}
