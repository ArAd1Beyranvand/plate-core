import 'package:flutter/widgets.dart';
import 'package:plate_core/plate_core.dart';

import '../plate_alphabet.dart';

/// Alphabets of an Afghan plate, which prints every value twice: the serial in
/// Iranshahr numerals above and Latin figures below, the class as a
/// Persian letter above and a Latin code below. Each pair is one value with two
/// presentations (see [PlateMirror]), so the twins accept the same characters
/// and differ only in [PlateAlphabet.glyphs] and id. Storage stays ASCII.
abstract final class AfghanistanAlphabets {
  /// The serial as stored and as the lower register prints it.
  static const PlateAlphabet digits = PlateAlphabetDigits.english;

  /// The serial as the upper register prints it: Iranshahr numerals
  /// (`٤`), not the Persian variants (`۴`).
  static const PlateAlphabet iranshahrDigits = PlateAlphabetDigits.iranshahr;

  /// The vehicle class as the upper register prints it: one Persian letter,
  /// stored as an ASCII mnemonic (`'P'` prints `ش` here and `PRV` in
  /// [classLatin]).
  ///
  /// Seven classes, not the article's eleven: diplomatic, governmental and UN
  /// plates have no class register, which a spec without one expresses better
  /// than a character rendering to the empty string. Chosen, since the
  /// letters are not on a keyboard.
  static const PlateAlphabet vehicleClass = PlateAlphabet.pattern(
    id: 'af.class',
    include: 'P D T B L M R',
    input: AlphabetInput.chosen,
    isNumeric: false,
    direction: TextDirection.rtl,
    glyphs: <String, String>{
      'P': 'ش', // private
      'D': 'ش', // private duplicate — see classLatin
      'T': 'ت', // taxi
      'B': 'ب', // bus
      'L': 'ل', // lorry
      'M': 'م', // motorcycle
      'R': 'ر', // rickshaw
    },
  );

  /// The same class as the lower register prints it, in Latin. Here `P` and
  /// `D` come apart (`PRV` against `DUPL`), where the Persian register prints
  /// `ش` for both. Classes that render to themselves have no glyph entry.
  static const PlateAlphabet classLatin = PlateAlphabet.pattern(
    id: 'af.classLatin',
    include: 'P D T B L M R',
    input: AlphabetInput.chosen,
    isNumeric: false,
    glyphs: <String, String>{'P': 'PRV', 'D': 'DUPL', 'R': 'TRC'},
  );

  /// Category of a cross-border plate: `BUS`, `TAXI` or `CARGO`. It names the
  /// service run, not the registered class, so it is not a subset of
  /// [classLatin].
  static const PlateAlphabet internationalCategory = PlateAlphabet(
    id: 'af.intlCategory',
    characters: <String>['B', 'T', 'C'],
    input: AlphabetInput.chosen,
    isNumeric: false,
    glyphs: <String, String>{'B': 'BUS', 'T': 'TAXI', 'C': 'CARGO'},
  );
}
