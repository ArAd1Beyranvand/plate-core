import 'package:plate_core/plate_core.dart';

/// Judges an Italian plate: two letters, three digits and two letters on a car
/// (`AA 000 AA`), or two letters and five digits on a motorcycle. The letters
/// leave out I, O, Q and U. Reports, never bars a keystroke.
class ItalyValidator extends GatedPlateValidator {
  const ItalyValidator();

  @override
  String get gateGroup => 'number';

  static const String reasonPrefix = 'The prefix is two letters (no I, O, Q, U).';
  static const String reasonNumber = 'The number is three digits, or five on a motorcycle.';
  static const String reasonSuffix = 'The suffix is two letters (no I, O, Q, U).';

  static final RegExp _letters = RegExp(r'^[A-HJ-NP-TV-Z]{2}$');

  @override
  PlateValidation judge(PlateEntry entry) {
    if (!_letters.hasMatch(entry.group('prefix'))) {
      return const PlateValidation.invalid(reasonPrefix);
    }
    final String suffix = entry.group('suffix');
    final String number = entry.group('number');
    if (!isDigitsOfLength(number, suffix.isEmpty ? 5 : 3)) {
      return const PlateValidation.invalid(reasonNumber);
    }
    if (suffix.isNotEmpty && !_letters.hasMatch(suffix)) {
      return const PlateValidation.invalid(reasonSuffix);
    }
    return const PlateValidation.valid();
  }
}

/// Judges a diplomatic, consular or United Nations plate: a country code of
/// two letters and a number of four digits (`CD`, `CC`) or three (`UN`, `UNP`,
/// `UNT`). `Q` and `V` are not used on consular plates. Reports, never bars a
/// keystroke, except for the spec's restrictions.
class ItalyDiplomaticValidator extends GatedPlateValidator {
  const ItalyDiplomaticValidator({this.digits = 4, this.consular = false});

  final int digits;
  final bool consular;

  @override
  String get gateGroup => 'number';

  static const String reasonNumber = 'The number is three or four digits.';
  static const String reasonCode = 'The country code is two letters.';
  static const String reasonConsular = 'Consular codes leave out Q and V.';

  static final RegExp _code = RegExp(r'^[A-Z]{2}$');

  @override
  PlateValidation judge(PlateEntry entry) {
    if (!isDigitsOfLength(entry.group('number'), digits)) {
      return const PlateValidation.invalid(reasonNumber);
    }
    final String code = entry.group('code');
    if (!_code.hasMatch(code)) {
      return const PlateValidation.invalid(reasonCode);
    }
    if (consular && (code.contains('Q') || code.contains('V'))) {
      return const PlateValidation.invalid(reasonConsular);
    }
    return const PlateValidation.valid();
  }
}
