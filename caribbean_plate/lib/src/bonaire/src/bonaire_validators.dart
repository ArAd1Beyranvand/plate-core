import 'package:plate_core/plate_core.dart';

/// Judges a `BonairePlates.bonaire` or `.blue` value: a one- or two-letter
/// type prefix and three to five digits (`V-5169`, `MF-630`). Reports, never
/// bars a keystroke.
class BonaireValidator extends GatedPlateValidator {
  const BonaireValidator();

  @override
  String get gateGroup => 'number';

  static final RegExp _prefix = RegExp(r'^[A-Z]{1,2}$');

  static const String reasonPrefix = 'The prefix is one or two letters.';
  static const String reasonNumber = 'The number is three to five digits.';

  @override
  PlateValidation judge(PlateEntry entry) {
    if (!_prefix.hasMatch(entry.group('prefix'))) {
      return const PlateValidation.invalid(reasonPrefix);
    }
    final String number = entry.group('number');
    if (number.length < 3 || number.length > 5 || !isDigits(number)) {
      return const PlateValidation.invalid(reasonNumber);
    }
    return const PlateValidation.valid();
  }
}

/// Judges a St. Eustatius or Saba value: the island letter (`E` or `S`) and
/// up to four digits. The St. Eustatius photo shows two digits (`E 30`); the
/// picture wins over the article's "three or four", so one is accepted there.
class BonaireIslandValidator extends GatedPlateValidator {
  const BonaireIslandValidator({required this.island, this.minDigits = 1});

  final String island;
  final int minDigits;

  @override
  String get gateGroup => 'number';

  static const String reasonNumber = 'The number is up to four digits.';

  String get reasonIsland => 'The prefix is $island.';

  @override
  PlateValidation judge(PlateEntry entry) {
    if (entry.group('prefix') != island) {
      return PlateValidation.invalid(reasonIsland);
    }
    final String number = entry.group('number');
    if (number.length < minDigits || number.length > 4 || !isDigits(number)) {
      return const PlateValidation.invalid(reasonNumber);
    }
    return const PlateValidation.valid();
  }
}
