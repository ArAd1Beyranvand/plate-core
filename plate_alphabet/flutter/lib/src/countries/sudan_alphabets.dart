import 'package:plate_core/plate_core.dart';

import '../plate_alphabet.dart';
import 'package:flutter/widgets.dart';

/// The alphabets a Sudanese plate slot is drawn over.
///
/// Every value is stored once, in Latin, and each row of the plate is that
/// value through a different alphabet: the big Arabic row through the glyph
/// maps below, the small Latin row through the same characters with none. So
/// the state code `KH` prints `خ` above and `KH` below, and typing in either
/// row writes the other.
abstract final class SudanAlphabets {
  static const PlateAlphabet digits = PlateAlphabetDigits.english;
  static const PlateAlphabet iranshahrDigits = PlateAlphabetDigits.iranshahr;

  /// State codes seen on a 2009-series plate, Latin as printed on the lower
  /// row: `KH` Khartoum (artwork, factory sample, worldlicenseplates),
  /// `G` Al Jazirah and `RS` Red Sea (worldlicenseplates).
  // TODO(sudan-states): the other states' codes; none are sourced.
  static const PlateAlphabet stateLatin = PlateAlphabet.pattern(
    id: 'sd.state.latin',
    include: 'KH G RS',
    input: AlphabetInput.chosen,
    isNumeric: false,
  );

  // TODO(py): [H7] glyph 'RS' holds U+200C (ZWNJ) between ب and ح; keep it in the export, text shaping depends on it.
  // TODO(ts): [H7] glyph holds U+200C; JSON export must emit \u200c, and don't trim() glyphs.
  // TODO(kt): [H7] glyph holds U+200C; keep it as \u200C in generated sources, and don't trim() glyphs.
  /// [stateLatin] as the upper row prints it. Red Sea is two letters, spaced
  /// apart as on the photographed plate (`٨ ب ح` over `8RS`) — unjoined by a
  /// zero-width non-joiner, since any space pushes ب into the class digit.
  static const PlateAlphabet stateArabic = PlateAlphabet.pattern(
    id: 'sd.state.arabic',
    include: 'KH G RS',
    input: AlphabetInput.chosen,
    isNumeric: false,
    direction: TextDirection.rtl,
    placeholder: '؟',
    glyphs: <String, String>{'KH': 'خ', 'G': 'ج', 'RS': 'ب\u200Cح'},
  );
}
