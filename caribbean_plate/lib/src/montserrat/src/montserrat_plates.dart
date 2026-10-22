import 'package:plate_alphabet/plate_alphabet.dart';
import 'package:plate_core/plate_core.dart';

import 'montserrat_country.dart';

/// Where the ink sits, in plate units.
///
/// One photo, `Montserrat___Car_licence_plate_2000s_M_1667`, flattened at
/// aspect 2.05 to 520×254 (the article gives no size). Ink y 75.2–198.8
/// (123.6 tall, centre 137). Type letter x 52.8–144.5; digits x 176.8–456.8.
///
/// The brief's glyph count read three digits, the picture shows `1667`, and the
/// article says "up to four numbers": the picture and prose agree, so the field
/// is 1 to 4 digits.
///
/// The reference ink would need a ~225-unit box on a 254 plate; the box is
/// 180, which fits four digits across the measured span (0.72 × 180 × 0.56 × 4
/// ≈ 290 against 280) and lands the ink below the photo's.
abstract final class _Layout {
  static const double width = 520, height = 254;
  static const double cy = 137, box = 180;
  static const double letterLeft = 52.8, letterWidth = 91.7;
  static const double digitLeft = 176.8, digitWidth = 280;
}

/// Montserrat's plate: a type letter ('M' private, 'R' rental, ...) and one to
/// four digits. Groups `type`, `serial`. Pair with [MontserratThemes.private].
///
/// Not implemented: other backgrounds ("the background colour can vary"), for
/// which no photograph exists. The other photos in the article are other
/// territories. The article names no Israel-specific value.
abstract final class MontserratPlates {
  static final PlateSpec private = PlateSpec(
    id: 'ms.private',
    country: MontserratCountry.montserrat,
    canvasWidth: _Layout.width,
    canvasHeight: _Layout.height,
    panel: const PlatePanel(box: PlateBox(0, 0, 0, 0)),
    noPanel: true,
    slots: const <PlateSlot>[
      PlateSlot(
        alphabet: MontserratAlphabets.letters,
        box: PlateBox(
          _Layout.letterLeft,
          _Layout.cy - _Layout.box / 2,
          _Layout.letterWidth,
          _Layout.box,
        ),
        length: 1,
      ),
      PlateSlot(
        alphabet: MontserratAlphabets.digits,
        box: PlateBox(
          _Layout.digitLeft,
          _Layout.cy - _Layout.box / 2,
          _Layout.digitWidth,
          _Layout.box,
        ),
        length: 4,
        minLength: 1,
      ),
    ],
    textGroups: <PlateTextGroup>[
      PlateTextGroup(<int>[0], key: 'type'),
      PlateTextGroup(<int>[1], key: 'serial'),
    ],
  );

  static List<PlateSpec> get all => <PlateSpec>[private];
}
