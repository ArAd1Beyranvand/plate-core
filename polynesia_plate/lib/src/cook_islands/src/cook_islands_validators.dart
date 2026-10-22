import 'package:plate_core/plate_core.dart';

/// Judges a plate: four digits (car, `1234`) or three letters over three
/// digits (motorcycle, `AAP 676`). Reports, never bars a keystroke.
class CookIslandsValidator extends GatedPlateValidator {
  const CookIslandsValidator();

  @override
  String get gateGroup => 'serial';

  static const String reasonCar = 'The number is four digits.';
  static const String reasonLetters = 'The register is three letters.';
  static const String reasonMotorcycle = 'The number is three digits.';

  @override
  PlateValidation judge(PlateEntry entry) {
    final String letters = entry.group('letters');
    final String serial = entry.group('serial');
    if (entry.spec.slots.length == 1) {
      return isDigitsOfLength(serial, 4)
          ? const PlateValidation.valid()
          : const PlateValidation.invalid(reasonCar);
    }
    if (!RegExp(r'^[A-Z]{3}$').hasMatch(letters)) {
      return const PlateValidation.invalid(reasonLetters);
    }
    if (!isDigitsOfLength(serial, 3)) {
      return const PlateValidation.invalid(reasonMotorcycle);
    }
    return const PlateValidation.valid();
  }
}
