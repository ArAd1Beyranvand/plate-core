import 'package:plate_core/plate_core.dart';

/// The alphabets behind Portuguese slots.
///
/// The 2020 series (`AA 00 AA`) uses every letter, W, Y and K included, so one
/// set serves every field; [mixed] is the first field of the US Forces plates,
/// a letter then a digit (`A1`). [diplomaticCode] is the `CD` of the
/// diplomatic plate, the only code the article shows.
abstract final class PortugalAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const List<String> _letters = <String>[
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', //
    'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
  ];

  static const PlateAlphabet letters = PlateAlphabet(
    id: 'pt.letters',
    characters: _letters,
    input: AlphabetInput.typed,
    isNumeric: false,
  );

  static const PlateAlphabet mixed = PlateAlphabet(
    id: 'pt.mixed',
    characters: <String>[
      ..._letters,
      '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', //
    ],
    input: AlphabetInput.typed,
    isNumeric: false,
  );

  static const PlateAlphabet diplomaticCode = PlateAlphabet(
    id: 'pt.diplomatic.code',
    characters: <String>['C', 'D'],
    input: AlphabetInput.typed,
    isNumeric: false,
  );
}
