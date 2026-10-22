import 'package:plate_core/plate_core.dart';

/// Judges a St. Eustatius value: the island letter `E` and a number of up to
/// four digits (`E 30`, `E191`). The article says "three or four digits" for
/// the 2007 plate and `E123` for 1976, but the 2007 photo shows two digits,
/// so one to four are accepted; the picture wins. Reports, never bars a
/// keystroke.
class SintEustatiusValidator extends GatedPlateValidator {
  const SintEustatiusValidator();

  @override
  String get gateGroup => 'number';

  static const String reasonPrefix = 'The prefix is E.';
  static const String reasonNumber = 'The number is up to four digits.';

  @override
  PlateValidation judge(PlateEntry entry) {
    if (entry.group('prefix') != 'E') {
      return const PlateValidation.invalid(reasonPrefix);
    }
    final String number = entry.group('number');
    if (number.isEmpty || number.length > 4 || !isDigits(number)) {
      return const PlateValidation.invalid(reasonNumber);
    }
    return const PlateValidation.valid();
  }
}
