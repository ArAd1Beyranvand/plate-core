import 'package:plate_core/plate_core.dart';

/// Georgian plates are Latin only: serial letters are the capitals and the
/// numerals Latin digits. [alphanumeric] is for the vanity plate, which
/// prints any run of them.
abstract final class GeorgiaCountryAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;
  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;

  static const PlateAlphabet alphanumeric = PlateAlphabet.pattern(
    id: 'georgia.alphanumeric',
    include: '0-9 A-Z',
  );
}
