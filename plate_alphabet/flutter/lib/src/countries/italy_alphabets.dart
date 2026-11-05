import 'package:plate_core/plate_core.dart';

/// The alphabets behind Italian slots.
///
/// The article gives the serial letters as the Latin alphabet except I, O, Q
/// and U (a base-22 digit), so [letters] has 22 characters.
abstract final class ItalyAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const PlateAlphabet letters = PlateAlphabet.pattern(
    id: 'it.letters',
    include: 'A-Z',
    exclude: 'I O Q U',
  );
}
