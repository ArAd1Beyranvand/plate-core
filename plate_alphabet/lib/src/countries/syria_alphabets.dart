import 'package:plate_core/plate_core.dart';

import '../plate_alphabet.dart';

/// The characters a current Syrian plate is composed of.
///
/// The transitional government's plate dropped Eastern Arabic numerals and
/// prints Western digits only. The AANES plate prints its six digits twice:
/// Western on top, Eastern Arabic underneath. Its motorcycle plate leads with
/// one Latin letter. The 1997 series and the opposition-held series are not
/// covered.
abstract final class SyriaAlphabets {
  /// Western digits — every slot on every current plate.
  static const PlateAlphabet digits = PlateAlphabetDigits.english;

  /// `٠..٩`, the AANES plate's echo row. Stores ASCII digits.
  static const PlateAlphabet easternDigits = PlateAlphabetDigits.iranshahr;

  /// The letter before an AANES motorcycle's four digits. The article names
  /// no restricted set, so this is the whole Latin alphabet.
  static const PlateAlphabet letters = PlateAlphabet(
    id: 'sy.letters',
    characters: <String>[
      'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', //
      'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
    ],
    input: AlphabetInput.typed,
    isNumeric: false,
  );
}
