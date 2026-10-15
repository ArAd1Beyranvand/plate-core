import 'package:plate_core/plate_core.dart';

/// The alphabets behind Bhutanese slots.
///
/// The article gives the format XX-N-X0000: N is the area code 1 to 5 and the
/// letters are A–Z with no excluded letter. The plates print Western digits.
abstract final class BhutanAlphabets {
  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  /// The area code, 1 to 5.
  static const PlateAlphabet area = PlateAlphabet(
    id: 'alphabet.bt.area',
    characters: <String>['1', '2', '3', '4', '5'],
    input: AlphabetInput.typed,
    isNumeric: true,
  );
}
