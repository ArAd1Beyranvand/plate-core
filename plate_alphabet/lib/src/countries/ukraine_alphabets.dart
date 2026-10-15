import 'package:plate_core/plate_core.dart';

/// The alphabets behind Ukrainian slots.
///
/// Regular plates use only the twelve Cyrillic letters that look like Latin
/// ones (А В Е І К М Н О Р С Т Х), so that a plate reads the same abroad
/// under the Vienna Convention. They are stored as their Latin twins — the
/// glyph printed is identical — which also keeps the keyboard simple.
abstract final class UkraineAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const List<String> _lookalikes = <String>[
    'A', 'B', 'C', 'E', 'H', 'I', 'K', 'M', 'O', 'P', 'T', 'X', //
  ];

  /// The twelve lookalike letters of regional and serial fields.
  static const PlateAlphabet letters = PlateAlphabet(
    id: 'ua.letters',
    characters: _lookalikes,
    input: AlphabetInput.typed,
    isNumeric: false,
  );

  /// Temporary and military fields mix those letters with digits (`T1`,
  /// `02`, `AA4215`, `E6`).
  static const PlateAlphabet mixed = PlateAlphabet(
    id: 'ua.mixed',
    characters: <String>[
      ..._lookalikes,
      '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', //
    ],
    input: AlphabetInput.typed,
    isNumeric: false,
  );

  /// An individualised plate takes Cyrillic or Latin letters, and digits.
  static const PlateAlphabet personalised = PlateAlphabet(
    id: 'ua.personalised',
    characters: <String>[
      'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', //
      'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
      'А', 'Б', 'В', 'Г', 'Ґ', 'Д', 'Е', 'Є', 'Ж', 'З', 'И', 'І', 'Ї', 'Й', //
      'К', 'Л', 'М', 'Н', 'О', 'П', 'Р', 'С', 'Т', 'У', 'Ф', 'Х', 'Ц', 'Ч',
      'Ш', 'Щ', 'Ь', 'Ю', 'Я',
      '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
    ],
    input: AlphabetInput.typed,
    isNumeric: false,
  );
}
