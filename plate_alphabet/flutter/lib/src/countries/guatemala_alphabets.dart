import 'package:plate_core/plate_core.dart';

/// The alphabets behind Guatemalan slots: a plate is a class letter (`P`
/// private, `C` commercial, ...), three digits and three letters, all Latin.
abstract final class GuatemalaAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;
}
