import 'package:plate_core/plate_core.dart';

import '../plate_alphabet.dart';

/// The alphabets behind Taiwanese slots.
///
/// [letters] is the serial letter of the 2012+ plate: the article says I and O
/// are not issued. [alphanumeric] is the 1992 plate's two-character and
/// four-character fields, which mix letters and digits (`9R-8027`, `AI-4329`).
/// The rules live in the validators; these only say what a key may type.
abstract final class TaiwanAlphabets {
  static const PlateAlphabet digits = PlateAlphabetDigits.english;

  static const PlateAlphabet letters = PlateAlphabet.pattern(
    id: 'tw.letters',
    include: 'A-Z',
    exclude: 'I O',
  );

  static const PlateAlphabet alphanumeric = PlateAlphabet.pattern(
    id: 'tw.alphanumeric',
    include: 'A-Z 0-9',
  );
}
