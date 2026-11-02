import 'package:plate_core/plate_core.dart';

/// The alphabets behind Ukrainian slots.
///
/// Regular plates use only the twelve Cyrillic letters that look like Latin
/// ones (А В Е І К М Н О Р С Т Х), so that a plate reads the same abroad
/// under the Vienna Convention. They are stored as their Latin twins — the
/// glyph printed is identical — which also keeps the keyboard simple.
abstract final class UkraineAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  /// The twelve lookalike letters of regional and serial fields.
  static const PlateAlphabet letters = PlateAlphabet.pattern(
    id: 'ua.letters',
    include: 'A-C E H I K M O P T X',
    input: AlphabetInput.typed,
    isNumeric: false,
  );

  /// Temporary and military fields mix those letters with digits (`T1`,
  /// `02`, `AA4215`, `E6`).
  static const PlateAlphabet mixed = PlateAlphabet.pattern(
    id: 'ua.mixed',
    include: 'A-C E H I K M O P T X 0-9',
    input: AlphabetInput.typed,
    isNumeric: false,
  );

  /// An individualised plate takes Cyrillic or Latin letters, and digits.
  static const PlateAlphabet personalised = PlateAlphabet.pattern(
    id: 'ua.personalised',
    include:
        'A-Z А Б В Г Ґ Д Е Є Ж З И І Ї Й К Л М Н О П Р С Т У Ф Х Ц Ч Ш Щ Ь Ю Я 0-9',
    input: AlphabetInput.typed,
    isNumeric: false,
  );
}
