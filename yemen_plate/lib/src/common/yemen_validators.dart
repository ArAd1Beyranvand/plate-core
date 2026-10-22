import 'package:plate_core/plate_core.dart';

import 'yemen_governorates.dart';

/// Judges a System A (2026 unified) plate, gated on the side code so it stays
/// quiet until the number is entered. The side code is checked for shape only.
class YemenUnifiedValidator extends GatedPlateValidator {
  const YemenUnifiedValidator();

  @override
  String get gateGroup => 'sideCode';

  static const String reasonNumberNotNumeric = 'The vehicle number is digits only.';

  static const String reasonNumberLength = 'The vehicle number is four to six digits.';

  static const String reasonSideCodeNotNumeric = 'The side code is digits only.';

  static const String reasonSideCodeLength = 'The side code is two digits.';

  static const int minNumberLength = 4;
  static const int maxNumberLength = 6;

  @override
  PlateValidation judge(PlateEntry entry) =>
      validateFields(number: entry.group('number'), sideCode: entry.group('sideCode'));

  // TODO(side-code): no source pins down which digit encodes what; stay opaque.
  static PlateValidation validateFields({required String number, required String sideCode}) {
    if (number.isNotEmpty && !isDigits(number)) {
      return const PlateValidation.invalid(reasonNumberNotNumeric);
    }
    if (number.length < minNumberLength || number.length > maxNumberLength) {
      return const PlateValidation.invalid(reasonNumberLength);
    }

    if (!isDigits(sideCode)) {
      return const PlateValidation.invalid(reasonSideCodeNotNumeric);
    }
    if (sideCode.length != 2) {
      return const PlateValidation.invalid(reasonSideCodeLength);
    }

    return const PlateValidation.valid();
  }
}

/// Judges a System B (1993 northern) plate, gated on the serial. Checks more
/// than [YemenUnifiedValidator] because this grammar is documented: governorate
/// 1..22, serial never zero-padded.
class YemenNorthernValidator extends GatedPlateValidator {
  const YemenNorthernValidator();

  @override
  String get gateGroup => 'serial';

  static const String reasonGovernorateNotNumeric = 'The governorate code is digits only.';

  static const String reasonGovernorateLength = 'The governorate code is one or two digits.';

  static const String reasonGovernorateRange = 'The governorate code is 1 to 22.';

  static const String reasonSerialNotNumeric = 'The serial is digits only.';

  static const String reasonSerialLength = 'The serial is four to six digits.';

  static const String reasonSerialLeadingZero = 'The serial is not padded with leading zeros.';

  static const int minSerialLength = 4;
  static const int maxSerialLength = 6;

  @override
  PlateValidation judge(PlateEntry entry) =>
      validateFields(governorate: entry.group('governorate'), serial: entry.group('serial'));

  /// `'05'` and `'5'` are the same governorate (two-cell padding).
  static PlateValidation validateFields({required String governorate, required String serial}) {
    if (governorate.isEmpty || governorate.length > 2) {
      return const PlateValidation.invalid(reasonGovernorateLength);
    }
    if (!isDigits(governorate)) {
      return const PlateValidation.invalid(reasonGovernorateNotNumeric);
    }
    final int code = int.parse(governorate);
    if (code < YemenGovernorate.minCode || code > YemenGovernorate.maxCode) {
      return const PlateValidation.invalid(reasonGovernorateRange);
    }

    if (serial.length < minSerialLength || serial.length > maxSerialLength) {
      return const PlateValidation.invalid(reasonSerialLength);
    }
    if (!isDigits(serial)) {
      return const PlateValidation.invalid(reasonSerialNotNumeric);
    }
    if (serial.startsWith('0')) {
      return const PlateValidation.invalid(reasonSerialLeadingZero);
    }

    return const PlateValidation.valid();
  }
}

/// Judges a southern plate's number: the strip plates of Hadhramaut, Al Mahrah,
/// Shabwah and Marib, Aden's and Taiz's. Gated on the serial. The artwork shows
/// three to five digits; nothing more of the grammar is published.
class YemenSouthernValidator extends GatedPlateValidator {
  const YemenSouthernValidator();

  @override
  String get gateGroup => 'serial';

  static const String reasonSerialNotNumeric = 'The number is digits only.';

  static const String reasonSerialLength = 'The number is three to five digits.';

  static const int minSerialLength = 3;
  static const int maxSerialLength = 5;

  @override
  PlateValidation judge(PlateEntry entry) => validateFields(serial: entry.group('serial'));

  static PlateValidation validateFields({required String serial}) {
    if (serial.length < minSerialLength || serial.length > maxSerialLength) {
      return const PlateValidation.invalid(reasonSerialLength);
    }
    if (!isDigits(serial)) {
      return const PlateValidation.invalid(reasonSerialNotNumeric);
    }
    return const PlateValidation.valid();
  }
}
