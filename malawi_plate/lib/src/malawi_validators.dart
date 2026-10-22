import 'package:plate_core/plate_core.dart';

/// Judges a Malawian plate: two letters and four digits (`BC 5049`). Reports,
/// never bars a keystroke.
class MalawiValidator extends GatedPlateValidator {
  const MalawiValidator();

  @override
  String get gateGroup => 'serial';

  static const String reasonLetters = 'The register is two letters.';
  static const String reasonSerial = 'The number is four digits.';

  @override
  PlateValidation judge(PlateEntry entry) {
    if (!RegExp(r'^[A-Z]{2}$').hasMatch(entry.group('letters'))) {
      return const PlateValidation.invalid(reasonLetters);
    }
    if (!isDigitsOfLength(entry.group('serial'), 4)) {
      return const PlateValidation.invalid(reasonSerial);
    }
    return const PlateValidation.valid();
  }
}
