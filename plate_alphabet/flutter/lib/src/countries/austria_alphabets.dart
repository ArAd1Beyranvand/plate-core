import 'package:plate_core/plate_core.dart';

/// The alphabets behind Austrian slots.
///
/// District and serial letters are the plain Latin capitals; the plates carry
/// no diacritics. A personalised combination takes letters and digits.
abstract final class AustriaAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const PlateAlphabet letters = PlateAlphabet.pattern(
    id: 'at.letters',
    include: 'A-Z',
    input: AlphabetInput.typed,
    isNumeric: false,
  );

  static const PlateAlphabet personalised = PlateAlphabet.pattern(
    id: 'at.personalised',
    include: 'A-Z 0-9',
    input: AlphabetInput.typed,
    isNumeric: false,
  );
}
