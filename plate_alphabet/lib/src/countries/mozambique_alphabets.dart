import 'package:plate_core/plate_core.dart';

/// The alphabets behind Mozambican slots.
///
/// The 2011 series is three letters, three digits and a two-letter province
/// code; the pre-2011 plates start with `M` and a district pair. Every letter
/// is allowed, so one set serves both.
abstract final class MozambiqueAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const PlateAlphabet letters = PlateAlphabet(
    id: 'mz.letters',
    characters: <String>[
      'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', //
      'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
    ],
    input: AlphabetInput.typed,
    isNumeric: false,
  );

  /// The province codes the article has seen on 2011 plates.
  static const List<String> provinceCodes = <String>[
    'CA', 'GZ', 'IB', 'MC', 'MP', 'MN', 'NP', 'NS', 'SF', 'TT', 'ZB', //
  ];
}
