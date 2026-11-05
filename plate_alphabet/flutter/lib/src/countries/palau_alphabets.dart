import 'package:plate_core/plate_core.dart';

/// The alphabets behind Palauan slots: Latin digits and capitals, no
/// restriction on which letters occur.
abstract final class PalauAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const PlateAlphabet letters = PlateAlphabet.latinUppercase;

  /// A run that mixes both, such as Koror's black plate `2K5136`.
  static const PlateAlphabet alphanumeric = PlateAlphabet.pattern(
    id: 'pw.alphanumeric',
    include: 'A-Z 0-9',
  );
}
