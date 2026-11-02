import 'package:plate_core/plate_core.dart';

/// Virgin Islands plates are Latin capitals and ASCII digits: a class prefix
/// (`PV`, `GV`, `CM`, `TX`, `TAXI`) and a serial. The article excludes no letter.
abstract final class BritishVirginIslandsAlphabets {
  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;

  static const PlateAlphabet digits = PlateAlphabet.latinDigits;
}
