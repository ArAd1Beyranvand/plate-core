import 'package:plate_core/plate_core.dart';

/// The alphabets behind Myanmar slots.
///
/// The 2021 plates print Latin letters and Western digits; [serialPrefix] is
/// the two-or-three character class code before the dash, which is a digit and
/// a letter on private and hire plates (`7R`, `1P`) and letters elsewhere
/// (`EE`, `HSE`, `RLG`), so one alphabet carries both. The older motorcycle and
/// rickshaw plates print Burmese: [burmeseDigits] stores `0-9` and prints
/// `၀-၉`, and [burmeseLetters] is the 33 consonants of the Burmese alphabet.
abstract final class MyanmarAlphabets {
  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const PlateAlphabet serialPrefix = PlateAlphabet.pattern(
    id: 'mm.prefix',
    include: '0-9 A-Z',
    input: AlphabetInput.chosen,
    isNumeric: false,
  );

  /// The make and model line: capitals, digits, space and hyphen.
  static const PlateAlphabet model = PlateAlphabet(
    id: 'mm.model',
    characters: <String>[
      ' ', '-', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', //
      'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', //
      'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
    ],
    input: AlphabetInput.chosen,
    isNumeric: false,
  );

  static const Map<String, String> _burmeseNumerals = <String, String>{
    '0': '၀', '1': '၁', '2': '၂', '3': '၃', '4': '၄', //
    '5': '၅', '6': '၆', '7': '၇', '8': '၈', '9': '၉',
  };

  static const PlateAlphabet burmeseDigits = PlateAlphabet.pattern(
    id: 'mm.burmese.digits',
    include: '0-9',
    input: AlphabetInput.typed,
    isNumeric: true,
    glyphs: _burmeseNumerals,
  );

  static const PlateAlphabet burmeseLetters = PlateAlphabet.pattern(
    id: 'mm.burmese.letters',
    include:
        'က ခ ဂ ဃ င စ ဆ ဇ ဈ ည ဋ ဌ ဍ ဎ ဏ တ ထ ဒ ဓ န ပ ဖ ဗ ဘ မ ယ ရ လ ဝ သ ဟ ဠ အ',
    input: AlphabetInput.chosen,
    isNumeric: false,
  );

  /// A cell that is a numeral or a consonant (`၂၃ ယ`).
  static const PlateAlphabet burmeseMixed = PlateAlphabet.pattern(
    id: 'mm.burmese.mixed',
    include:
        '0-9 က ခ ဂ ဃ င စ ဆ ဇ ဈ ည ဋ ဌ ဍ ဎ ဏ တ ထ ဒ ဓ န ပ ဖ ဗ ဘ မ ယ ရ လ ဝ သ ဟ ဠ အ',
    input: AlphabetInput.chosen,
    isNumeric: false,
    glyphs: _burmeseNumerals,
  );
}
