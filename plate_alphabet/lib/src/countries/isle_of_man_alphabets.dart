import 'package:plate_core/plate_core.dart';

/// The alphabets behind Isle of Man slots.
///
/// Manx plates never use `I`, `Q`, `S` or `Z`; the first letter is never `A`
/// and the last is never `O`. The middle two letters of the first field are
/// always `MN`, which the validator checks.
abstract final class IsleOfManAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const PlateAlphabet letters = PlateAlphabet.pattern(
    id: 'im.letters',
    include: 'A-Z',
    exclude: 'I Q S Z',
    input: AlphabetInput.typed,
    isNumeric: false,
  );

  /// The trailing serial letter: the plain set less `O`.
  static const PlateAlphabet suffix = PlateAlphabet.pattern(
    id: 'im.suffix',
    include: 'A-Z',
    exclude: 'I O Q S Z',
    input: AlphabetInput.typed,
    isNumeric: false,
  );
}
