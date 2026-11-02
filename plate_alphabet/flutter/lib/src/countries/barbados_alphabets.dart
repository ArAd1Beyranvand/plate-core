import 'package:plate_core/plate_core.dart';

/// The alphabets behind Barbadian slots. Plates are Latin capitals and ASCII
/// digits: one or two letters (the parish, or the category) then up to four
/// digits (`L 4159`, `MA 999`).
abstract final class BarbadosAlphabets {
  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;

  static const PlateAlphabet digits = PlateAlphabet.latinDigits;
}
