import 'package:plate_core/plate_core.dart';

/// The alphabets behind Argentine slots.
///
/// Plates are Latin capitals and ASCII digits. The article names no excluded
/// letters, so every capital is accepted; the category prefixes (`CD`, `ME`,
/// `D`, `M`...) are fixed codes the validators check.
abstract final class ArgentinaAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;
}
