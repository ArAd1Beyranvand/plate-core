import 'dart:math';

import 'package:plate_alphabet/plate_alphabet.dart';
import 'package:plate_core/plate_core.dart';

import 'cook_islands_country.dart';

/// Where the ink sits, in plate units.
///
/// Car (`Cook_Islands_license_plate_graphic`, flattened by the offline stage
/// to the article's 372×134 mm): `KIA ORANA` ink y 10.5–21.5, x 145.2–223.5;
/// digits ink y 30–104.2, x 103.8–266.8; `COOK ISLANDS` ink y 110.2–121,
/// x 127.2–236.5. The fit's "3 glyphs" for the digit row disagrees with the
/// picture, which reads `1348`; the picture wins and the field is four digits.
///
/// The digit ink is 74 tall, which would need a ~135-unit box on a 134-unit
/// plate. The box is 112 (ink ~62, 83% of the artwork) so the captions keep
/// their room, and the field is widened to 190 around the artwork's centre
/// (185.3) because the engine's face is wider than the artwork's.
///
/// Motorcycle (`Cook_Islands_motorcycles`): the fit is CHECK and its numbers
/// are rejected. The photo shows three scooters whose plates are ~30 px wide,
/// two stacked rows, three letters over three digits (`AAP 676`). Everything
/// in the `moto*` constants is an ESTIMATE on an assumed 200×145 canvas.
abstract final class _Layout {
  static const double carWidth = 372, carHeight = 134;
  static const double carCx = 185.3, carDigitsBox = 112, carDigitsWidth = 190;
  static const double carDigitsCy = 67.1; // ink 30–104.2
  static const double captionBox = 20; // ink 11 / 0.55
  static const double captionWidth = 130;
  static const double topCx = 184.4, topCy = 16; // ink 10.5–21.5
  static const double bottomCx = 181.9, bottomCy = 115.6; // ink 110.2–121

  static const double motoWidth = 200, motoHeight = 145;
  static const double motoBox = 62, motoFieldWidth = 150;
  static const double motoLettersCy = 40, motoDigitsCy = 105;
}

/// The Cook Islands' current plates, Australian-standard size stamped on New
/// Zealand dies. Pair [car] with [CookIslandsThemes.car] and [motorcycle]
/// with [CookIslandsThemes.motorcycle].
///
/// Not implemented: older series (the article gives none). The article names
/// no Israel-specific value.
abstract final class CookIslandsPlates {
  /// Four digits between the captions `KIA ORANA` and `COOK ISLANDS`.
  static final PlateSpec car = _spec(
    'ck.car',
    _Layout.carWidth,
    _Layout.carHeight,
    slots: <PlateSlot>[
      PlateSlot(
        alphabet: CookIslandsAlphabets.digits,
        box: PlateBox(
          _Layout.carCx - _Layout.carDigitsWidth / 2,
          _Layout.carDigitsCy - _Layout.carDigitsBox / 2,
          _Layout.carDigitsWidth,
          _Layout.carDigitsBox,
        ),
        length: 4,
      ),
    ],
    groups: <PlateTextGroup>[
      PlateTextGroup(<int>[0], key: 'serial'),
    ],
    labels: <PlateLabel>[
      _caption('KIA ORANA', _Layout.topCx, _Layout.topCy),
      _caption('COOK ISLANDS', _Layout.bottomCx, _Layout.bottomCy),
    ],
  );

  /// Three letters over three digits.
  static final PlateSpec motorcycle = _spec(
    'ck.motorcycle',
    _Layout.motoWidth,
    _Layout.motoHeight,
    slots: <PlateSlot>[
      _motoField(CookIslandsAlphabets.letters, _Layout.motoLettersCy),
      _motoField(CookIslandsAlphabets.digits, _Layout.motoDigitsCy),
    ],
    groups: <PlateTextGroup>[
      PlateTextGroup(<int>[0], key: 'letters'),
      PlateTextGroup(<int>[1], key: 'serial'),
    ],
  );

  static List<PlateSpec> get all => <PlateSpec>[car, motorcycle];

  static PlateSlot _motoField(PlateAlphabet alphabet, double cy) => PlateSlot(
    alphabet: alphabet,
    box: PlateBox(
      (_Layout.motoWidth - _Layout.motoFieldWidth) / 2,
      cy - _Layout.motoBox / 2,
      _Layout.motoFieldWidth,
      _Layout.motoBox,
    ),
    length: 3,
    spacing: max(0, _Layout.motoFieldWidth / 3 - 0.6 * 0.72 * _Layout.motoBox),
  );

  static PlateLabel _caption(String text, double cx, double cy) => PlateLabel(
    text: text,
    box: PlateBox(
      cx - _Layout.captionWidth / 2,
      cy - _Layout.captionBox / 2,
      _Layout.captionWidth,
      _Layout.captionBox,
    ),
    glyphHeight: _Layout.captionBox,
  );

  static PlateSpec _spec(
    String id,
    double width,
    double height, {
    required List<PlateSlot> slots,
    required List<PlateTextGroup> groups,
    List<PlateLabel> labels = const <PlateLabel>[],
  }) => PlateSpec(
    id: id,
    country: CookIslandsCountry.cook_islands,
    canvasWidth: width,
    canvasHeight: height,
    panel: const PlatePanel(box: PlateBox(0, 0, 0, 0)),
    noPanel: true,
    slots: slots,
    textGroups: groups,
    labels: labels,
  );
}
