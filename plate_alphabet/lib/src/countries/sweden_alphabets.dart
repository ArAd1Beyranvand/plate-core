import 'package:plate_core/plate_core.dart';

/// The alphabets behind Swedish slots.
///
/// The article: every letter of the Swedish alphabet is used except I, Q, V,
/// Å, Ä and Ö; since 2019 the last character may be a letter, and that
/// position also excludes O so it cannot be read as a zero. Diplomatic codes
/// use neither I, O, Q nor V, and the status letter is one of A–I.
abstract final class SwedenAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const List<String> _letters = <String>[
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'J', 'K', 'L', 'M', //
    'N', 'O', 'P', 'R', 'S', 'T', 'U', 'W', 'X', 'Y', 'Z',
  ];

  static const PlateAlphabet letters = PlateAlphabet(
    id: 'se.letters',
    characters: _letters,
    input: AlphabetInput.typed,
    isNumeric: false,
  );

  /// The last character of a registration: a digit, or (from 2019) a letter
  /// other than O.
  static const PlateAlphabet last = PlateAlphabet(
    id: 'se.last',
    characters: <String>[
      '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', //
      'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'J', 'K', 'L', 'M', 'N', //
      'P', 'R', 'S', 'T', 'U', 'W', 'X', 'Y', 'Z',
    ],
    input: AlphabetInput.typed,
    isNumeric: false,
  );

  /// A diplomatic mission code: two letters, none of I, O, Q, V.
  static const PlateAlphabet missionLetters = PlateAlphabet(
    id: 'se.mission',
    characters: <String>[
      'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'J', 'K', 'L', 'M', //
      'N', 'P', 'R', 'S', 'T', 'U', 'W', 'X', 'Y', 'Z',
    ],
    input: AlphabetInput.typed,
    isNumeric: false,
  );

  /// The diplomatic status letter, ambassador (A) to international
  /// organisation staff (I).
  static const PlateAlphabet status = PlateAlphabet(
    id: 'se.status',
    characters: <String>['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I'],
    input: AlphabetInput.typed,
    isNumeric: false,
  );
}
