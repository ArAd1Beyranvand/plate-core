import 'package:flutter/widgets.dart';
import 'package:plate_core/plate_core.dart';

import '../plate_alphabet.dart';

/// The alphabets a Moroccan plate slot is drawn over.
///
/// The series letter is stored as the Latin equivalent the article pairs with
/// it and printed as the Arabic one: choosing `T` prints `ط`. These seven are
/// the letters allocated to ordinary registrations so far; the rest of the
/// abjad is reserved for police, civil defence and the like.
abstract final class MoroccoAlphabets {
  static const PlateAlphabet digits = PlateAlphabetDigits.english;

  static const PlateAlphabet series = PlateAlphabet.pattern(
    id: 'ma.series',
    include: 'A B D H E T Y',
    input: AlphabetInput.chosen,
    isNumeric: false,
    direction: TextDirection.rtl,
    placeholder: '؟',
    glyphs: <String, String>{
      'A': 'أ',
      'B': 'ب',
      'D': 'د',
      'H': 'ه',
      'E': 'و',
      'T': 'ط',
      'Y': 'ي',
    },
  );
}
