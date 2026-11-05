import 'package:plate_core/plate_core.dart';

/// The alphabets behind Andorran slots.
///
/// Plates are Latin capitals and ASCII digits. The standard plate carries one
/// letter; the temporary plate's expiry month is a Roman numeral.
abstract final class AndorraAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;

  /// The expiry month of a temporary plate, I to XII.
  static const PlateAlphabet romanMonth = PlateAlphabet(
    id: 'ad.romanMonth',
    characters: <String>['I', 'V', 'X'],
  );
}
