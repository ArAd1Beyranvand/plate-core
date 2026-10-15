import 'package:plate_core/plate_core.dart';

/// The alphabets behind Cambodian slots.
///
/// The article gives the format as one class digit, one or two Latin letters
/// and four digits; the province's name is printed text, not a slot. The
/// photographed plates print Western digits. No letter set is stated, so
/// [letters] is the whole Latin alphabet; it also serves the fixed prefixes
/// of the stacked plates (`CD`, `ONG`).
abstract final class CambodiaAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;
}
