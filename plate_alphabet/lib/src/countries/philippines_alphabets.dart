import 'package:plate_core/plate_core.dart';

import '../plate_alphabet.dart';

/// The alphabets behind Philippine slots.
///
/// [letters] is all of A–Z: S as a first letter (government only), the
/// second-letter classes and the region prefixes are series rules, reported by
/// `PhilippinesValidator` rather than barred here.
abstract final class PhilippinesAlphabets {
  static const PlateAlphabet digits = PlateAlphabetDigits.english;

  static const PlateAlphabet letters = PlateAlphabetLatin.typed;

  /// A motorcycle plate cell. The six characters began as `123ABC` and the LTO
  /// has since issued "virtually any six-character alphanumeric combination"
  /// (`N123BC`, `1ABC23`, `A12B34`…), so every cell takes a letter or a digit.
  static const PlateAlphabet alphanumeric = PlateAlphabet(
    id: 'ph.alphanumeric',
    characters: <String>[
      'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', //
      'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', //
      '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
    ],
    input: AlphabetInput.typed,
    isNumeric: false,
  );
}
