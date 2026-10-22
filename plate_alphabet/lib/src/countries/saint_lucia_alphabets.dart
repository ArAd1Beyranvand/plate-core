import 'package:plate_core/plate_core.dart';

/// The alphabets behind Saint Lucian slots. Plates are Latin capitals and
/// ASCII digits: a letter prefix (`P`, `PA`, `TX`, `M`, `DM`, `SLG`, `MP`)
/// then up to four digits.
abstract final class SaintLuciaAlphabets {
  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;

  static const PlateAlphabet digits = PlateAlphabet.latinDigits;
}
