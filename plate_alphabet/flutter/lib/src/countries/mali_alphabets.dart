import 'package:plate_core/plate_core.dart';

import '../plate_alphabet.dart';

/// The alphabets behind Mali slots. Latin letters and Western digits on
/// the current plate series.
abstract final class MaliAlphabets {
  static const PlateAlphabet digits = PlateAlphabetDigits.english;

  static const PlateAlphabet letters = PlateAlphabet.pattern(
    id: 'ml.letters',
    include: 'A-Z',
  );
}
