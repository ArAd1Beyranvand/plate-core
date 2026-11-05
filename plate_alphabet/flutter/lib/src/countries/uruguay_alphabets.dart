import 'package:plate_core/plate_core.dart';

/// The alphabets behind Uruguayan slots.
///
/// The first letter of a serial is the department's code (the article's
/// table: A Canelones … S Montevideo, nineteen letters, A to S); the other
/// letters of the serial are any Latin capital.
abstract final class UruguayAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;

  static const PlateAlphabet department = PlateAlphabet.pattern(
    id: 'uy.department',
    include: 'A-S',
  );
}
