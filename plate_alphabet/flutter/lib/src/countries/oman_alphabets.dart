import 'package:flutter/widgets.dart';
import 'package:plate_core/plate_core.dart';

/// Oman's plate letter, printed twice: Latin below, Arabic above. Every value
/// is stored once, in Latin; [arabic] is the same characters through the glyph
/// map, so typing in either row writes the other.
///
/// Digits are Western on the current series.
abstract final class PlateAlphabetOman {
  /// The letter codes seen on 2001-series plates, one or two letters chosen
  /// as one value: `A` (article photograph), `B`/`M` and `BM` (private
  /// artwork), `K` and `KK` (taxi artwork).
  // TODO(oman-letters): the rest of the issued codes; none are sourced.
  static const PlateAlphabet letters = PlateAlphabet.pattern(
    id: 'om.letter.latin',
    include: 'A B K M BM KK',
    input: AlphabetInput.chosen,
    glyphs: <String, String>{'BM': 'B   M', 'KK': 'K   K'},
  );

  /// [letters] as the upper row prints it: a pair reads right to left, so
  /// `BM` prints `م` over `B` and `ب` over `M`.
  static const PlateAlphabet arabic = PlateAlphabet.pattern(
    id: 'om.letter.arabic',
    include: 'A B K M BM KK',
    input: AlphabetInput.chosen,
    direction: TextDirection.rtl,
    placeholder: '؟',
    glyphs: <String, String>{
      'A': 'ا',
      'B': 'ب',
      'K': 'ك',
      'M': 'م',
      'BM': 'ب   م',
      'KK': 'ك   ك',
    },
  );
}
