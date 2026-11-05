import 'package:plate_core/plate_core.dart';

/// The alphabets behind Seychellois slots: the series letter (`S`) and the two-letter tag (`HV`). All 26 Latin capitals; the
/// article names no excluded letter.
abstract final class SeychellesAlphabets {
  static const PlateAlphabet digits = PlateAlphabet.latinDigits;

  static const PlateAlphabet letters = PlateAlphabet.pattern(
    id: 'sc.letters',
    include: 'A-Z',
  );
}
