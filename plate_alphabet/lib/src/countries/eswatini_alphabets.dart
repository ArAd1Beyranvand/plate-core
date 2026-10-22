import 'package:plate_core/plate_core.dart';

/// The alphabets behind Eswatini slots: the full Latin capitals (the fixed
/// `SD` and the region letter are the validator's concern) and Latin digits.
abstract final class EswatiniAlphabets {
  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;
}
