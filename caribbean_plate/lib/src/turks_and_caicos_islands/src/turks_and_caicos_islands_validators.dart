import 'package:plate_core/plate_core.dart';

/// Judges a [TurksAndCaicosIslandsPlates.modern] plate: five digits. Reports,
/// never bars a keystroke.
class TurksAndCaicosIslandsValidator extends GatedPlateValidator {
  const TurksAndCaicosIslandsValidator();

  @override
  String get gateGroup => 'serial';

  static const String reasonSerial = 'The number is five digits.';

  @override
  PlateValidation judge(PlateEntry entry) {
    if (!isDigitsOfLength(entry.group('serial'), 5)) {
      return const PlateValidation.invalid(reasonSerial);
    }
    return const PlateValidation.valid();
  }
}

/// Judges a [TurksAndCaicosIslandsPlates.prefixed] or `selfDrive` plate:
/// `TC` and one to five digits.
class TurksAndCaicosIslandsPrefixedValidator extends GatedPlateValidator {
  const TurksAndCaicosIslandsPrefixedValidator();

  @override
  String get gateGroup => 'serial';

  static const String reasonPrefix = 'The plate starts with TC.';
  static const String reasonSerial = 'The number is one to five digits.';

  @override
  PlateValidation judge(PlateEntry entry) {
    if (entry.group('prefix') != 'TC') {
      return const PlateValidation.invalid(reasonPrefix);
    }
    if (!RegExp(r'^[0-9]{1,5}$').hasMatch(entry.group('serial'))) {
      return const PlateValidation.invalid(reasonSerial);
    }
    return const PlateValidation.valid();
  }
}
