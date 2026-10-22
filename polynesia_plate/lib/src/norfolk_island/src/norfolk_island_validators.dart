import 'package:plate_core/plate_core.dart';

/// Judges a `3◆203` value: a block digit 1 to 7, then three digits (leading
/// zeros are printed; cancelled blocks were reissued from 000). Reports,
/// never bars a keystroke.
class NorfolkIslandValidator extends GatedPlateValidator {
  const NorfolkIslandValidator();

  @override
  String get gateGroup => 'block';

  static const String reasonBlock = 'The block is a digit from 1 to 7.';
  static const String reasonSerial = 'The number is three digits.';

  static final RegExp _block = RegExp(r'^[1-7]$');

  @override
  PlateValidation judge(PlateEntry entry) {
    if (!_block.hasMatch(entry.group('block'))) {
      return const PlateValidation.invalid(reasonBlock);
    }
    if (!isDigitsOfLength(entry.group('serial'), 3)) {
      return const PlateValidation.invalid(reasonSerial);
    }
    return const PlateValidation.valid();
  }
}
