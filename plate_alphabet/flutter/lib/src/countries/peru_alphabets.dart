import 'package:plate_core/plate_core.dart';

import '../plate_alphabet.dart';

/// Peruvian plates carry Western digits and Latin capitals.
abstract final class PeruAlphabets {
  static const PlateAlphabet digits = PlateAlphabetDigits.english;
  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;

  /// The register of a 2010 plate, which mixes the two as `ABC`, `AB1` or
  /// `A1B`: the second character runs 1-9, 0, then A-Z as the series fill.
  static const PlateAlphabet alphanumeric = PlateAlphabet.pattern(
    id: 'pe.alphanumeric',
    include: 'A-Z 0-9',
  );
}
