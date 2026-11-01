import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** Judges a plate: two letters, the first always `P`, and four digits (`PA 1234`). Reports, never bars a keystroke. */
export class SurinameValidator extends GatedPlateValidator {
  readonly _letters = new RegExp('^P[A-Z]$');

  readonly gateGroup = 'serial';

  static readonly reasonLetters = 'The register is two letters, the first one P.';

  static readonly reasonSerial = 'The number is four digits.';

  judge(entry: PlateEntry): PlateValidation {
    if (!this._letters.test(entry.group('letters'))) {
      return invalid(SurinameValidator.reasonLetters);
    }
    if (!isDigitsOfLength(entry.group('serial'), 4)) {
      return invalid(SurinameValidator.reasonSerial);
    }
    return valid;
  }
}
