import 'package:plate_core/plate_core.dart';

/// The alphabets behind Swedish slots.
///
/// The article: every letter of the Swedish alphabet is used except I, Q, V,
/// Å, Ä and Ö; since 2019 the last character may be a letter, and that
/// position also excludes O so it cannot be read as a zero. Diplomatic codes
/// use neither I, O, Q nor V, and the status letter is one of A–I.
abstract final class SwedenAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const PlateAlphabet letters = PlateAlphabet.pattern(
    id: 'se.letters',
    include: 'A-Z',
    exclude: 'I Q V',
    input: AlphabetInput.typed,
    isNumeric: false,
  );

  /// The last character of a registration: a digit, or (from 2019) a letter
  /// other than O.
  static const PlateAlphabet last = PlateAlphabet.pattern(
    id: 'se.last',
    include: '0-9 A-Z',
    exclude: 'I O Q V',
    input: AlphabetInput.typed,
    isNumeric: false,
  );

  /// A diplomatic mission code: two letters, none of I, O, Q, V.
  static const PlateAlphabet missionLetters = PlateAlphabet.pattern(
    id: 'se.mission',
    include: 'A-Z',
    exclude: 'I O Q V',
    input: AlphabetInput.typed,
    isNumeric: false,
  );

  /// The diplomatic status letter, ambassador (A) to international
  /// organisation staff (I).
  static const PlateAlphabet status = PlateAlphabet.pattern(
    id: 'se.status',
    include: 'A-I',
    input: AlphabetInput.typed,
    isNumeric: false,
  );
}
