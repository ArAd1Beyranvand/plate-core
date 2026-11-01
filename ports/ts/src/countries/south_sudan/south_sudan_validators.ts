import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** Judges a 2017 plate: three digits, then one or two letters (`560 AT`). Reports, never bars a keystroke. */
export class SouthSudanValidator extends GatedPlateValidator {
  readonly gateGroup = 'letters';

  static readonly reasonSerial = 'The number is three digits.';
  static readonly reasonLetters = 'The register is one or two letters.';

  private static readonly _letters = new RegExp('^[A-Z]{1,2}$');

  judge(entry: PlateEntry): PlateValidation {
    if (!isDigitsOfLength(entry.group('serial'), 3)) {
      return invalid(SouthSudanValidator.reasonSerial);
    }
    if (!SouthSudanValidator._letters.test(entry.group('letters'))) {
      return invalid(SouthSudanValidator.reasonLetters);
    }
    return valid;
  }
}
