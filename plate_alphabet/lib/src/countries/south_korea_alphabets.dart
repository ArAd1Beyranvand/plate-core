import 'package:plate_core/plate_core.dart';

import '../plate_alphabet.dart';

/// The alphabets behind South Korean slots. Plates print Western digits; the
/// one Hangul syllable after the class digits is picked, never typed, so each
/// list below is a picker.
///
/// Which syllable goes with which vehicle is a rule for `SouthKoreaValidator`,
/// which reports rather than bars.
abstract final class SouthKoreaAlphabets {
  static const PlateAlphabet digits = PlateAlphabetDigits.english;

  /// Private cars: the twenty-eight syllables of the article's passenger list,
  /// then the rental-car syllables 하 허 호.
  static const PlateAlphabet privateLetters = PlateAlphabet.pattern(
    id: 'kr.letter.private',
    include:
        '가 나 다 라 마 거 너 더 러 머 버 서 어 저 고 노 도 로 모 보 소 오 조 구 누 두 루 무 부 수 우 주 하 허 호',
    input: AlphabetInput.chosen,
    isNumeric: false,
  );

  /// Commercial (yellow) plates: 아 바 사 자, and 배 for delivery vehicles.
  static const PlateAlphabet commercialLetters = PlateAlphabet.pattern(
    id: 'kr.letter.commercial',
    include: '아 바 사 자 배',
    input: AlphabetInput.chosen,
    isNumeric: false,
  );

  /// The military branch symbols of the article: Ministry of Defense, Joint
  /// Staff, Army, Navy/Marines, Air Force.
  static const PlateAlphabet militaryBranch = PlateAlphabet.pattern(
    id: 'kr.letter.military',
    include: '국 합 육 해 공',
    input: AlphabetInput.chosen,
    isNumeric: false,
  );

  /// The provinces and cities printed on commercial plates, in full minus the
  /// -do/-si suffix, in the article's list order.
  static const PlateAlphabet regions = PlateAlphabet.pattern(
    id: 'kr.region',
    include: '강원 경기 경남 경북 광주 대구 대전 부산 서울 세종 울산 인천 전남 전북 제주 충남 충북',
    input: AlphabetInput.chosen,
    isNumeric: false,
  );
}
