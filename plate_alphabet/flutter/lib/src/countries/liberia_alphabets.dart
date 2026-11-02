import 'package:plate_core/plate_core.dart';

/// The alphabets behind Liberian slots: a diplomatic plate prints digits, then
/// the letters `CD` or `CMD`, then digits.
abstract final class LiberiaAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;
  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;
}
