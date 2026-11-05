import 'package:plate_core/plate_core.dart';

/// Danish plates use Western digits and the 26 capitals; the national letters
/// Æ, Ø and Å appear only on vanity plates (the Ø of the reference).
abstract final class DenmarkAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;

  static const PlateAlphabet vanity = PlateAlphabet.pattern(
    id: 'dk.vanity',
    include: 'A-Z Æ Ø Å 0-9',
  );
}
