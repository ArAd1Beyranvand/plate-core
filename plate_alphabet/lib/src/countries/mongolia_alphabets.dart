import 'package:plate_core/plate_core.dart';

/// The alphabets behind Mongolian slots.
///
/// The serial is three Cyrillic letters. The first two are the aimag suffix
/// the article tabulates ([suffixes]); the third is a free letter. The article
/// states no restriction on that third letter, so [letters] is the Mongolian
/// Cyrillic alphabet. Where the article's table carries a Latin look-alike
/// (`БH`, `БP`, `OP`), the Cyrillic letter is stored.
abstract final class MongoliaAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const List<String> suffixes = <String>[
    'АР', 'БН', 'БР', 'БӨ', 'БУ', 'ГА', 'ГС', 'ДА', 'ДГ', 'ДО', 'ДУ', 'ОР', //
    'ХЭ', 'ХО', 'ХӨ', 'НА', 'ӨМ', 'ӨВ', 'СЭ', 'СҮ', 'СБ', 'ТӨ', 'УБ', 'УН', //
    'УА', 'УЕ', 'УК', 'УВ', 'ЗА',
  ];

  static const PlateAlphabet letters = PlateAlphabet(
    id: 'mn.letters',
    characters: <String>[
      'А', 'Б', 'В', 'Г', 'Д', 'Е', 'Ё', 'Ж', 'З', 'И', 'Й', 'К', 'Л', 'М', //
      'Н', 'О', 'Ө', 'П', 'Р', 'С', 'Т', 'У', 'Ү', 'Ф', 'Х', 'Ц', 'Ч', 'Ш', //
      'Щ', 'Ъ', 'Ы', 'Ь', 'Э', 'Ю', 'Я',
    ],
    input: AlphabetInput.typed,
    isNumeric: false,
  );
}
