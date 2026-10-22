import 'package:plate_core/plate_core.dart';

/// The alphabets behind Rwandan slots. The format `RXX ###X` names no
/// excluded letter, so [letters] is the full Latin capital set; [serial] is the
/// second field, three digits then a letter, typed as one run.
abstract final class RwandaAlphabets {
  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;

  static const PlateAlphabet serial = PlateAlphabet.pattern(
    id: 'rw.serial',
    include: 'A-Z 0-9',
    input: AlphabetInput.typed,
    isNumeric: false,
  );
}
