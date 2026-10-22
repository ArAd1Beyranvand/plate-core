import 'package:plate_core/plate_core.dart';

/// The alphabets behind Portuguese slots.
///
/// The 2020 series (`AA 00 AA`) uses every letter, W, Y and K included, so one
/// set serves every field; [mixed] is the first field of the US Forces plates,
/// a letter then a digit (`A1`). [diplomaticCode] is the `CD` of the
/// diplomatic plate, the only code the article shows.
abstract final class PortugalAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const PlateAlphabet letters = PlateAlphabet.pattern(
    id: 'pt.letters',
    include: 'A-Z',
    input: AlphabetInput.typed,
    isNumeric: false,
  );

  static const PlateAlphabet mixed = PlateAlphabet.pattern(
    id: 'pt.mixed',
    include: 'A-Z 0-9',
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
