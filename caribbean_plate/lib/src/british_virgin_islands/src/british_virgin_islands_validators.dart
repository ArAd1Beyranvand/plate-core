import 'package:plate_core/plate_core.dart';

/// Judges a Virgin Islands plate: a class prefix and a serial. `PV` takes five
/// digits, `TAXI` three, every other two-letter prefix (`GV`, `CM`, `TX`,
/// `RT`) four. Reports, never bars a keystroke.
class BritishVirginIslandsValidator extends GatedPlateValidator {
  const BritishVirginIslandsValidator();

  @override
  String get gateGroup => 'serial';

  static const String reasonPrefix = 'The plate starts with a class prefix: two letters, or TAXI.';
  static const String reasonSerial = 'The serial has the wrong digit count.';

  @override
  PlateValidation judge(PlateEntry entry) =>
      validateFields(prefix: entry.group('prefix'), serial: entry.group('serial'));

  static int digitsFor(String prefix) => switch (prefix) {
    'PV' => 5,
    'TAXI' => 3,
    _ => 4,
  };

  static PlateValidation validateFields({required String prefix, required String serial}) {
    if (!RegExp(r'^([A-Z]{2}|TAXI)$').hasMatch(prefix)) {
      return const PlateValidation.invalid(reasonPrefix);
    }
    if (!isDigitsOfLength(serial, digitsFor(prefix))) {
      return const PlateValidation.invalid(reasonSerial);
    }
    return const PlateValidation.valid();
  }
}
