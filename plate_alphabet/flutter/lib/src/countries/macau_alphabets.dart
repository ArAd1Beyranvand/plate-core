import 'package:plate_core/plate_core.dart';

/// The alphabets behind Macanese slots.
///
/// The article names no excluded letter for the `MA` series, so [letters] is
/// the full Latin capital set. The mainland supplement plate follows the
/// Chinese standard, which drops I and O.
abstract final class MacauAlphabets {
  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  /// One character of the mainland supplement plate's serial: a digit, or a
  /// letter but I and O.
  static const PlateAlphabet mainlandSerial = PlateAlphabet.pattern(
    id: 'mo.mainland',
    include: '0-9 A-Z',
    exclude: 'I O',
  );
}
