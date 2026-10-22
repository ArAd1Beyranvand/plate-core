import 'package:plate_core/plate_core.dart';

/// The alphabets behind Maltese slots.
///
/// Plates are Latin capitals and ASCII digits. The article tabulates A–Z as
/// the month letters of a private plate, so the serial letters are the whole
/// alphabet; the taxi suffix is `M` (Malta) or `G` (Gozo).
abstract final class MaltaAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;

  /// A personalised plate: one to ten letters and/or digits.
  static const PlateAlphabet personalised = PlateAlphabet.pattern(
    id: 'mt.personalised',
    include: 'A-Z 0-9',
    input: AlphabetInput.typed,
    isNumeric: false,
  );

  /// The `M` or `G` that ends a taxi plate.
  static const PlateAlphabet island = PlateAlphabet(
    id: 'mt.island',
    characters: <String>['M', 'G'],
    input: AlphabetInput.typed,
    isNumeric: false,
  );
}
