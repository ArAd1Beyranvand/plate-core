import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** Judges a plate: four digits (`1234`). Reports, never bars a keystroke. */
export class NiueValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonSerial = 'The number is four digits.';

  judge(entry: PlateEntry): PlateValidation {
    return isDigitsOfLength(entry.group('serial'), 4) ? valid : invalid(NiueValidator.reasonSerial);
  }
}
