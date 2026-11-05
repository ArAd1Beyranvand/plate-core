import 'package:plate_core/plate_core.dart';

/// The alphabets behind Croatian slots.
///
/// Region codes are the 34 the article tabulates; four of them carry the
/// Croatian letters `Č`, `Š` and `Ž`, which appear only there. The serial
/// letters are the Latin capitals without Q, W, X and Y, which the article says
/// are not issued because they are not in the Croatian alphabet. A customized
/// plate's word is free, so it takes the whole Latin alphabet and digits.
abstract final class CroatiaAlphabets {
  static const List<String> regionCodes = <String>[
    'BJ', 'BM', 'ČK', 'DA', 'DE', 'DJ', 'DU', 'GS', 'IM', 'KA', 'KC', 'KR', //
    'KT', 'KŽ', 'MA', 'NA', 'NG', 'OG', 'OS', 'PU', 'PŽ', 'RI', 'SB', 'SK', //
    'SL', 'ST', 'ŠI', 'VK', 'VT', 'VU', 'VŽ', 'ZD', 'ZG', 'ŽU',
  ];

  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  /// The letters region codes are made of.
  static const PlateAlphabet regionLetters = PlateAlphabet.pattern(
    id: 'hr.region.letters',
    include: 'A-C Č D-S Š T-V Z Ž',
    exclude: 'F H Q',
  );

  static const PlateAlphabet letters = PlateAlphabet.pattern(
    id: 'hr.letters',
    include: 'A-Z',
    exclude: 'Q W X Y',
  );

  /// A customized plate's chosen word: any Latin capital or digit.
  static const PlateAlphabet custom = PlateAlphabet.pattern(
    id: 'hr.custom',
    include: 'A-Z 0-9',
  );
}
