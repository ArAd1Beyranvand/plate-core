import 'package:plate_core/plate_core.dart';

/// The alphabets behind Paraguayan slots: the Mercosur plate prints four
/// Latin capitals and three digits.
abstract final class ParaguayAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;
}
