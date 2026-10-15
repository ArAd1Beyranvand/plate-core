import 'package:flutter/widgets.dart';
import 'package:plate_core/plate_core.dart';

import '../plate_alphabet.dart';

/// A Djiboutian plate prints its number twice: Latin on the left, and the same
/// value mirrored in Arabic on the right (`683D30` against `٣٠ج٦٨٣`). Each
/// value is stored once, in Latin, and the right half reads it through
/// [arabicDigits] and [letterArabic].
abstract final class DjiboutiAlphabets {
  static const PlateAlphabet digits = PlateAlphabetDigits.english;
  static const PlateAlphabet arabicDigits = PlateAlphabetDigits.iranshahr;

  /// The middle letter. Only `D` (ج) is on the reference plate; the article
  /// gives no list of others.
  static const PlateAlphabet letter = PlateAlphabet(
    id: 'dj.letter.latin',
    characters: <String>['D'],
    input: AlphabetInput.chosen,
    isNumeric: false,
  );

  static const PlateAlphabet letterArabic = PlateAlphabet(
    id: 'dj.letter.arabic',
    characters: <String>['D'],
    input: AlphabetInput.chosen,
    isNumeric: false,
    direction: TextDirection.rtl,
    placeholder: '؟',
    glyphs: <String, String>{'D': 'ج'},
  );
}
