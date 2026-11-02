import 'package:plate_core/plate_core.dart';

/// The alphabets behind Bermudian slots.
///
/// The article names no excluded letter for the class prefixes (`CL`, `IN`,
/// `HA`, `RMC`) or the cycle suffix, so [letters] is the full Latin capital set.
abstract final class BermudaAlphabets {
  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;
}
