import 'package:plate_core/plate_core.dart';

/// The alphabets behind Fijian slots.
///
/// The article gives serials such as `AA-001` and `001-A` and names no
/// excluded letter, so [letters] is the full Latin capital set.
abstract final class FijiAlphabets {
  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;
}
