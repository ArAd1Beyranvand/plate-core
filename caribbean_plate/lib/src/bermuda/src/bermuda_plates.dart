import 'dart:math';

import 'package:plate_alphabet/plate_alphabet.dart';
import 'package:plate_core/plate_core.dart';

import 'bermuda_country.dart';

/// Where the ink sits, in millimetres.
///
/// The article says most plates are the European 520×110 and only
/// personalised ones the 152×300 North American size, so the canvas is
/// 520×110.
///
/// **Private (`Bermuda_license_plate_graphic`, `License_plate_Bermuda_1975`).**
/// Five digits in one run. The graphic is a bare run of digits with no plate
/// around it (aspect 8.04, ink 2.2–30.5 of ~33 rows), and the 1975 photo's
/// flattening is at the wrong aspect (3.48), so only fractions carry over:
/// the run spans 10%–91% of the width (x 14.8–138.5 of 152), which on 520
/// is x 50..474, centred at ~262. Measured, but rescaled from a mismatched
/// plate rectangle.
///
/// **Prefixed and suffixed** (`CL123`, `L1234`, `RMC001`, `123Y`): no image
/// exists, so these are unmeasured. Cells use the pitch of a seven-character
/// run (the personalised maximum) centred on the plate.
///
/// **Under-height ink, accepted.** The artwork's ink fills ~85% of the plate
/// height; `glyphStyle` makes ink ~55% of the slot, which would need a slot
/// taller than the plate. Slots are as tall as the plate allows; `plate_core`
/// is unchanged.
abstract final class _Layout {
  static const double width = 520;
  static const double height = 110;
  static const double slotTop = 3;
  static const double slotHeight = 104;

  static const double privateLeft = 50;
  static const double privatePitch = 84;

  static const double mixedPitch = 64;
  static const double mixedGap = 20;
  static const double suffixPitch = 84;
}

/// Bermuda's current plates, black on white (`BermudaThemes.plate`).
///
/// * [private] — five digits, group `serial`.
/// * [prefixed] — a class prefix of one to three letters (`CL`, `L`, `IN`,
///   `HA`, `LP`, `T`, `CM`, `RMC`, motorcycle pairs) then three or four
///   digits; groups `letters`, `serial`.
/// * [suffixed] — three digits and a trailing letter (auxiliary cycles);
///   groups `serial`, `letter`.
///
/// Not implemented: the pre-1975 white-on-black `P 1234` plate and the US
/// Forces `A 1234` plate (historic), and the personalised 152×300 plate on
/// a map of the island. The article names no Israel-specific value.
abstract final class BermudaPlates {
  static final PlateSpec private = _spec(
    'bm.private',
    slots: <PlateSlot>[
      _slot(BermudaAlphabets.digits, _Layout.privateLeft, _Layout.privatePitch, 5),
    ],
    groups: <String>['serial'],
  );

  static final PlateSpec prefixed = () {
    const double p = _Layout.mixedPitch;
    const double total = 7 * p + _Layout.mixedGap;
    const double left = (_Layout.width - total) / 2;
    return _spec(
      'bm.prefixed',
      slots: <PlateSlot>[
        _variable(BermudaAlphabets.letters, left, p, 3, minLength: 1),
        _variable(BermudaAlphabets.digits, left + 3 * p + _Layout.mixedGap, p, 4, minLength: 3),
      ],
      groups: <String>['letters', 'serial'],
    );
  }();

  static final PlateSpec suffixed = () {
    const double p = _Layout.suffixPitch;
    const double left = (_Layout.width - 4 * p) / 2;
    return _spec(
      'bm.suffixed',
      slots: <PlateSlot>[
        _slot(BermudaAlphabets.digits, left, p, 3),
        _slot(BermudaAlphabets.letters, left + 3 * p, p, 1),
      ],
      groups: <String>['serial', 'letter'],
    );
  }();

  static List<PlateSpec> get all => <PlateSpec>[private, prefixed, suffixed];

  /// A fixed run of [count] cells of [pitch]; spacing is what remains of the
  /// pitch after a glyph's ~0.6 em advance.
  static PlateSlot _slot(PlateAlphabet alphabet, double left, double pitch, int count) => PlateSlot(
    alphabet: alphabet,
    box: PlateBox(left, _Layout.slotTop, count * pitch, _Layout.slotHeight),
    length: count,
    spacing: max(0, pitch - 0.6 * 0.72 * _Layout.slotHeight),
  );

  /// A run of [minLength] to [max] cells; the box fits the longest and the
  /// text is centred in it.
  static PlateSlot _variable(
    PlateAlphabet alphabet,
    double left,
    double pitch,
    int max, {
    required int minLength,
  }) => PlateSlot(
    alphabet: alphabet,
    box: PlateBox(left, _Layout.slotTop, max * pitch, _Layout.slotHeight),
    length: max,
    minLength: minLength,
  );

  static PlateSpec _spec(
    String id, {
    required List<PlateSlot> slots,
    required List<String> groups,
  }) => PlateSpec(
    id: id,
    country: BermudaCountry.bermuda,
    canvasWidth: _Layout.width,
    canvasHeight: _Layout.height,
    panel: const PlatePanel(box: PlateBox(0, 0, 0, 0)),
    noPanel: true,
    slots: slots,
    textGroups: <PlateTextGroup>[
      for (int i = 0; i < groups.length; i++) PlateTextGroup(<int>[i], key: groups[i]),
    ],
  );
}
