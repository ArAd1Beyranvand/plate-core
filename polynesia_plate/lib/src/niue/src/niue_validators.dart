import 'package:plate_core/plate_core.dart';

/// Judges a plate: four digits (`1234`). Reports, never bars a keystroke.
class NiueValidator extends GatedPlateValidator {
  const NiueValidator();

  @override
  String get gateGroup => 'serial';

  static const String reasonSerial = 'The number is four digits.';

  @override
  PlateValidation judge(PlateEntry entry) => isDigitsOfLength(entry.group('serial'), 4)
      ? const PlateValidation.valid()
      : const PlateValidation.invalid(reasonSerial);
}
