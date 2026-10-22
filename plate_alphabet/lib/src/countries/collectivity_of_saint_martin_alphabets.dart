import 'package:plate_core/plate_core.dart';

import 'france_alphabets.dart';

/// The alphabets behind the Collectivity of Saint Martin's slots, which uses
/// French stamping dies and the FNI format `1234-ABC`: the serial letters are
/// France's (Latin without I, O, U) and the digits are Latin.
abstract final class CollectivityOfSaintMartinAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;
  static const PlateAlphabet letters = FranceAlphabets.letters;
}
