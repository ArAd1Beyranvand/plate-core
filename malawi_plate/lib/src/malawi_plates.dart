import 'dart:math';

import 'package:plate_alphabet/plate_alphabet.dart';
import 'package:plate_core/plate_core.dart';

import 'malawi_country.dart';

/// Where the ink sits, in plate units.
///
/// `License_plate_of_Malawi`, a photograph flattened to 520×124 (aspect 4.20,
/// the only size the offline fit gives; the article cites none). Ink rows
/// y 9–102.2 (93.2 tall, cy 55.6); letters x 20.8–161.5, digits x 200.2–489.8.
///
/// 93 units of ink would need a ~130-unit slot, more than the canvas, so the
/// box is 110 and the ink lands near 60% of the photo's.
abstract final class _Layout {
  static const double width = 520, height = 124;
  static const double cy = 55.6, box = 110;
  static const double lettersLeft = 20.8, lettersWidth = 140.7;
  static const double digitsLeft = 200.2, digitsWidth = 289.6;
}

/// Malawi's plate: two letters and four digits (`BC 5049`), silver on black.
/// Groups `letters`, `serial`. Pair with [MalawiThemes.private].
///
/// Not implemented: the two small printed marks above and below the digits
/// (a year stamp and a sticker), which carry no typed value, and any other
/// category; the article's table is empty and only one plate was measured. The
/// article names no Israel-specific value.
abstract final class MalawiPlates {
  static final PlateSpec private = PlateSpec(
    id: 'mw.private',
    country: MalawiCountry.malawi,
    canvasWidth: _Layout.width,
    canvasHeight: _Layout.height,
    panel: const PlatePanel(box: PlateBox(0, 0, 0, 0)),
    noPanel: true,
    slots: <PlateSlot>[
      _field(MalawiAlphabets.letters, 2, _Layout.lettersLeft, _Layout.lettersWidth),
      _field(MalawiAlphabets.digits, 4, _Layout.digitsLeft, _Layout.digitsWidth),
    ],
    textGroups: <PlateTextGroup>[
      PlateTextGroup(<int>[0], key: 'letters'),
      PlateTextGroup(<int>[1], key: 'serial'),
    ],
  );

  static List<PlateSpec> get all => <PlateSpec>[private];

  static PlateSlot _field(PlateAlphabet alphabet, int count, double left, double width) =>
      PlateSlot(
        alphabet: alphabet,
        box: PlateBox(left, _Layout.cy - _Layout.box / 2, width, _Layout.box),
        length: count,
        spacing: max(0, width / count - 0.6 * 0.72 * _Layout.box),
      );
}
