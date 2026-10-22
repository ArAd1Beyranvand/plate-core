import 'package:plate_core/plate_core.dart';

/// The alphabets behind Tongan slots.
///
/// The article names the vehicle-type letters (B, C, G, H, J, L, MC, P, R, T,
/// V) and gives no excluded letter, so [letters] is the full Latin capital
/// set. The numbers are one to five Latin digits.
abstract final class TongaAlphabets {
  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;
}
