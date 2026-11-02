import 'package:plate_core/plate_core.dart';

/// The alphabets behind Dutch slots.
///
/// Ordinary plates use only the consonants B D F G H J K L N P R S T V X Z
/// (no vowels, no C or Q, no M or W), but the special series print the others
/// (`CD`, `AA`, `OK`, `WX`, `EM`), so the typed alphabet is all of A–Z; the
/// validator reports ordinary letters outside the consonant set.
abstract final class NetherlandsAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const PlateAlphabet letters = PlateAlphabet.pattern(
    id: 'nl.letters',
    include: 'A-Z',
    input: AlphabetInput.typed,
    isNumeric: false,
  );

  /// The letters ordinary registrations are drawn from.
  static const String consonants = 'BDFGHJKLNPRSTVXZ';
}
