import 'package:plate_core/plate_core.dart';

/// Judges an `AnguillaPlates.private` value: a vehicle-type letter and one to
/// four digits (`A 1234`). The article names only `A` and `P` (personal) for
/// the letter, so any capital passes. Reports, never bars a keystroke.
class AnguillaValidator extends GatedPlateValidator {
  const AnguillaValidator();

  @override
  String get gateGroup => 'serial';

  static const int maxDigits = 4;

  static const String reasonType = 'The plate starts with a type letter.';
  static const String reasonSerial = 'The serial is one to four digits.';

  @override
  PlateValidation judge(PlateEntry entry) =>
      validateFields(type: entry.group('type'), serial: entry.group('serial'));

  static PlateValidation validateFields({required String type, required String serial}) {
    if (!RegExp(r'^[A-Z]$').hasMatch(type)) {
      return const PlateValidation.invalid(reasonType);
    }
    if (!isDigits(serial) || serial.length > maxDigits) {
      return const PlateValidation.invalid(reasonSerial);
    }
    return const PlateValidation.valid();
  }
}
