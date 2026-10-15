import 'package:plate_core/plate_core.dart';

/// The alphabets behind Turkmen slots.
///
/// Province codes are the seven the article tabulates (AG Ashgabat … MR Mary).
/// Every other letter position is the Latin capitals: the article states no
/// restriction on series, trailer, class or military letters.
abstract final class TurkmenistanAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const List<String> provinceCodes = <String>[
    'AG', 'AH', 'AK', 'BN', 'DZ', 'LB', 'MR', //
  ];

  static const PlateAlphabet letters = PlateAlphabet(
    id: 'tm.letters',
    characters: <String>[
      'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', //
      'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
    ],
    input: AlphabetInput.typed,
    isNumeric: false,
  );
}
