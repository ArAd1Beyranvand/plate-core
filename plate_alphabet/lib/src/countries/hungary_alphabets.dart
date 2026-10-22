import 'package:plate_core/plate_core.dart';

/// The alphabets behind Hungarian slots.
///
/// Every typed field is ASCII: serial letters are the Latin capitals (the
/// article gives no exclusions, and `W` and `I` both appear on the sample
/// photos) and the numerals are Latin digits. The `H` beside the flag and the
/// dashes are printed, not typed.
abstract final class HungaryAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;
  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;
}
