import 'package:plate_core/plate_core.dart';

// TODO(py): [D4-code] hand-port; reason strings are the contract, keep them byte-identical.
// TODO(ts): [D4-code] hand-port; reason strings are the contract, keep them byte-identical.
// TODO(kt): [D4-code] hand-port; reason strings are the contract, keep them byte-identical.
/// Advisory validator for `MalaysiaPlates.singleRow`, `twoRow` and `ev`.
///
/// I and O are never issued; the number runs 1-9999 with no leading zero; a
/// Sabah (`S...`) suffix is never Q or S. The military `Z` is accepted. State
/// letters and vanity series (which break every rule here) are not checked.
class MalaysiaValidator extends GatedPlateValidator {
  const MalaysiaValidator();

  @override
  String get gateGroup => 'number';

  static const String reasonPrefixMissing = 'A plate starts with letters.';
  static const String reasonNoIO =
      'I and O are not issued on Malaysian plates.';
  static const String reasonNumber = 'The number is 1 to 9999.';
  static const String reasonLeadingZero = 'The number has no leading zero.';
  static const String reasonSabahSuffix = 'A Sabah suffix is never Q or S.';

  // TODO(py): [H9] Python re: \d/\w match Unicode; keep explicit [0-9]/[A-Z] classes (or re.ASCII).
  // TODO(ts): [H9] same flavour as Dart; port as is, cover accept/reject in the vectors (D9).
  // TODO(kt): [H9] Regex engine differs per target (JVM/JS/Native): keep to portable syntax.
  static final RegExp _notIssued = RegExp('[IO]');

  @override
  PlateValidation judge(PlateEntry entry) => validateFields(
    prefix: entry.group('prefix'),
    number: entry.group('number'),
    suffix: entry.group('suffix'),
  );

  static PlateValidation validateFields({
    required String prefix,
    required String number,
    String suffix = '',
  }) {
    if (prefix.isEmpty) {
      return const PlateValidation.invalid(reasonPrefixMissing);
    }
    if (_notIssued.hasMatch(prefix + suffix)) {
      return const PlateValidation.invalid(reasonNoIO);
    }
    if (number.isEmpty || number.length > 4 || !isDigits(number)) {
      return const PlateValidation.invalid(reasonNumber);
    }
    if (number.startsWith('0')) {
      return const PlateValidation.invalid(reasonLeadingZero);
    }
    if (prefix.startsWith('S') && (suffix == 'Q' || suffix == 'S')) {
      return const PlateValidation.invalid(reasonSabahSuffix);
    }
    return const PlateValidation.valid();
  }
}

/// Advisory validator for `MalaysiaPlates.diplomatic`: two two-digit numbers
/// and a mission code. No number ranges are documented.
class MalaysiaDiplomaticValidator extends GatedPlateValidator {
  const MalaysiaDiplomaticValidator();

  @override
  String get gateGroup => 'mission';

  static const String reasonDigits = 'Both numbers are two digits.';
  static const String reasonMission = 'The code is DC, CC, UN or PA.';

  static const Set<String> _missions = <String>{'DC', 'CC', 'UN', 'PA'};

  @override
  PlateValidation judge(PlateEntry entry) {
    final String country = entry.group('country');
    final String serial = entry.group('serial');
    if (country.length != 2 ||
        serial.length != 2 ||
        !isDigits(country) ||
        !isDigits(serial)) {
      return const PlateValidation.invalid(reasonDigits);
    }
    if (!_missions.contains(entry.group('mission'))) {
      return const PlateValidation.invalid(reasonMission);
    }
    return const PlateValidation.valid();
  }
}
