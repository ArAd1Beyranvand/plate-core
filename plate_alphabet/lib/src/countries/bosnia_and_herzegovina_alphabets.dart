import 'package:plate_core/plate_core.dart';

/// The alphabets behind Bosnian and Herzegovinian slots.
///
/// The article: plates use only the letters written the same in Latin and
/// Cyrillic, `A E J K M O T`. A serial's first character may be one of those
/// letters or a digit (`A12-A-345`, `012-A-345`, agricultural `M80-T-096`).
abstract final class BosniaAndHerzegovinaAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const List<String> _letters = <String>[
    'A',
    'E',
    'J',
    'K',
    'M',
    'O',
    'T',
  ];

  static const PlateAlphabet letters = PlateAlphabet(
    id: 'ba.letters',
    characters: _letters,
    input: AlphabetInput.typed,
    isNumeric: false,
  );

  /// First character of a serial: a digit or one of [letters].
  static const PlateAlphabet first = PlateAlphabet(
    id: 'ba.first',
    characters: <String>[
      'A', 'E', 'J', 'K', 'M', 'O', 'T', //
      '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
    ],
    input: AlphabetInput.typed,
    isNumeric: false,
  );
}
