import 'package:plate_core/plate_core.dart';

import '../plate_alphabet.dart';

abstract final class NigerAlphabets {
  static const PlateAlphabet digits = PlateAlphabetDigits.english;

  /// The eight regions, by digit: 1 Agadez, 2 Diffa, 3 Dosso, 4 Maradi,
  /// 5 Tahoua, 6 Tillabéri, 7 Zinder, 8 Niamey.
  static const PlateAlphabet region = PlateAlphabet.pattern(
    id: 'ne.region',
    include: '1-8',
    isNumeric: true,
  );

  static const PlateAlphabet series = PlateAlphabet.latinUppercase;
}
