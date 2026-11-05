import 'package:plate_core/plate_core.dart';

/// The alphabets behind British slots.
///
/// Plates are Latin capitals and ASCII digits. Which letters the DVLA issues
/// (no `I`, `Q` or `Z` in an area code) is the validator's business, so the
/// letter fields accept the whole alphabet.
abstract final class UnitedKingdomAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;

  /// The `D` (diplomatic staff) or `X` (non-diplomatic staff) in the middle of
  /// a diplomatic mark.
  static const PlateAlphabet diplomaticClass = PlateAlphabet(
    id: 'gb.diplomaticClass',
    characters: <String>['D', 'X'],
  );
}
