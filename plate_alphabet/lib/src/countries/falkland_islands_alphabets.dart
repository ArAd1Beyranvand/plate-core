import 'package:plate_core/plate_core.dart';

/// The alphabets behind Falkland Islands slots.
///
/// Plates are Latin capitals and ASCII digits, as in the United Kingdom.
abstract final class FalklandIslandsAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;

  /// The fixed `F` that opens every plate.
  static const PlateAlphabet prefix = PlateAlphabet(
    id: 'fk.prefix',
    characters: <String>['F'],
    input: AlphabetInput.typed,
    isNumeric: false,
  );
}
