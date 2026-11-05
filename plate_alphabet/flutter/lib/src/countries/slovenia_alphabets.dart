import 'package:plate_core/plate_core.dart';

/// The alphabets behind Slovenian slots.
///
/// Region codes are the unit codes the article tabulates (CE, GO, KK, KP, KR,
/// LJ, MB) plus the other four administrative units (MS, NM, PO, SG); the
/// table is cut off after MB, so those four are from memory. Serial letters
/// are the Latin capitals without Q, W, X and Y, which are not issued; also
/// from memory, and only advisory.
abstract final class SloveniaAlphabets {
  static const List<String> regionCodes = <String>[
    'CE', 'GO', 'KK', 'KP', 'KR', 'LJ', 'MB', 'MS', 'NM', 'PO', 'SG', //
  ];

  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  /// The letters region codes are made of.
  static const PlateAlphabet regionLetters = PlateAlphabet.pattern(
    id: 'si.region.letters',
    include: 'B-S',
    exclude: 'D F H I Q',
  );

  static const PlateAlphabet letters = PlateAlphabet.pattern(
    id: 'si.letters',
    include: 'A-Z',
    exclude: 'Q W X Y',
  );

  /// The single `P` of a police plate.
  static const PlateAlphabet policeLetter = PlateAlphabet(
    id: 'si.police.letter',
    characters: <String>['P'],
  );

  /// The `CD` of a diplomatic plate.
  static const PlateAlphabet diplomaticLetters = PlateAlphabet(
    id: 'si.diplomatic.letters',
    characters: <String>['C', 'D'],
  );
}
