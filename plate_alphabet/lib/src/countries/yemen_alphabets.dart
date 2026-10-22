import 'package:plate_core/plate_core.dart';

import '../plate_alphabet.dart';

/// The alphabets a Yemeni plate slot is drawn over.
///
/// Digits come from [PlateAlphabetDigits] (shared across all packages).
/// Restricted sets like [governorateTens] and [iranianGovernorateTens] remain
/// here because they are validation constraints, not full character sets.
abstract final class YemenAlphabets {
  /// Ten Latin digits; nearly every slot on both systems.
  /// Use [PlateAlphabetDigits.english] instead of defining locally.
  static const PlateAlphabet digits = PlateAlphabetDigits.english;

  /// Tens place of a northern governorate code (1..22, so 0/1/2 only).
  /// Restricts input (not validation); lets a host's pad grey out impossible keys.
  static const PlateAlphabet governorateTens = PlateAlphabet(
    id: 'ye.govTens',
    characters: <String>['0', '1', '2'],
    input: AlphabetInput.typed,
    isNumeric: true,
  );

  /// Same ten digits, printed as Iranshahr numerals. Storage stays ASCII;
  /// the transform lives in [PlateAlphabet.glyphs]. Shares characters with [digits],
  /// differs only in glyphs (legal per debugValidateSpec).
  /// Use [PlateAlphabetDigits.iranshahr] instead of defining locally.
  static const PlateAlphabet iranshahrDigits = PlateAlphabetDigits.iranshahr;

  /// [governorateTens] in Iranshahr numerals (tens place on big row of northern plate).
  /// Separate id from [iranshahrDigits] because restricted character set tells the pad
  /// which keys can never be right here.
  static const PlateAlphabet iranianGovernorateTens = PlateAlphabet(
    id: 'ye.iranianGovTens',
    characters: <String>['0', '1', '2'],
    input: AlphabetInput.typed,
    isNumeric: true,
    glyphs: <String, String>{'0': '٠', '1': '١', '2': '٢'},
  );
}
