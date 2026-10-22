import 'package:plate_core/plate_core.dart';

/// The alphabets behind Australian slots.
///
/// Every state issues Latin capitals and ASCII digits. The article names
/// letters a series skips (NSW suffixes `IA`–`IZ` and `OA`–`OZ`, SA's `Q`);
/// the validator checks them, the alphabets accept every capital.
abstract final class AustraliaAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;

  /// A field that mixes letters and digits, such as SA's `S647` or VIC's `1NC`.
  static const PlateAlphabet alphanumeric = PlateAlphabet.pattern(
    id: 'au.alphanumeric',
    include: 'A-Z 0-9',
    input: AlphabetInput.typed,
    isNumeric: false,
  );
}
