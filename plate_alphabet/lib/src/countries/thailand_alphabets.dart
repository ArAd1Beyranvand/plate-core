import 'package:plate_core/plate_core.dart';

import '../plate_alphabet.dart';

/// The alphabets behind Thai slots.
///
/// [letters] is the article's table of series letters: thirty-nine Thai
/// consonants, in the table's order. Plates print Western digits. Which
/// letters a given series may use is not stated beyond that table, so
/// `ThailandValidator` reports on length, not on the series itself.
abstract final class ThailandAlphabets {
  static const PlateAlphabet digits = PlateAlphabetDigits.english;

  static const PlateAlphabet letters = PlateAlphabet(
    id: 'th.letters',
    characters: <String>[
      'ก', 'ข', 'ค', 'ง', 'จ', 'ฉ', 'ช', 'ฌ', 'ฏ', 'ฐ', 'ณ', 'ด', 'ต', //
      'ถ', 'ท', 'ธ', 'น', 'บ', 'ป', 'ผ', 'พ', 'ฟ', 'ภ', 'ม', 'ย', 'ร', //
      'ล', 'ว', 'ศ', 'ษ', 'ส', 'ห', 'ฬ', 'อ', 'ฮ', 'ญ', 'ฒ', 'ฆ', 'ซ',
    ],
    input: AlphabetInput.chosen,
    isNumeric: false,
  );
}
