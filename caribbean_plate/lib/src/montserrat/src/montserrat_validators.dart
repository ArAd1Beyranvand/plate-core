import 'package:plate_core/plate_core.dart';

/// Judges a Montserrat plate: a type letter and one to four digits (`M 1667`).
/// Reports, never bars a keystroke.
class MontserratValidator extends GatedPlateValidator {
  const MontserratValidator();

  @override
  String get gateGroup => 'serial';

  static const String reasonType = 'The type is one letter.';
  static const String reasonSerial = 'The number is one to four digits.';

  static final RegExp _type = RegExp(r'^[A-Z]$');
  static final RegExp _serial = RegExp(r'^[0-9]{1,4}$');

  @override
  PlateValidation judge(PlateEntry entry) {
    if (!_type.hasMatch(entry.group('type'))) {
      return const PlateValidation.invalid(reasonType);
    }
    if (!_serial.hasMatch(entry.group('serial'))) {
      return const PlateValidation.invalid(reasonSerial);
    }
    return const PlateValidation.valid();
  }
}
