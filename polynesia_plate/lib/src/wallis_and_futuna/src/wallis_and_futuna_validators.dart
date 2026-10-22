import 'package:plate_core/plate_core.dart';

/// Judges a Wallis and Futuna plate: a four-digit serial followed by the
/// printed `WF`. Reports, never bars a keystroke.
class WallisAndFutunaValidator extends GatedPlateValidator {
  const WallisAndFutunaValidator();

  @override
  String get gateGroup => 'number';

  static const String reasonNumber = 'The serial is four digits.';

  @override
  PlateValidation judge(PlateEntry entry) {
    if (!isDigitsOfLength(entry.group('number'), 4)) {
      return const PlateValidation.invalid(reasonNumber);
    }
    return const PlateValidation.valid();
  }
}
