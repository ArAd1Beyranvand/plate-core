import 'package:flutter/widgets.dart';
import 'package:plate_core/plate_core.dart';

/// Digit alphabets shared by all plate packages. Each stores ASCII `0-9` and
/// differs only in rendering, so country packages reference these instead of
/// restating the ten glyphs.
abstract final class PlateAlphabetDigits {
  /// ASCII `0-9`, rendered as itself.
  static const PlateAlphabet english = PlateAlphabet.latinDigits;

  /// ASCII `0-9` rendered as Persian numerals `۰..۹`.
  static const PlateAlphabet iranian = PlateAlphabet.pattern(
    id: 'alphabet.fa.digits',
    include: '0-9',
    input: AlphabetInput.typed,
    isNumeric: true,
    glyphs: <String, String>{
      '0': '۰',
      '1': '۱',
      '2': '۲',
      '3': '۳',
      '4': '۴',
      '5': '۵',
      '6': '۶',
      '7': '۷',
      '8': '۸',
      '9': '۹',
    },
  );

  /// ASCII `0-9` rendered as Iranshahr numerals `٠..٩`, distinct from the
  /// Persian variants above (`٤` vs `۴`).
  static const PlateAlphabet iranshahr = PlateAlphabet.pattern(
    id: 'alphabet.iranshahr.digits',
    include: '0-9',
    input: AlphabetInput.typed,
    isNumeric: true,
    glyphs: <String, String>{
      '0': '٠',
      '1': '١',
      '2': '٢',
      '3': '٣',
      '4': '٤',
      '5': '٥',
      '6': '٦',
      '7': '٧',
      '8': '٨',
      '9': '٩',
    },
  );
}

/// Full letter sets that country packages subset.
abstract final class PlateAlphabetLetters {
  /// Every Persian and Arabic-script letter used on plates.
  static const PlateAlphabet persianAll = PlateAlphabet.pattern(
    id: 'alphabet.fa.all',
    include:
        'ا ب پ ت ث ج چ ح خ د ذ ر ز ژ س ش ص ض ط ظ ع غ ف ق ک گ ل م ن و ه ة ی',
    input: AlphabetInput.chosen,
    isNumeric: false,
    direction: TextDirection.rtl,
    placeholder: '؟',
  );

  /// Every Latin uppercase letter used on plates, plus `Ä Ö Ü` and the `MP`
  /// digraph.
  static const PlateAlphabet latinAll = PlateAlphabet.pattern(
    id: 'alphabet.latin.all',
    include: 'A-Z Ä Ö Ü MP',
    input: AlphabetInput.chosen,
    isNumeric: false,
    placeholder: '?',
  );
}

/// A–Z typed from the keyboard; [PlateAlphabetLetters.latinAll] is the picker
/// variant.
abstract final class PlateAlphabetLatin {
  static const PlateAlphabet typed = PlateAlphabet.pattern(
    id: 'alphabet.latin.typed',
    include: 'A-Z',
    input: AlphabetInput.typed,
    isNumeric: false,
  );
}

/// Belarus: Latin letters that share a shape with a Cyrillic one, and the
/// fixed-letter slots.
abstract final class PlateAlphabetBelarus {
  static const PlateAlphabet letters = PlateAlphabet.pattern(
    id: 'by.letters',
    include: 'A B E I K M H O P C T X',
    input: AlphabetInput.typed,
    isNumeric: false,
  );

  /// Region digit: 1–7 regions and Minsk, 8 overflow series, 0 Ministry of
  /// Defence.
  static const PlateAlphabet region = PlateAlphabet.pattern(
    id: 'by.region',
    include: '0-8',
    input: AlphabetInput.typed,
    isNumeric: true,
  );

  /// The leading `E` of an electric vehicle's number.
  static const PlateAlphabet electric = PlateAlphabet(
    id: 'by.electric',
    characters: <String>['E'],
    input: AlphabetInput.typed,
    isNumeric: false,
  );

  /// First letter of a diplomatic plate: always `C`.
  static const PlateAlphabet diplomaticFirst = PlateAlphabet(
    id: 'by.diplomatic.first',
    characters: <String>['C'],
    input: AlphabetInput.typed,
    isNumeric: false,
  );

  /// Second letter: `D` for diplomatic corps, `C` for consular.
  static const PlateAlphabet diplomaticSecond = PlateAlphabet(
    id: 'by.diplomatic.second',
    characters: <String>['C', 'D'],
    input: AlphabetInput.typed,
    isNumeric: false,
  );
}

/// North Korea: the two-syllable Hangul region code. The thirteen controlled
/// regions, then the seven South Korean provinces still coded; 링김 is an
/// observed 1990s code absent from any list.
abstract final class PlateAlphabetKorea {
  static const PlateAlphabet northRegions = PlateAlphabet.pattern(
    id: 'kp.region',
    include: '평양 라선 평남 평북 자강 황남 황북 강원 함남 함북 량강 남포 개성 충남 충북 경기 경남 경북 전남 전북 링김',
    input: AlphabetInput.chosen,
    isNumeric: false,
  );
}

/// Namibia: the letters the town codes use, and the personalised plates'
/// letters-and-digits set.
abstract final class PlateAlphabetNamibia {
  /// Every letter in a town code (`W`, `WB`, `KM`, …). Advisory: the validator
  /// checks the code.
  static const PlateAlphabet region = PlateAlphabet.pattern(
    id: 'na.region',
    include: 'A-W',
    exclude: 'F I Q',
    input: AlphabetInput.typed,
    isNumeric: false,
  );

  /// A personalised plate's characters: up to seven letters or digits.
  static const PlateAlphabet personalised = PlateAlphabet.pattern(
    id: 'na.personalised',
    include: 'A-Z 0-9',
    input: AlphabetInput.typed,
    isNumeric: false,
  );
}
