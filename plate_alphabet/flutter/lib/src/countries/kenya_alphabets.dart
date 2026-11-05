import 'package:plate_core/plate_core.dart';

/// The alphabets behind Kenyan slots.
///
/// The article names no excluded letter for the current series, so [letters]
/// is the full Latin capital set.
abstract final class KenyaAlphabets {
  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  /// The class mark between a diplomatic number's mission and serial: `CD` for
  /// an embassy, `UN` for a UN body. Picked, never typed.
  static const PlateAlphabet diplomaticType = PlateAlphabet(
    id: 'ke.diplomatic.type',
    characters: <String>['CD', 'UN'],
    input: AlphabetInput.chosen,
  );
}
