import 'package:plate_core/plate_core.dart';

import '../plate_alphabet.dart';

/// The alphabets behind Democratic Republic of the Congo slots. Latin letters
/// and Western digits on every current series.
abstract final class DemocraticRepublicOfTheCongoAlphabets {
  static const PlateAlphabet digits = PlateAlphabetDigits.english;

  static const PlateAlphabet letters = PlateAlphabet.pattern(
    id: 'cd.letters',
    include: 'A-Z',
  );
}
