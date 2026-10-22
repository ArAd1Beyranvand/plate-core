import 'package:plate_core/plate_core.dart';

/// Judges a Saba value: one prefix letter and a run of digits. The 2011 plate
/// is `S 240` (three or four digits; the article's `R` and `D` prefixes mark
/// other vehicle types), the 1978 plate `S-163` (up to three). Reports, never
/// bars a keystroke.
class SabaIslandValidator extends GatedPlateValidator {
  const SabaIslandValidator({this.minDigits = 3, this.maxDigits = 4});

  /// The 1978 plate: `S-123`, one to three digits.
  const SabaIslandValidator.classic1978() : this(minDigits: 1, maxDigits: 3);

  final int minDigits;
  final int maxDigits;

  @override
  String get gateGroup => 'number';

  static final RegExp _prefix = RegExp(r'^[SRD]$');

  static const String reasonPrefix = 'The prefix is S, R or D.';

  String get reasonNumber => minDigits == maxDigits
      ? 'The number is $maxDigits digits.'
      : 'The number is $minDigits to $maxDigits digits.';

  @override
  PlateValidation judge(PlateEntry entry) {
    if (!_prefix.hasMatch(entry.group('prefix'))) {
      return const PlateValidation.invalid(reasonPrefix);
    }
    final String number = entry.group('number');
    if (number.length < minDigits || number.length > maxDigits || !isDigits(number)) {
      return PlateValidation.invalid(reasonNumber);
    }
    return const PlateValidation.valid();
  }
}
