import 'package:plate_core/plate_core.dart';

/// Judges a `SintMaartenPlates.private` value: a one- or two-letter type
/// prefix and up to four digits (`P 2404`, `TX 123`). Reports, never bars a
/// keystroke.
class SintMaartenValidator extends GatedPlateValidator {
  const SintMaartenValidator();

  @override
  String get gateGroup => 'number';

  static final RegExp _prefix = RegExp(r'^[A-Z]{1,2}$');

  static const String reasonPrefix = 'The prefix is one or two letters.';
  static const String reasonNumber = 'The number is up to four digits.';

  @override
  PlateValidation judge(PlateEntry entry) {
    if (!_prefix.hasMatch(entry.group('prefix'))) {
      return const PlateValidation.invalid(reasonPrefix);
    }
    final String number = entry.group('number');
    if (number.isEmpty || number.length > 4 || !isDigits(number)) {
      return const PlateValidation.invalid(reasonNumber);
    }
    return const PlateValidation.valid();
  }
}
