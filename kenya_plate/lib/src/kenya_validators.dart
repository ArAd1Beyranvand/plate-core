import 'package:plate_core/plate_core.dart';

import 'kenya_missions.dart';

final RegExp _threeLetters = RegExp(r'^[A-Z]{3}$');
final RegExp _oneLetter = RegExp(r'^[A-Z]$');
final RegExp _twoLetters = RegExp(r'^[A-Z]{2}$');
final RegExp _oneToThreeDigits = RegExp(r'^[0-9]{1,3}$');

/// Judges a 2022 plate (`KDK 101A`). Reports, never bars a keystroke.
class KenyaValidator extends GatedPlateValidator {
  const KenyaValidator();

  @override
  String get gateGroup => 'suffix';

  static const String reasonLetters = 'The register is three letters.';
  static const String reasonDigits = 'The number is three digits.';
  static const String reasonSuffix = 'The number ends in a letter.';

  @override
  PlateValidation judge(PlateEntry entry) {
    if (!_threeLetters.hasMatch(entry.group('letters'))) {
      return const PlateValidation.invalid(reasonLetters);
    }
    if (!isDigitsOfLength(entry.group('digits'), 3)) {
      return const PlateValidation.invalid(reasonDigits);
    }
    if (!_oneLetter.hasMatch(entry.group('suffix'))) {
      return const PlateValidation.invalid(reasonSuffix);
    }
    return const PlateValidation.valid();
  }
}

/// Judges a diplomatic plate (`1 CD 1 AK`): one to three digits, `CD` or `UN`,
/// one to three digits and two letters. Refuses mission `24` on its own
/// account as well, so it holds even against a spec built without
/// [KenyaMissions.restriction].
class KenyaDiplomaticValidator extends GatedPlateValidator {
  const KenyaDiplomaticValidator();

  @override
  String get gateGroup => 'letters';

  static const String reasonMission = 'The mission is one to three digits.';
  static const String reasonType = 'Pick CD or UN.';
  static const String reasonDigits = 'The serial is one to three digits.';
  static const String reasonLetters = 'The register is two letters.';

  @override
  PlateValidation validate(PlateEntry entry) {
    if (KenyaMissions.isRefused(entry.group('mission'))) {
      return const PlateValidation.invalid(KenyaMissions.notFound);
    }
    return super.validate(entry);
  }

  @override
  PlateValidation judge(PlateEntry entry) {
    if (!_oneToThreeDigits.hasMatch(entry.group('mission'))) {
      return const PlateValidation.invalid(reasonMission);
    }
    if (entry.group('type').isEmpty) {
      return const PlateValidation.invalid(reasonType);
    }
    if (!_oneToThreeDigits.hasMatch(entry.group('digits'))) {
      return const PlateValidation.invalid(reasonDigits);
    }
    if (!_twoLetters.hasMatch(entry.group('letters'))) {
      return const PlateValidation.invalid(reasonLetters);
    }
    return const PlateValidation.valid();
  }
}
