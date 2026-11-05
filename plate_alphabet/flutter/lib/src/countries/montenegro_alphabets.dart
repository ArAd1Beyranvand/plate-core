import 'package:plate_core/plate_core.dart';

/// The alphabets behind Montenegrin slots.
///
/// Municipal codes are two Latin capitals, with `Š` and `Ž` for `ŠN`, `PŽ` and
/// `ŽB`. Serial letters omit `I` and `O` (too like `1` and `0`); the article
/// allows them on paid custom plates, which the plates in the pictures do not
/// show. Diplomatic plates carry one series letter: `A`, `M`, `P`, `E` or `C`.
abstract final class MontenegroAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const List<String> _latin = <String>[
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', //
    'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
  ];

  static const PlateAlphabet municipality = PlateAlphabet(
    id: 'me.municipality',
    characters: <String>[..._latin, 'Š', 'Ž'],
  );

  static const PlateAlphabet letters = PlateAlphabet.pattern(
    id: 'me.letters',
    include: 'A-Z',
    exclude: 'I O',
  );

  static const PlateAlphabet diplomaticLetters = PlateAlphabet.pattern(
    id: 'me.diplomatic.letters',
    include: 'A C E M P',
  );

  /// The moped plate's four-character serial mixes letters and digits.
  static const PlateAlphabet mixed = PlateAlphabet.pattern(
    id: 'me.mixed',
    include: 'A-Z 0-9',
    exclude: 'I O',
  );
}
