import 'package:plate_core/plate_core.dart';

import 'sudan_alphabets.dart';

// TODO(py): [D4-code] hand-port; reason strings are the contract, keep them byte-identical.
// TODO(ts): [D4-code] hand-port; reason strings are the contract, keep them byte-identical.
// TODO(kt): [D4-code] hand-port; reason strings are the contract, keep them byte-identical.
/// Judges a `SudanPlates` value. Reports, never bars a keystroke.
///
/// A single class digit (its meaning is undocumented and is not the usage), a
/// state code, and a serial of four or five digits.
class SudanValidator extends GatedPlateValidator {
  const SudanValidator();

  @override
  String get gateGroup => 'serial';

  static const String reasonClass = 'The class is one digit.';
  static const String reasonState = 'Unknown state code.';
  static const String reasonSerial = 'The serial is four or five digits.';

  @override
  PlateValidation judge(PlateEntry entry) => validateFields(
    classDigit: entry.group('class'),
    state: entry.group('state'),
    serial: entry.group('serial'),
  );

  static PlateValidation validateFields({
    required String classDigit,
    required String state,
    required String serial,
  }) {
    if (!isDigitsOfLength(classDigit, 1)) {
      return const PlateValidation.invalid(reasonClass);
    }
    if (!SudanAlphabets.stateLatin.characters.contains(state)) {
      return const PlateValidation.invalid(reasonState);
    }
    if (!isDigitsOfLength(serial, 4) && !isDigitsOfLength(serial, 5)) {
      return const PlateValidation.invalid(reasonSerial);
    }
    return const PlateValidation.valid();
  }
}
