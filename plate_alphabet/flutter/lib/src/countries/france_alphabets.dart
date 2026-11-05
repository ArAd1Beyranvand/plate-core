import 'package:plate_core/plate_core.dart';

/// The alphabets behind French slots.
///
/// SIV serial letters are the Latin alphabet without I, O and U (23 letters).
/// A département code is two digits, or `2A`/`2B` for Corsica, so its alphabet
/// is the digits plus A and B. Diplomatic status letters are C, D, M and K
/// (`C`, `CD`, `CMD`, `K`).
abstract final class FranceAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const PlateAlphabet letters = PlateAlphabet.pattern(
    id: 'fr.letters',
    include: 'A-Z',
    exclude: 'I O U',
  );

  static const PlateAlphabet department = PlateAlphabet.pattern(
    id: 'fr.department',
    include: '0-9 A B',
  );

  static const PlateAlphabet status = PlateAlphabet.pattern(
    id: 'fr.status',
    include: 'C D K M',
  );
}
