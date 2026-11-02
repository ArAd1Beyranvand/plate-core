import 'package:plate_core/plate_core.dart';

/// The alphabets behind Kosovar slots.
///
/// The article says the serial letters run from A to Q, but the pictures print
/// V, T, F, D and others, so [letters] is the full Latin capital set (the
/// picture wins).
abstract final class KosovoAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;
  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;

  /// A government plate's agency code mixes a digit and a letter (`3Z`).
  static const PlateAlphabet mixed = PlateAlphabet.pattern(
    id: 'xk.mixed',
    include: 'A-Z 0-9',
    input: AlphabetInput.typed,
    isNumeric: false,
  );
}
