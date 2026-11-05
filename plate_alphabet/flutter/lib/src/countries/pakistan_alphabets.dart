import 'package:plate_core/plate_core.dart';

/// The alphabets behind Pakistani slots.
///
/// The article: every plate uses the Latin alphabet, and the letters I, O and
/// U are not used.
abstract final class PakistanAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const PlateAlphabet letters = PlateAlphabet.pattern(
    id: 'pk.letters',
    include: 'A-Z',
    exclude: 'I O U',
  );
}
