import 'package:plate_core/plate_core.dart';

import '../plate_alphabet.dart';

/// The alphabets behind Republic of the Congo slots. Latin letters and
/// Western digits on the current series.
abstract final class RepublicOfTheCongoAlphabets {
  static const PlateAlphabet digits = PlateAlphabetDigits.english;

  static const PlateAlphabet letters = PlateAlphabet.pattern(
    id: 'cg.letters',
    include: 'A-Z',
  );
}
