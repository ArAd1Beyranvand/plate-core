import 'package:plate_core/plate_core.dart';

/// The alphabets behind Greek slots.
///
/// Greek plates only use the fourteen capitals of the Greek alphabet that
/// have a Latin twin (Α Β Ε Ζ Η Ι Κ Μ Ν Ο Ρ Τ Υ Χ), so that a plate reads the
/// same to a Greek and to a foreign eye. They are stored as the Latin
/// letters, which is also what the photographed plates print.
abstract final class GreeceAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const PlateAlphabet letters = PlateAlphabet.pattern(
    id: 'gr.letters',
    include: 'A B E Z H I K M-P T Y X',
    input: AlphabetInput.typed,
    isNumeric: false,
  );
}
