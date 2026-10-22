import 'package:plate_core/plate_core.dart';

/// The alphabets behind Haitian slots. The references show Latin capitals and
/// Latin digits only; no letter is excluded.
abstract final class HaitiAlphabets {
  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;
}
