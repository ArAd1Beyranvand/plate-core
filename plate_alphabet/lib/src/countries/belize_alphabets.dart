import 'package:plate_core/plate_core.dart';

/// The alphabets behind Belizean slots. Plates are Latin capitals and ASCII
/// digits: a class or district letter run (`C`, `D`, `DFS`) and a serial of
/// digits (`C-14884`, `DFS-041`).
abstract final class BelizeAlphabets {
  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;

  static const PlateAlphabet digits = PlateAlphabet.latinDigits;
}
