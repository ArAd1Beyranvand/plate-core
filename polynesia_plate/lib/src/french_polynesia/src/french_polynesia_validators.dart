import 'package:plate_core/plate_core.dart';

/// Judges a French Polynesia plate: six digits and one letter, as in
/// `233051 P`. The letter leaves out I, O and U. Reports, never bars a
/// keystroke.
class FrenchPolynesiaValidator extends GatedPlateValidator {
  const FrenchPolynesiaValidator();

  @override
  String get gateGroup => 'number';

  static const String reasonNumber = 'The number is six digits.';
  static const String reasonLetter = 'The letter is one of A–Z without I, O, U.';

  static final RegExp _letter = RegExp(r'^[A-HJ-NP-TV-Z]$');

  @override
  PlateValidation judge(PlateEntry entry) {
    if (!isDigitsOfLength(entry.group('number'), 6)) {
      return const PlateValidation.invalid(reasonNumber);
    }
    if (!_letter.hasMatch(entry.group('letter'))) {
      return const PlateValidation.invalid(reasonLetter);
    }
    return const PlateValidation.valid();
  }
}
