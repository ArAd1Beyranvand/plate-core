import 'package:plate_core/plate_core.dart';

import '../plate_alphabet.dart';

/// The alphabets behind Canadian slots.
///
/// Serials are Latin capitals and ASCII digits. I, O, Q and U are generally
/// left out of issued serials, but that is an issuing rule, so it is reported
/// by `CanadianPermitValidator` rather than barred here.
abstract final class CanadaAlphabets {
  static const PlateAlphabet digits = PlateAlphabetDigits.english;

  static const PlateAlphabet letters = PlateAlphabetLatin.typed;
}
