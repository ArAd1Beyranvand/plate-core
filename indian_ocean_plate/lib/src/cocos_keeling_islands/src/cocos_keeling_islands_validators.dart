import 'package:plate_core/plate_core.dart';

/// Judges a plate by its groups: `letters` (one, `C`) and `serial` (three
/// digits), `C 400`. Reports, never bars a keystroke.
class CocosKeelingIslandsValidator extends GatedPlateValidator {
  const CocosKeelingIslandsValidator();

  @override
  String get gateGroup => 'serial';

  static const String reasonLetters = 'The register is the letter C.';
  static const String reasonSerial = 'The number is three digits.';

  @override
  PlateValidation judge(PlateEntry entry) {
    final String letters = entry.group('letters');
    if (letters.isNotEmpty && letters != 'C') {
      return const PlateValidation.invalid(reasonLetters);
    }
    if (!isDigitsOfLength(entry.group('serial'), 3)) {
      return const PlateValidation.invalid(reasonSerial);
    }
    return const PlateValidation.valid();
  }
}
