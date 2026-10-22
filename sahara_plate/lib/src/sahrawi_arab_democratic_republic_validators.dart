import 'package:plate_core/plate_core.dart';

/// Judges a plate by its fields: `SH` or `GSH`, two digits and five digits, or
/// nine digits on the army plate. Reports, never bars a keystroke.
class SahrawiArabDemocraticRepublicValidator extends GatedPlateValidator {
  const SahrawiArabDemocraticRepublicValidator();

  @override
  String get gateGroup => 'serial';

  static const String reasonCivil = 'A plate is SH or GSH, two digits and five digits.';
  static const String reasonArmy = 'An army plate is nine digits.';

  @override
  PlateValidation judge(PlateEntry entry) {
    final String serial = entry.group('serial');
    if (entry.spec.indicesOfGroup('prefix').isEmpty) {
      return isDigitsOfLength(serial, 9)
          ? const PlateValidation.valid()
          : const PlateValidation.invalid(reasonArmy);
    }
    final String prefix = entry.group('prefix');
    return (prefix == 'SH' || prefix == 'GSH') &&
            isDigitsOfLength(entry.group('code'), 2) &&
            isDigitsOfLength(serial, 5)
        ? const PlateValidation.valid()
        : const PlateValidation.invalid(reasonCivil);
  }
}
