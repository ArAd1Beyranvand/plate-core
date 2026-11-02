import 'package:plate_core/plate_core.dart';

/// The alphabets behind San Marino plates.
///
/// Plates are Latin capitals and ASCII digits: a letter or a short code
/// (`CD`, `CRS`, `POLIZIA`, `VE`) followed by up to four digits.
abstract final class SanMarinoAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;
}
