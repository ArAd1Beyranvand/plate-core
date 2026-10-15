import 'package:plate_core/plate_core.dart';

/// The alphabets behind Japanese slots.
///
/// Plates print Western digits. The office name (kanji, up to four characters)
/// and the hiragana are picked, never typed, so each is a picker whose symbols
/// may be several characters long — an office is one symbol, `品川`.
///
/// Which hiragana goes with which plate colour is the article's own table;
/// `JapanValidator` reports a mismatch rather than barring it.
abstract final class JapanAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;

  /// The vehicle class code: two or three characters, a digit then a digit or,
  /// in the third place, a letter (the article's `50K`).
  static const PlateAlphabet classCode = PlateAlphabet(
    id: 'jp.class',
    characters: <String>[
      '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', //
      'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', //
      'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
    ],
    input: AlphabetInput.typed,
    isNumeric: false,
  );

  /// The first pair of the serial: digits, with the centred dot `・` that
  /// stands for a leading zero.
  static const PlateAlphabet serialHead = PlateAlphabet(
    id: 'jp.serial.head',
    characters: <String>[
      '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '・', //
    ],
    input: AlphabetInput.typed,
    isNumeric: false,
  );

  /// The hiragana of a white plate; `れ` and `わ` mark rental vehicles.
  static const PlateAlphabet kanaWhite = PlateAlphabet(
    id: 'jp.kana.white',
    characters: <String>[
      'さ', 'す', 'せ', 'そ', 'た', 'ち', 'つ', 'て',
      'と', 'な', 'に', 'ぬ', 'ね', 'の', 'は', 'ひ',
      'ふ', 'ほ', 'ま', 'み', 'む', 'め', 'も', 'や',
      'ゆ', 'よ', 'ら', 'り', 'る', 'ろ', 'れ', 'わ',
    ],
    input: AlphabetInput.chosen,
    isNumeric: false,
  );

  /// The hiragana of a green plate.
  static const PlateAlphabet kanaGreen = PlateAlphabet(
    id: 'jp.kana.green',
    characters: <String>[
      'あ', 'い', 'う', 'え', 'か', 'き', 'く', 'け',
      'こ', 'を',
    ],
    input: AlphabetInput.chosen,
    isNumeric: false,
  );

  /// Every hiragana any plate carries — the article's yellow list, which is
  /// the union of the white and green ones. The two-wheelers use it too: the
  /// article lists no set for them, and the reference plates print `あ` and `ゆ`.
  static const PlateAlphabet kanaAny = PlateAlphabet(
    id: 'jp.kana.any',
    characters: <String>[
      'あ', 'い', 'う', 'え', 'か', 'き', 'く', 'け',
      'こ', 'さ', 'す', 'せ', 'そ', 'た', 'ち', 'つ',
      'て', 'と', 'な', 'に', 'ぬ', 'ね', 'の', 'は',
      'ひ', 'ふ', 'ほ', 'ま', 'み', 'む', 'め', 'も',
      'や', 'ゆ', 'よ', 'ら', 'り', 'る', 'れ', 'ろ',
      'わ', 'を',
    ],
    input: AlphabetInput.chosen,
    isNumeric: false,
  );

  /// The hiragana of a black plate: the two rental characters.
  static const PlateAlphabet kanaBlack = PlateAlphabet(
    id: 'jp.kana.black',
    characters: <String>['り', 'れ'],
    input: AlphabetInput.chosen,
    isNumeric: false,
  );

  /// The issuing offices the article's table lists (current markings, in its
  /// order, without the former ones), each printed as one name.
  static const PlateAlphabet offices = PlateAlphabet(
    id: 'jp.office',
    characters: <String>[
      '尾張小牧', '一宮', '春日井', '名古屋', '豊橋', '三河',
      '岡崎', '豊田', '秋田', '青森', '弘前', '八戸',
      '千葉', '成田', '習志野', '市川', '船橋', '野田',
      '柏', '松戸', '袖ヶ浦', '市原', '愛媛', '福井',
      '福岡', '筑豊', '北九州', '久留米', '福島', '会津',
      '郡山', '白河', 'いわき', '岐阜', '飛騨', '群馬',
      '前橋', '高崎', '福山', '広島', '旭川', '函館',
      '北見', '知床', '釧路', '室蘭', '苫小牧', '帯広',
      '十勝', '札幌', '姫路', '神戸', '水戸', '土浦',
      'つくば', '石川', '金沢', '岩手', '平泉', '盛岡',
      '香川', '高松', '鹿児島', '奄美', '相模', '湘南',
      '川崎', '横浜', '高知', '熊本', '京都', '三重',
      '鈴鹿', '四日市', '伊勢志摩', '宮城', '仙台', '宮崎',
      '松本', '諏訪', '南信州', '安曇野', '長野', '長崎',
      '佐世保', '奈良', '飛鳥', '長岡', '上越', '新潟',
      '大分', '岡山', '倉敷', '沖縄', '和泉', '堺',
      '大阪', 'なにわ', '佐賀', '春日部', '越谷', '熊谷',
      '大宮', '川口', '所沢', '川越', '滋賀', '島根',
      '出雲', '浜松', '沼津', '富士山', '伊豆', '静岡',
      'とちぎ', '宇都宮', '那須', '日光', '徳島', '足立',
      '江東', '葛飾', '江戸川', '八王子', '多摩', '練馬',
      '杉並', '板橋', '品川', '世田谷', '鳥取', '富山',
      '和歌山', '庄内', '山形', '山口', '下関', '山梨',
    ],
    input: AlphabetInput.chosen,
    isNumeric: false,
  );
}
