import 'package:flutter/widgets.dart';
import 'package:plate_core/plate_core.dart';

import '../plate_alphabet.dart';

/// The alphabets behind a Riyadh slot.
///
/// A value is stored once, in Latin, and the plate prints it twice: the large
/// row through the glyph maps here, the small row as it is. So `T N J` prints
/// `ط ن ح` above and `TNJ` below.
///
/// The seventeen letters are the ones the article lists, each paired with the
/// Latin letter it is mapped to. The article names no other letter, so no other
/// is accepted.
abstract final class RiyadhAlphabets {
  static const PlateAlphabet digits = PlateAlphabetDigits.english;

  /// `0-9` printed as Iranshahr numerals, for the large row.
  static const PlateAlphabet iranshahrDigits = PlateAlphabetDigits.iranshahr;

  /// The Latin row of the letters.
  static const PlateAlphabet lettersLatin = PlateAlphabet.pattern(
    id: 'ye.riyadh.letters.latin',
    include: 'A B J D R S X T E G K L Z N H U V',
    input: AlphabetInput.typed,
    isNumeric: false,
  );

  /// The Arabic row of the letters.
  static const PlateAlphabet lettersArabic = PlateAlphabet.pattern(
    id: 'ye.riyadh.letters.arabic',
    include: 'A B J D R S X T E G K L Z N H U V',
    input: AlphabetInput.chosen,
    isNumeric: false,
    direction: TextDirection.rtl,
    placeholder: '؟',
    glyphs: <String, String>{
      'A': 'ا',
      'B': 'ب',
      'J': 'ح',
      'D': 'د',
      'R': 'ر',
      'S': 'س',
      'X': 'ص',
      'T': 'ط',
      'E': 'ع',
      'G': 'ق',
      'K': 'ك',
      'L': 'ل',
      'Z': 'م',
      'N': 'ن',
      'H': 'هـ',
      'U': 'و',
      'V': 'ى',
    },
  );
}
