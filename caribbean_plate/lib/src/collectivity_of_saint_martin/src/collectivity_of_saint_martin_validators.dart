import 'package:plate_core/plate_core.dart';

/// Judges a Saint Martin plate: three or four digits, then two or three
/// letters (`1234-ABC`, `123-AB`). The letters leave out I, O, U and the SS
/// pair. Reports, never bars a keystroke.
class CollectivityOfSaintMartinValidator extends GatedPlateValidator {
  const CollectivityOfSaintMartinValidator();

  @override
  String get gateGroup => 'letters';

  static const String reasonNumber = 'The number is three or four digits.';
  static const String reasonLetters = 'The letters are two or three (no I, O, U or SS).';

  static final RegExp _number = RegExp(r'^\d{3,4}$');
  static final RegExp _letters = RegExp(r'^[A-HJ-NP-TV-Z]{2,3}$');

  @override
  PlateValidation judge(PlateEntry entry) {
    if (!_number.hasMatch(entry.group('number'))) {
      return const PlateValidation.invalid(reasonNumber);
    }
    final String letters = entry.group('letters');
    if (!_letters.hasMatch(letters) || letters.contains('SS')) {
      return const PlateValidation.invalid(reasonLetters);
    }
    return const PlateValidation.valid();
  }
}
