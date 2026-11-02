import 'package:plate_core/plate_core.dart';

/// The alphabets behind Vatican plates.
///
/// Plates are Latin capitals and ASCII digits: a fixed `CV` or `SCV` prefix,
/// digits, and on an official plate one trailing letter.
abstract final class VaticanCityAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;
}
