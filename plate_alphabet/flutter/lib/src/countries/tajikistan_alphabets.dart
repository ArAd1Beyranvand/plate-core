import 'package:plate_core/plate_core.dart';

/// Alphabets of a Tajik plate. Plates print Latin, but the register is
/// Cyrillic in Latin shapes: the eleven letters whose Cyrillic and Latin forms
/// coincide (`А В Е К М Н О Р С Т Х`) plus `D J Z Y`, added in the 2014
/// redesign. [letters] therefore has no [PlateAlphabet.glyphs].
abstract final class TajikistanAlphabets {
  /// The closed set of letters a civilian number may carry. `H` and `P` are
  /// partners of Cyrillic `Н` and `Р` by shape, not sound.
  static const PlateAlphabet letters = PlateAlphabet.pattern(
    id: 'tj.letters',
    include: 'A-E H J K M O P T X-Z',
  );

  /// Diplomatic class: `CD` corps, `CMD` head of mission, `D`, `T` and `S` for
  /// the ranks below. `CMD` is one choice rendered as three characters, hence
  /// chosen input and a wide slot.
  static const PlateAlphabet diplomaticClass = PlateAlphabet.pattern(
    id: 'tj.diplomaticClass',
    include: 'CD CMD D T S',
    input: AlphabetInput.chosen,
  );
}
