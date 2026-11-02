import 'package:plate_core/plate_core.dart';

/// The alphabets behind Easter Island slots: the `ABC 123` plates are
/// Chilean, three Latin capitals and three digits.
abstract final class EasterIslandAlphabets {
  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;
}
