import 'package:plate_core/plate_core.dart';

/// The alphabets behind Argentine slots.
///
/// Plates are Latin capitals and ASCII digits. The article names no excluded
/// letters, so every capital is accepted; the category prefixes (`CD`, `ME`,
/// `D`, `M`...) are fixed codes the validators check.
abstract final class ArgentinaAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;

  /// The category letter of a 1995 foreign-mission plate.
  static const PlateAlphabet missionClass = PlateAlphabet(
    id: 'ar.missionClass',
    characters: <String>['D', 'C', 'M', 'I', 'A'],
    input: AlphabetInput.chosen,
  );

  /// The category code of a 1985 foreign-mission plate, printed as two letters.
  static const PlateAlphabet mission1985Class = PlateAlphabet(
    id: 'ar.mission1985Class',
    characters: <String>['CD', 'CC', 'ME', 'OI', 'PA'],
    input: AlphabetInput.chosen,
    glyphs: <String, String>{
      'CD': 'C  D',
      'CC': 'C  C',
      'ME': 'M  E',
      'OI': 'O  I',
      'PA': 'P  A',
    },
  );
}
