import 'package:plate_core/plate_core.dart';

/// Judges a 2006 plate: three letters and four digits (`ABC 1234`). Reports,
/// never bars a keystroke.
class ZimbabweValidator extends GatedPlateValidator {
  const ZimbabweValidator();

  @override
  String get gateGroup => 'serial';

  static const String reasonLetters = 'The register is three letters.';
  static const String reasonSerial = 'The number is four digits.';

  @override
  PlateValidation judge(PlateEntry entry) {
    final String letters = entry.group('letters');
    if (letters.length != 3 || !RegExp(r'^[A-Z]{3}$').hasMatch(letters)) {
      return const PlateValidation.invalid(reasonLetters);
    }
    if (!isDigitsOfLength(entry.group('serial'), 4)) {
      return const PlateValidation.invalid(reasonSerial);
    }
    return const PlateValidation.valid();
  }
}
