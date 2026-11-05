import 'package:plate_core/plate_core.dart';

/// The alphabets behind North Macedonian slots.
///
/// The plates print Latin letters only, but the red block between the area
/// code and the number echoes the area code and the series letters in
/// Cyrillic (`BT` → `БТ`, `KS` → `КС`). The `*Cyrillic` alphabets are those
/// echoes: same characters, Cyrillic glyphs, for a `PlateMirror`.
abstract final class NorthMacedoniaAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const Map<String, String> _regionGlyphs = <String, String>{
    'A': 'А', 'B': 'Б', 'D': 'Д', 'E': 'Е', 'G': 'Г', 'H': 'Х', 'I': 'И', //
    'K': 'К', 'M': 'М', 'N': 'Н', 'O': 'О', 'P': 'П', 'R': 'Р', 'S': 'С', //
    'T': 'Т', 'U': 'У', 'V': 'В',
  };

  /// The letters the 34 area codes are made of.
  static const PlateAlphabet regionLetters = PlateAlphabet.pattern(
    id: 'mk.region.letters',
    include: 'A-V',
    exclude: 'C F J L Q',
  );

  static const PlateAlphabet regionCyrillic = PlateAlphabet.pattern(
    id: 'mk.region.cyrillic',
    include: 'A-V',
    exclude: 'C F J L Q',
    glyphs: _regionGlyphs,
  );

  /// The series letters after the number: the Latin letters that have a
  /// Cyrillic counterpart.
  static const PlateAlphabet letters = PlateAlphabet.pattern(
    id: 'mk.letters',
    include: 'A-Z',
    exclude: 'Q W X Y',
  );

  static const PlateAlphabet lettersCyrillic = PlateAlphabet.pattern(
    id: 'mk.letters.cyrillic',
    include: 'A-Z',
    exclude: 'Q W X Y',
    glyphs: <String, String>{
      'A': 'А', 'B': 'Б', 'C': 'Ц', 'D': 'Д', 'E': 'Е', 'F': 'Ф', 'G': 'Г', //
      'H': 'Х', 'I': 'И', 'J': 'Ј', 'K': 'К', 'L': 'Л', 'M': 'М', 'N': 'Н', //
      'O': 'О', 'P': 'П', 'R': 'Р', 'S': 'С', 'T': 'Т', 'U': 'У', 'V': 'В', //
      'Z': 'З',
    },
  );

  /// The class letters of a diplomatic plate: `CD` diplomatic corps, `CC`
  /// consular corps, `CMD` head of mission.
  static const PlateAlphabet diplomaticLetters = PlateAlphabet(
    id: 'mk.diplomatic.letters',
    characters: <String>['C', 'D', 'M'],
  );
}
