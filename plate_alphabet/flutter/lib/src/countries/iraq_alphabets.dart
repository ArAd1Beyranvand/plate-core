import 'package:plate_core/plate_core.dart';

import '../plate_alphabet.dart';

/// The characters an Iraqi plate is composed of.
///
/// The 2022/2024 series is the first to print in the Latin alphabet and
/// western Arabic numerals; everything before it used Arabic script and
/// Iranshahr numerals. These are the current series only.
abstract final class IraqAlphabets {
  /// Western Arabic numerals — what the current series prints, for both the
  /// governorate code and the serial.
  static const PlateAlphabet digits = PlateAlphabetDigits.english;

  /// The single class letter between the governorate code and the serial.
  ///
  /// The current series does not publish a restricted set, and the reference
  /// artwork prints "G", which the preceding Arabic series did not have. So
  /// this is the full Latin alphabet; the narrower historical set is
  /// [IraqValidators.arabicSeriesLetters], which describes rather than
  /// restricts.
  static const PlateAlphabet letters = PlateAlphabet.pattern(
    id: 'iq.letters',
    include: 'A-Z',
  );
}
