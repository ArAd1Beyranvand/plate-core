import 'package:plate_core/plate_core.dart';

/// Advisory validator for the `XX #### XX` format.
class MaliValidator extends GatedPlateValidator {
  const MaliValidator();

  @override
  String get gateGroup => 'suffix';

  static const String reasonFormat =
      'Format is 2 letters, 4 digits, 2 letters.';

  @override
  PlateValidation judge(PlateEntry entry) {
    if (entry.group('prefix').length != 2 ||
        entry.group('number').length != 4 ||
        entry.group('suffix').length != 2) {
      return const PlateValidation.invalid(reasonFormat);
    }
    return const PlateValidation.valid();
  }
}
