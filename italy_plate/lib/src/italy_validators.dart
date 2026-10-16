import 'package:plate_core/plate_core.dart';

/// Judges an Italian plate: two letters, three digits and two letters on a car
/// (`AA 000 AA`), or two letters and five digits on a motorcycle. The letters
/// leave out I, O, Q and U. Reports, never bars a keystroke.
class ItalyValidator extends GatedPlateValidator {
  const ItalyValidator();

  @override
  String get gateGroup => 'number';

  static const String reasonPrefix =
      'The prefix is two letters (no I, O, Q, U).';
  static const String reasonNumber =
      'The number is three digits, or five on a motorcycle.';
  static const String reasonSuffix =
      'The suffix is two letters (no I, O, Q, U).';

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
