import 'package:plate_core/plate_core.dart';

/// The alphabets behind Latvian slots.
///
/// Plates are ASCII digits and the Latin capitals A–Z; the diacritic letters
/// of Latvian are not printed on any plate in the references.
abstract final class LatviaAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;
}
