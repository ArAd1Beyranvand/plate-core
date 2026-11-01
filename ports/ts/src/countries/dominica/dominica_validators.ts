import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** Requires exactly three digits. Reports, never bars a keystroke. */
export class DominicaValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonSerial = 'The number is three digits.';

  judge(entry: PlateEntry): PlateValidation {
    return isDigitsOfLength(entry.group('serial'), 3) ? valid : invalid(DominicaValidator.reasonSerial);
  }
}
