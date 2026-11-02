import 'package:plate_core/plate_core.dart';

import '../plate_alphabet.dart';

/// The characters a current Syrian plate is composed of.
///
/// The transitional government's plate dropped Iranshahr numerals and
/// prints Western digits only. The AANES plate prints its six digits twice:
/// Western on top, Iranshahr underneath. Its motorcycle plate leads with
/// one Latin letter. The 1997 series and the opposition-held series are not
/// covered.
abstract final class SyriaAlphabets {
  /// Western digits — every slot on every current plate.
  static const PlateAlphabet digits = PlateAlphabetDigits.english;

  /// `٠..٩`, the AANES plate's echo row. Stores ASCII digits.
  static const PlateAlphabet iranshahrDigits = PlateAlphabetDigits.iranshahr;

  /// The letter before an AANES motorcycle's four digits. The article names
  /// no restricted set, so this is the whole Latin alphabet.
  static const PlateAlphabet letters = PlateAlphabet.pattern(
    id: 'sy.letters',
    include: 'A-Z',
    input: AlphabetInput.typed,
    isNumeric: false,
  );
}
