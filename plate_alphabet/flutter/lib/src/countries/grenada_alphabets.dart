import 'package:plate_core/plate_core.dart';

/// The alphabets behind Grenadian slots.
///
/// The article excludes no letter; the plates use Latin letters and digits.
abstract final class GrenadaAlphabets {
  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;
}
