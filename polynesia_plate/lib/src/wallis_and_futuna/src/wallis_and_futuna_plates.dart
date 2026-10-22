import 'dart:math';

import 'package:flutter/widgets.dart' show EdgeInsets;
import 'package:plate_alphabet/plate_alphabet.dart';
import 'package:plate_core/plate_core.dart';

import 'wallis_and_futuna_colors.dart';
import 'wallis_and_futuna_country.dart';

/// Where the ink sits, in plate units (520×110 mm, European size), measured on
/// the flattened `French_number_plate_sample_from_Wallis_and_Futuna__988_`
/// photo: digit ink rows 19–90 (71 tall, centre 54.5), the four digits
/// 108.5–302 (pitch 193.5 / 4 = 48.4) and the printed `WF` 363.8–458.
///
/// Ink is about 55% of a box and a box cannot leave the canvas, so the 110 box
/// gives ~60 ink, 85% of the 71 measured. `WF` is fixed text on every plate,
/// so it is a label, not a slot, centred on its measured span (410.9); its
/// glyph is 100 so the pair fits the 94.2 span.
///
/// The EU band is blue to x 47 on the photo; 50 is used, the same die as
/// France's (52), with the stars and `F` at France's measured geometry.
///
/// Not drawn: the 1987 and undated "graphic" white-on-black series (`1234 WF`
/// and `WF 1234`); their pictures are history, and the infobox's black on
/// white/yellow is what the current photo shows.
abstract final class _Layout {
  static const double width = 520, height = 110;
  static const double bandEnd = 50, bandCx = 26.75;
  static const double digitsLeft = 108.5, digitsRight = 302;
  static const double digitsCount = 4;
  static const double wfCentre = 410.9, wfGlyph = 100, wfWidth = 100;

  /// The stars' panel block, and the `F` under it (France's photo: cap 21.5).
  static const double panelWidth = 46, panelHeight = 70.4;
  static const double fTop = 65.5, fHeight = 22, fGlyph = 39, fWidth = 20;
}

/// Group `number` — the four-digit serial; `WF` is printed. The front plate
/// is white and the rear yellow: the same spec under two themes.
abstract final class WallisAndFutunaPlates {
  static final PlateSpec private = _spec();

  static List<PlateSpec> get all => <PlateSpec>[private];

  static PlateSpec _spec() {
    const double pitch = (_Layout.digitsRight - _Layout.digitsLeft) / _Layout.digitsCount;
    return PlateSpec(
      id: 'wf.private',
      country: WallisAndFutunaCountry.wallis_and_futuna,
      canvasWidth: _Layout.width,
      canvasHeight: _Layout.height,
      panel: PlatePanel(
        box: const PlateBox(
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
      slots: <PlateSlot>[
        PlateSlot(
          alphabet: WallisAndFutunaAlphabets.digits,
          box: const PlateBox(
            _Layout.digitsLeft,
            0,
            _Layout.digitsRight - _Layout.digitsLeft,
            _Layout.height,
          ),
          length: 4,
          spacing: max(0, pitch - 0.6 * 0.72 * _Layout.height),
        ),
      ],
      labels: const <PlateLabel>[
        PlateLabel(
          text: 'F',
          box: PlateBox(
            _Layout.bandCx - _Layout.fWidth / 2,
            _Layout.fTop,
            _Layout.fWidth,
            _Layout.fHeight,
          ),
          glyphHeight: _Layout.fGlyph,
          color: WallisAndFutunaColors.white,
        ),
        PlateLabel(
          text: 'WF',
          box: PlateBox(_Layout.wfCentre - _Layout.wfWidth / 2, 0, _Layout.wfWidth, _Layout.height),
          glyphHeight: _Layout.wfGlyph,
        ),
      ],
      textGroups: const <PlateTextGroup>[
        PlateTextGroup(<int>[0], key: 'number'),
      ],
    );
  }
}
