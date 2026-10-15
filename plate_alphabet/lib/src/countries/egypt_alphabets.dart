import 'package:flutter/widgets.dart';
import 'package:plate_core/plate_core.dart';

import '../plate_alphabet.dart';

/// The alphabets an Egyptian plate slot is drawn over.
///
/// Each letter is stored once, as the Latin letter the government pairs with
/// it, and printed as the Arabic one: typing or choosing `S` prints `س`. The
/// article lists exactly these seventeen, picked to be hard to confuse with
/// each other. Digits are printed as Eastern Arabic numerals.
abstract final class EgyptAlphabets {
  static const PlateAlphabet digits = PlateAlphabetDigits.iranshahr;

  static const PlateAlphabet letters = PlateAlphabet(
    id: 'eg.letters',
    characters: <String>[
      'A', 'B', 'G', 'D', 'R', 'S', 'C', 'T', 'E', //
      'F', 'K', 'L', 'M', 'N', 'H', 'W', 'Y',
    ],
    input: AlphabetInput.chosen,
    isNumeric: false,
    direction: TextDirection.rtl,
    placeholder: '؟',
    glyphs: <String, String>{
      'A': 'أ',
      'B': 'ب',
      'G': 'ج',
      'D': 'د',
      'R': 'ر',
      'S': 'س',
      'C': 'ص',
      'T': 'ط',
      'E': 'ع',
      'F': 'ف',
      'K': 'ق',
      'L': 'ل',
      'M': 'م',
      'N': 'ن',
      'H': 'هـ',
      'W': 'و',
      'Y': 'ى',
    },
  );
}
