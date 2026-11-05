import 'package:plate_core/plate_core.dart';

import '../plate_alphabet.dart';

/// The alphabets behind Abkhazian slots.
///
/// Plates use thirteen Cyrillic capitals that resemble Latin ones
/// (А Б В Е К М Н О Р С Т У Х). Unlike Russia's, `Б` has no Latin twin, so
/// they are stored as Cyrillic.
abstract final class AbkhaziaAlphabets {
  static const PlateAlphabet digits = PlateAlphabetDigits.english;

  static const PlateAlphabet letters = PlateAlphabet.pattern(
    id: 'ab.letters',
    include: 'А Б В Е К М Н О Р С Т У Х',
  );

  /// The status letters of a diplomatic plate, picked as a unit. Assumed to be
  /// Russia's `CD`, `D`, `T`: the one photo shows only `CD`.
  static const PlateAlphabet diplomaticStatus = PlateAlphabet(
    id: 'ab.diplomatic_status',
    characters: <String>['CD', 'D', 'T'],
    input: AlphabetInput.chosen,
    placeholder: 'CD',
  );
}
