import 'package:plate_core/plate_core.dart';

/// The alphabets behind Ecuadorian slots.
///
/// Plates use Latin capitals and Latin digits. The article excludes no letter:
/// which letters name a province or a plate type is the validator's concern.
abstract final class EcuadorAlphabets {
  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;
}
