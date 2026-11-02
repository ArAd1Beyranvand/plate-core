import 'package:plate_core/plate_core.dart';

/// The alphabets behind Saint Kitts and Nevis slots. Plates are Latin capitals
/// and ASCII digits: the `P` prefix (`P(A)` since 1997) then up to four digits.
abstract final class SaintKittsAndNevisAlphabets {
  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;

  static const PlateAlphabet digits = PlateAlphabet.latinDigits;
}
