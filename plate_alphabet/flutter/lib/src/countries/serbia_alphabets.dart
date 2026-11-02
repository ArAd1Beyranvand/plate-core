import 'package:plate_core/plate_core.dart';

/// The alphabets behind Serbian slots.
///
/// Registration areas are two letters of the Serbian Latin alphabet, the
/// article's table includes `BĆ`, `BČ`, `VŠ`, `KŽ` and `KŠ`, so the four
/// caroned letters are region letters; the Cyrillic echo under the crest is a
/// per-letter transliteration ([regionCyrillic]). Serial letters are the
/// Latin capitals without diacritics, with X added as the article says.
abstract final class SerbiaAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const PlateAlphabet regionLetters = PlateAlphabet.pattern(
    id: 'rs.region.letters',
    include: 'A-C Ć Č D-S Š T-V Z Ž',
    exclude: 'F H Q',
    input: AlphabetInput.typed,
    isNumeric: false,
  );

  /// The same letters, printed in Cyrillic: the echo of the area code under
  /// the crest.
  static const PlateAlphabet regionCyrillic = PlateAlphabet.pattern(
    id: 'rs.region.cyrillic',
    include: 'A-C Ć Č D-S Š T-V Z Ž',
    exclude: 'F H Q',
    input: AlphabetInput.typed,
    isNumeric: false,
    glyphs: <String, String>{
      'A': 'А', 'B': 'Б', 'C': 'Ц', 'Ć': 'Ћ', 'Č': 'Ч', 'D': 'Д', 'E': 'Е', //
      'G': 'Г', 'I': 'И', 'J': 'Ј', 'K': 'К', 'L': 'Л', 'M': 'М', 'N': 'Н', //
      'O': 'О', 'P': 'П', 'R': 'Р', 'S': 'С', 'Š': 'Ш', 'T': 'Т', 'U': 'У', //
      'V': 'В', 'Z': 'З', 'Ž': 'Ж',
    },
  );

  static const PlateAlphabet letters = PlateAlphabet.pattern(
    id: 'rs.letters',
    include: 'A-Z',
    exclude: 'Q W Y',
    input: AlphabetInput.typed,
    isNumeric: false,
  );

  /// The Cyrillic `П` of a police plate.
  static const PlateAlphabet policeLetter = PlateAlphabet(
    id: 'rs.police.letter',
    characters: <String>['П'],
    input: AlphabetInput.typed,
    isNumeric: false,
  );

  /// Diplomatic series letter: `A` diplomat, `M` accredited staff, `P` press.
  static const PlateAlphabet diplomaticLetters = PlateAlphabet(
    id: 'rs.diplomatic.letters',
    characters: <String>['A', 'M', 'P'],
    input: AlphabetInput.typed,
    isNumeric: false,
  );

  /// The fixed `TX` of a taxi plate.
  static const PlateAlphabet taxiFirst = PlateAlphabet(
    id: 'rs.taxi.first',
    characters: <String>['T'],
    input: AlphabetInput.typed,
    isNumeric: false,
  );
  static const PlateAlphabet taxiSecond = PlateAlphabet(
    id: 'rs.taxi.second',
    characters: <String>['X'],
    input: AlphabetInput.typed,
    isNumeric: false,
  );

  /// The fixed `OT` of a historic vehicle.
  static const PlateAlphabet oldtimerFirst = PlateAlphabet(
    id: 'rs.oldtimer.first',
    characters: <String>['O'],
    input: AlphabetInput.typed,
    isNumeric: false,
  );
  static const PlateAlphabet oldtimerSecond = PlateAlphabet(
    id: 'rs.oldtimer.second',
    characters: <String>['T'],
    input: AlphabetInput.typed,
    isNumeric: false,
  );
}
