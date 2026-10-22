import 'package:plate_core/plate_core.dart';

/// Judges a `BermudaPlates.private` value: five digits. Reports, never bars a
/// keystroke.
class BermudaValidator extends GatedPlateValidator {
  const BermudaValidator();

  @override
  String get gateGroup => 'serial';

  static const String reasonSerial = 'The number is five digits.';

  @override
  PlateValidation judge(PlateEntry entry) => isDigitsOfLength(entry.group('serial'), 5)
      ? const PlateValidation.valid()
      : const PlateValidation.invalid(reasonSerial);
}

/// Judges a `BermudaPlates.prefixed` value: one to three letters, then three
/// or four digits (`L1234`, `CL123`, `RMC001`).
class BermudaPrefixedValidator extends GatedPlateValidator {
  const BermudaPrefixedValidator();

  @override
  String get gateGroup => 'serial';

  static const String reasonLetters = 'The class prefix is one to three letters.';
  static const String reasonSerial = 'The number is three or four digits.';

  @override
  PlateValidation judge(PlateEntry entry) {
    if (!RegExp(r'^[A-Z]{1,3}$').hasMatch(entry.group('letters'))) {
      return const PlateValidation.invalid(reasonLetters);
    }
    if (!RegExp(r'^[0-9]{3,4}$').hasMatch(entry.group('serial'))) {
      return const PlateValidation.invalid(reasonSerial);
    }
    return const PlateValidation.valid();
  }
}

/// Judges a `BermudaPlates.suffixed` value: three digits and a letter
/// (`123Y`).
class BermudaSuffixedValidator extends GatedPlateValidator {
  const BermudaSuffixedValidator();

  @override
  String get gateGroup => 'letter';

  static const String reasonSerial = 'The number is three digits.';
  static const String reasonLetter = 'The suffix is one letter.';

  @override
  PlateValidation judge(PlateEntry entry) {
    if (!isDigitsOfLength(entry.group('serial'), 3)) {
      return const PlateValidation.invalid(reasonSerial);
    }
    if (!RegExp(r'^[A-Z]$').hasMatch(entry.group('letter'))) {
      return const PlateValidation.invalid(reasonLetter);
    }
    return const PlateValidation.valid();
  }
}
