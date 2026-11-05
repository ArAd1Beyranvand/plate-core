import 'package:plate_core/plate_core.dart';

/// The alphabets behind Polish slots.
///
/// Every Latin letter but Q is used. B, D, I, O and Z may not appear in a
/// series (the part after the gap) of an ordinary plate, but custom plates
/// may use them, so the alphabet keeps them and the validator judges.
abstract final class PolandAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const PlateAlphabet letters = PlateAlphabet.pattern(
    id: 'pl.letters',
    include: 'A-Z',
    exclude: 'Q',
  );

  /// Letters and digits, for a field that mixes them (a series, a temporary
  /// plate's voivodeship code `D6`).
  static const PlateAlphabet alphanumeric = PlateAlphabet.pattern(
    id: 'pl.alphanumeric',
    include: 'A-Z 0-9',
    exclude: 'Q',
  );
}
