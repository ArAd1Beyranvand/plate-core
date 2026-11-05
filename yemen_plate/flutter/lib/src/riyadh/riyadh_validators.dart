import 'package:plate_core/plate_core.dart';

/// Judges a Riyadh plate: three letters from the seventeen issued and one to
/// four digits. The combinations banned since 2009 are not checked; only
/// examples are published, not the list.
class RiyadhValidator extends GatedPlateValidator {
  const RiyadhValidator() : super('serial');

  static const String reasonLetters = 'The register is three letters.';
  static const String reasonSerial = 'The number is one to four digits.';

  static final RegExp _letters = RegExp(r'^[ABJDRSXTEGKLZNHUV]{3}$');

  @override
  PlateValidation judge(PlateEntry entry) {
    if (!_letters.hasMatch(entry.group('letters'))) {
      return const PlateValidation.invalid(reasonLetters);
    }
    final String serial = entry.group('serial');
    if (!isDigits(serial) || serial.length > 4) {
      return const PlateValidation.invalid(reasonSerial);
    }
    return const PlateValidation.valid();
  }
}
