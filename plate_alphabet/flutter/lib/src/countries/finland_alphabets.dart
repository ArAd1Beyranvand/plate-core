import 'package:plate_core/plate_core.dart';

/// The alphabets behind Finnish slots.
///
/// Regular plates use A–Z and the national letters Å, Ä, Ö (article, "Codes").
/// Diplomatic plates carry `C` or `CD` (Corps Diplomatique) before the number.
abstract final class FinlandAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const PlateAlphabet letters = PlateAlphabet.pattern(
    id: 'fi.letters',
    include: 'A-Z Å Ä Ö',
    input: AlphabetInput.typed,
    isNumeric: false,
  );

  static const PlateAlphabet diplomaticLetters = PlateAlphabet(
    id: 'fi.diplomatic.letters',
    characters: <String>['C', 'D'],
    input: AlphabetInput.typed,
    isNumeric: false,
  );
}
