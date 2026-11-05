import 'package:plate_core/plate_core.dart';

/// The alphabets behind Ugandan slots. The article restricts no letter, so
/// [letters] is the whole Latin capital alphabet.
abstract final class UgandaAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const PlateAlphabet letters = PlateAlphabet.pattern(
    id: 'ug.letters',
    include: 'A-Z',
  );
}
