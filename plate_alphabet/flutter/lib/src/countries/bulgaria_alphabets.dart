import 'package:plate_core/plate_core.dart';

/// The alphabets behind Bulgarian slots.
///
/// Plates print only the twelve Cyrillic letters that also exist in Latin
/// (А В Е К М Н О Р С Т У Х), shown in their Latin forms. The article says
/// the series uses nine of them, `А` the only vowel, so `Е`, `О` and `У` are
/// left out of [series].
abstract final class BulgariaAlphabets {
  /// Province codes (article table): one or two letters from the Cyrillic set
  /// that Latin shapes cover. `EA` and `EM` are validated separately.
  static const List<String> regionCodes = <String>[
    'A', 'B', 'BH', 'BP', 'BT', 'E', 'EB', 'EH', 'K', 'KH', 'M', 'H', 'OB', //
    'P', 'PA', 'PB', 'PK', 'PP', 'C', 'CA', 'CB', 'CH', 'CM', 'CO', 'CC', //
    'CT', 'T', 'TX', 'Y', 'X',
  ];

  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  /// The twelve letters a province code is made of.
  static const PlateAlphabet region = PlateAlphabet.pattern(
    id: 'bg.region',
    include: 'A B E K M H O P C T Y X',
    input: AlphabetInput.typed,
    isNumeric: false,
  );

  /// The nine letters of the series after the digits.
  static const PlateAlphabet series = PlateAlphabet.pattern(
    id: 'bg.series',
    include: 'A B K M H P C T X',
    input: AlphabetInput.typed,
    isNumeric: false,
  );

  /// `EA` (electric car) or `EM` (electric motorcycle).
  static const PlateAlphabet electric = PlateAlphabet(
    id: 'bg.electric',
    characters: <String>['E', 'A', 'M'],
    input: AlphabetInput.typed,
    isNumeric: false,
  );

  /// `BA` on a military plate, `CP` on a civil-protection plate.
  static const PlateAlphabet service = PlateAlphabet.pattern(
    id: 'bg.service',
    include: 'B A C P',
    input: AlphabetInput.typed,
    isNumeric: false,
  );

  /// `XX`, or `XH` since 2019, on a foreigner's plate.
  static const PlateAlphabet foreign = PlateAlphabet(
    id: 'bg.foreign',
    characters: <String>['X', 'H'],
    input: AlphabetInput.typed,
    isNumeric: false,
  );

  /// `C`, `CC` or `CT` on a diplomatic plate.
  static const PlateAlphabet diplomatic = PlateAlphabet(
    id: 'bg.diplomatic',
    characters: <String>['C', 'T'],
    input: AlphabetInput.typed,
    isNumeric: false,
  );
}
