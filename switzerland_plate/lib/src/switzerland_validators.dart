import 'package:plate_core/plate_core.dart';

import 'switzerland_missions.dart';

/// The 26 cantons' two-letter codes.
const List<String> switzerlandCantons = <String>[
  'AG',
  'AI',
  'AR',
  'BE',
  'BL',
  'BS',
  'FR',
  'GE',
  'GL',
  'GR',
  'JU',
  'LU',
  'NE',
  'NW',
  'OW',
  'SG',
  'SH',
  'SO',
  'SZ',
  'TG',
  'TI',
  'UR',
  'VD',
  'VS',
  'ZG',
  'ZH',
];

bool _isPlain(String s) => isDigits(s) && !s.startsWith('0');

/// Judges a canton-and-number plate (`SwitzerlandPlates.high`, `long`,
/// `front`, `dealer`, `temporary`, `customs`, `motorcycle`, `scooter`).
/// Reports, never bars a keystroke; gated on the number.
///
/// The canton is one of [switzerlandCantons] (a [military] plate may instead
/// open with a lone `M`), and the number is digits with no leading zero, at
/// most as long as the number slot. The registry also issues no number 0.
class SwitzerlandValidator extends GatedPlateValidator {
  const SwitzerlandValidator({this.military = false});

  /// Whether a lone `M` is a legal canton field.
  final bool military;

  @override
  String get gateGroup => 'number';

  static const String reasonCanton = 'The canton is a Swiss canton code.';
  static const String reasonNumber = 'The number is digits without a leading 0.';

  @override
  PlateValidation judge(PlateEntry entry) {
    final String canton = entry.group('canton');
    if (!switzerlandCantons.contains(canton) && !(military && canton == 'M')) {
      return const PlateValidation.invalid(reasonCanton);
    }
    final String number = entry.group('number');
    if (!_isPlain(number)) {
      return const PlateValidation.invalid(reasonNumber);
    }
    return const PlateValidation.valid();
  }
}

/// Judges a `SwitzerlandPlates.diplomatic` or `consular` value: a canton, a
/// serial and a country code, none with a leading zero. Code 7 is refused on
/// its own account as well, so it holds even against a spec built without
/// [SwitzerlandMissions.restriction].
class SwitzerlandDiplomaticValidator extends GatedPlateValidator {
  const SwitzerlandDiplomaticValidator();

  @override
  String get gateGroup => 'code';

  static const String reasonSerial = 'The serial is one to three digits.';
  static const String reasonCode = 'The code is one to three digits.';

  @override
  PlateValidation validate(PlateEntry entry) {
    if (SwitzerlandMissions.isRefused(entry.group('code'))) {
      return const PlateValidation.invalid(SwitzerlandMissions.notFound);
    }
    return super.validate(entry);
  }

  @override
  PlateValidation judge(PlateEntry entry) {
    if (!switzerlandCantons.contains(entry.group('canton'))) {
      return const PlateValidation.invalid(SwitzerlandValidator.reasonCanton);
    }
    final String serial = entry.group('serial');
    if (!_isPlain(serial)) {
      return const PlateValidation.invalid(reasonSerial);
    }
    final String code = entry.group('code');
    if (!_isPlain(code)) {
      return const PlateValidation.invalid(reasonCode);
    }
    return const PlateValidation.valid();
  }
}
