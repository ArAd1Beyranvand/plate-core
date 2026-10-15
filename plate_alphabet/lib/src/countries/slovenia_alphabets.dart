import 'package:plate_core/plate_core.dart';

/// The alphabets behind Slovenian slots.
///
/// Region codes are the unit codes the article tabulates (CE, GO, KK, KP, KR,
/// LJ, MB) plus the other four administrative units (MS, NM, PO, SG); the
/// table is cut off after MB, so those four are from memory. Serial letters
/// are the Latin capitals without Q, W, X and Y, which are not issued; also
/// from memory, and only advisory.
abstract final class SloveniaAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const List<String> regionCodes = <String>[
    'CE', 'GO', 'KK', 'KP', 'KR', 'LJ', 'MB', 'MS', 'NM', 'PO', 'SG', //
  ];

  /// The letters region codes are made of.
  static const PlateAlphabet regionLetters = PlateAlphabet(
    id: 'si.region.letters',
    characters: <String>[
      'B', 'C', 'E', 'G', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'R', 'S', //
    ],
    input: AlphabetInput.typed,
    isNumeric: false,
  );

  static const PlateAlphabet letters = PlateAlphabet(
    id: 'si.letters',
    characters: <String>[
      'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', //
      'N', 'O', 'P', 'R', 'S', 'T', 'U', 'V', 'Z',
    ],
    input: AlphabetInput.typed,
    isNumeric: false,
  );

  /// The single `P` of a police plate.
  static const PlateAlphabet policeLetter = PlateAlphabet(
    id: 'si.police.letter',
    characters: <String>['P'],
    input: AlphabetInput.typed,
    isNumeric: false,
  );

  /// The `CD` of a diplomatic plate.
  static const PlateAlphabet diplomaticLetters = PlateAlphabet(
    id: 'si.diplomatic.letters',
    characters: <String>['C', 'D'],
    input: AlphabetInput.typed,
    isNumeric: false,
  );
}
