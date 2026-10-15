import 'package:plate_core/plate_core.dart';

/// The alphabets behind Uzbek slots.
///
/// Plates use only Latin capitals and ASCII digits. The article states no
/// forbidden letters, so every letter is allowed.
abstract final class UzbekistanAlphabets {
  /// Region code, serial and diplomatic digits.
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  /// Series letters.
  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;

  /// The `D` (diplomat) or `T` (technical staff) a diplomatic plate opens with.
  static const PlateAlphabet diplomaticStatus = PlateAlphabet(
    id: 'uz.diplomaticStatus',
    characters: <String>['D', 'T'],
    input: AlphabetInput.typed,
    isNumeric: false,
  );
}
