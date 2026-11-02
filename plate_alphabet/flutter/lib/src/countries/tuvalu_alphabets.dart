import 'package:plate_core/plate_core.dart';

/// The alphabets behind Tuvaluan slots.
///
/// The article gives `AB1234` and names no excluded letter, so [letters] is
/// the full Latin capital set.
abstract final class TuvaluAlphabets {
  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;
}
