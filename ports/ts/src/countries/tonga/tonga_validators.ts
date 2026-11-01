import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, valid } from '../../core/validators/plate_validator';

/** Judges a plate: a vehicle-type letter (two for `MC`) and one to five digits
 * (`C 12345`). Reports, never bars a keystroke. */
export class TongaValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonLetters = 'The register is one or two letters.';
  static readonly reasonSerial = 'The number is one to five digits.';

  judge(entry: PlateEntry): PlateValidation {
    if (!/^[A-Z]{1,2}$/.test(entry.group('letters')!)) {
      return invalid(TongaValidator.reasonLetters);
    }
    if (!/^[0-9]{1,5}$/.test(entry.group('serial')!)) {
      return invalid(TongaValidator.reasonSerial);
    }
    return valid;
  }
}
