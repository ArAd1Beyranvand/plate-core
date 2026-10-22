import 'package:plate_core/plate_core.dart';

/// The alphabets behind Romanian slots.
///
/// Plates are Latin capitals and ASCII digits. [letters] leaves out Q, which
/// the article says is never issued; the rule that a serial group may not
/// begin with I or O is the validator's.
abstract final class RomaniaAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const PlateAlphabet letters = PlateAlphabet.pattern(
    id: 'ro.letters',
    include: 'A-Z',
    exclude: 'Q',
    input: AlphabetInput.typed,
    isNumeric: false,
  );

  /// A municipality's name on a local-administration plate: capitals with the
  /// Romanian diacritics, a space and a hyphen.
  static const PlateAlphabet placeName = PlateAlphabet(
    id: 'ro.placeName',
    characters: <String>[
      'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', //
      'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
      'Ă', 'Â', 'Î', 'Ș', 'Ț', ' ', '-',
    ],
    input: AlphabetInput.typed,
    isNumeric: false,
  );
}
