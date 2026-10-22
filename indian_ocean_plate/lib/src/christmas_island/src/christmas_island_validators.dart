import 'package:plate_core/plate_core.dart';

/// Judges a `CI•1234` value: a two-letter register then a four-digit serial
/// (leading zeros are printed). Reports, never bars a keystroke.
class ChristmasIslandValidator extends GatedPlateValidator {
  const ChristmasIslandValidator();

  @override
  String get gateGroup => 'serial';

  static const String reasonLetters = 'The register is two letters.';
  static const String reasonSerial = 'The number is four digits.';

  static final RegExp _letters = RegExp(r'^[A-Z]{2}$');

  @override
  PlateValidation judge(PlateEntry entry) {
    if (!_letters.hasMatch(entry.group('letters'))) {
      return const PlateValidation.invalid(reasonLetters);
    }
    if (!isDigitsOfLength(entry.group('serial'), 4)) {
      return const PlateValidation.invalid(reasonSerial);
    }
    return const PlateValidation.valid();
  }
}
