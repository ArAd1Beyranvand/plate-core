import 'package:plate_core/plate_core.dart';

/// The alphabets behind Mozambican slots.
///
/// The 2011 series is three letters, three digits and a two-letter province
/// code; the pre-2011 plates start with `M` and a district pair. Every letter
/// is allowed, so one set serves both.
abstract final class MozambiqueAlphabets {
  /// The province codes the article has seen on 2011 plates.
  static const List<String> provinceCodes = <String>[
    'CA', 'GZ', 'IB', 'MC', 'MP', 'MN', 'NP', 'NS', 'SF', 'TT', 'ZB', //
  ];

  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const PlateAlphabet letters = PlateAlphabet.pattern(
    id: 'mz.letters',
    include: 'A-Z',
    input: AlphabetInput.typed,
    isNumeric: false,
  );
}
