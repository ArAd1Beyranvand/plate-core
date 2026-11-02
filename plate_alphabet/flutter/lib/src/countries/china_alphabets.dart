import 'package:plate_core/plate_core.dart';

import '../plate_alphabet.dart';

/// The alphabets behind Chinese slots. Plates print Western digits and Latin
/// capitals; the province character and the diplomatic status mark are
/// Hanzi, picked rather than typed.
///
/// Rules about which letter goes where (at most two letters in a serial, the
/// energy-type letter on a New Energy plate) belong to `ChinaValidator`, which
/// reports rather than bars.
abstract final class ChinaAlphabets {
  static const PlateAlphabet digits = PlateAlphabetDigits.english;

  /// The thirty-one one-character province-level abbreviations, in the
  /// article's table order with Tibet (藏) added: Table 2 lists it, the
  /// prefix section's regular expression missed it.
  static const PlateAlphabet provinces = PlateAlphabet.pattern(
    id: 'cn.province',
    include: '京 津 沪 渝 冀 豫 云 辽 黑 湘 皖 鲁 新 苏 浙 赣 鄂 桂 甘 晋 蒙 陕 吉 闽 贵 粤 青 藏 川 宁 琼',
    input: AlphabetInput.chosen,
    isNumeric: false,
    placeholder: '京',
  );

  /// The issuing-city letter after the province: A–Z without I and O, which
  /// the 2007 standard drops because they read as 1 and 0.
  static const PlateAlphabet cityLetters = PlateAlphabet.pattern(
    id: 'cn.letter',
    include: 'A-Z',
    exclude: 'I O',
    input: AlphabetInput.typed,
    isNumeric: false,
  );

  /// A serial character: a digit, a letter but I and O, or one of the Hanzi
  /// that may close it — 学 driving-school, 警 police, 挂 trailer, 港 Hong
  /// Kong, 澳 Macau, 试 test, 超 prototype. The suffix is only legal in the
  /// last place; `ChinaValidator` says so.
  static const PlateAlphabet serial = PlateAlphabet.pattern(
    id: 'cn.serial',
    include: '0-9 A-Z 学 警 挂 港 澳 试 超',
    exclude: 'I O',
    input: AlphabetInput.typed,
    isNumeric: false,
  );

  /// The status character of a diplomatic plate: 使 embassy, 领 consulate.
  static const PlateAlphabet diplomaticMark = PlateAlphabet(
    id: 'cn.mark',
    characters: <String>['使', '领'],
    input: AlphabetInput.chosen,
    isNumeric: false,
    placeholder: '使',
  );
}
