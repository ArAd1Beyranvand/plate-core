import 'package:plate_core/plate_core.dart';

/// The alphabets behind Tanzanian slots. The article restricts no letter, so
/// [letters] is the whole Latin capital alphabet.
abstract final class TanzaniaAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const PlateAlphabet letters = PlateAlphabet.pattern(
    id: 'tz.letters',
    include: 'A-Z',
    input: AlphabetInput.typed,
    isNumeric: false,
  );
}
