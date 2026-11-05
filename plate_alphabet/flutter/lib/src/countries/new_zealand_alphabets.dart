import 'package:plate_core/plate_core.dart';

/// New Zealand plates are Latin only. [alphanumeric] is for personalised
/// plates, which print any run of up to six letters and digits.
abstract final class NewZealandAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;
  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;

  static const PlateAlphabet alphanumeric = PlateAlphabet.pattern(
    id: 'new_zealand.alphanumeric',
    include: '0-9 A-Z',
  );
}
