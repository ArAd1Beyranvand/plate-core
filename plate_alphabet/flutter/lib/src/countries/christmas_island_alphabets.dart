import 'package:plate_core/plate_core.dart';

/// The alphabets behind Christmas Island slots: Latin capitals for the `CI`
/// register and Western digits for the serial, on every reference.
abstract final class ChristmasIslandAlphabets {
  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;
}
