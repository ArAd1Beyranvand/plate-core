import 'package:plate_core/plate_core.dart';

/// The alphabets behind Botswanan slots.
///
/// The article says the three letters of a private plate never include Q, so
/// it is not confused with O. The prefix (`B`, `BX`) is a fixed letter pair
/// and takes the same set.
abstract final class BotswanaAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const PlateAlphabet letters = PlateAlphabet.pattern(
    id: 'bw.letters',
    include: 'A-Z',
    exclude: 'Q',
    input: AlphabetInput.typed,
    isNumeric: false,
  );
}
