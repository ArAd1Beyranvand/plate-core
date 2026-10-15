import 'package:plate_core/plate_core.dart';

/// Judges an Eritrean registration: `ER`, a digit in the disc and a five
/// digit number (`ER – 3  01860`). The article has no format table, so this
/// is the one reference plate; it reports and never bars a keystroke.
class EritreaValidator extends GatedPlateValidator {
  const EritreaValidator();

  @override
  String get gateGroup => 'number';

  static const String reasonCode = 'The disc holds one digit.';
  static const String reasonNumber = 'The number is five digits.';

  @override
  PlateValidation judge(PlateEntry entry) {
    if (!isDigitsOfLength(entry.group('code'), 1)) {
      return const PlateValidation.invalid(reasonCode);
    }
    if (!isDigitsOfLength(entry.group('number'), 5)) {
      return const PlateValidation.invalid(reasonNumber);
    }
    return const PlateValidation.valid();
  }
}
