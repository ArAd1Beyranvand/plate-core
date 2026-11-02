import 'package:plate_core/plate_core.dart';

/// Saint Helena plates are digits only; government vehicles add the prefix
/// `SHG`.
abstract final class SaintHelenaAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  /// The fixed `SHG` that opens a government mark.
  static const PlateAlphabet government = PlateAlphabet(
    id: 'sh.government',
    characters: <String>['S', 'H', 'G'],
    input: AlphabetInput.typed,
    isNumeric: false,
  );
}
