import 'package:plate_core/plate_core.dart';

/// The alphabets behind Lithuanian slots.
///
/// The article says Q, W and X are not used in Lithuanian registration
/// numbers, so [letters] has 23 characters.
abstract final class LithuaniaAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const PlateAlphabet letters = PlateAlphabet.pattern(
    id: 'lt.letters',
    include: 'A-Z',
    exclude: 'Q W X',
  );
}
