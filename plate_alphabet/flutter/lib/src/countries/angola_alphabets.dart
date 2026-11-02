import 'package:plate_core/plate_core.dart';

/// The alphabets behind Angolan slots.
///
/// The article's format is AA-##-##-AA, the first pair being the region
/// (`LD` for Luanda). It states no letter set, so [letters] is the whole Latin
/// alphabet; the plates print Western digits.
abstract final class AngolaAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;
}
