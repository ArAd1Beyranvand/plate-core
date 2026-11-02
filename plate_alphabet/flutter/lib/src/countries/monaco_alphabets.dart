import 'package:plate_core/plate_core.dart';

/// The alphabets behind Monaco plates.
///
/// A car's four-character serial mixes digits and one letter (`A123`, `7756`,
/// `123A`) in a single printed run, so it takes one alphabet of both; a
/// motorcycle prints two letters then two digits.
abstract final class MonacoAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;

  static const PlateAlphabet serial = PlateAlphabet.pattern(
    id: 'mc.serial',
    include: '0-9 A-Z',
    input: AlphabetInput.typed,
    isNumeric: false,
  );
}
