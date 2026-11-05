import 'package:plate_core/plate_core.dart';

import '../plate_alphabet.dart';

/// The alphabets behind Somaliland's slots.
///
/// The article gives no excluded letter, so [letters] is the full Latin set.
abstract final class SomalilandAlphabets {
  /// Administrative division codes (article table): Awdal, Maroodi Jeex, Sool,
  /// Sanaag, Sahil, Togdheer.
  static const List<String> regionCodes = <String>[
    'AW', 'MJ', 'SL', 'SN', 'SX', 'TG', //
  ];

  static const PlateAlphabet letters = PlateAlphabetLatin.typed;
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  /// The 2005 plate prints the number a second time in Arabic numerals.
  static const PlateAlphabet iranshahrDigits = PlateAlphabetDigits.iranshahr;

  /// A class letter and four digits as one run (`C1234`).
  static const PlateAlphabet serial = PlateAlphabet.pattern(
    id: 'xs.serial',
    include: 'A-Z 0-9',
  );

  static const PlateAlphabet region = PlateAlphabet(
    id: 'xs.region',
    characters: regionCodes,
    input: AlphabetInput.chosen,
    placeholder: '??',
  );
}
