import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, valid } from '../../core/validators/plate_validator';

/** Judges a Montserrat plate: a type letter and one to four digits (`M 1667`).
 * Reports, never bars a keystroke. */
export class MontserratValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonType = 'The type is one letter.';
  static readonly reasonSerial = 'The number is one to four digits.';

  private static readonly _type = new RegExp(String.raw`^[A-Z]$`);
  private static readonly _serial = new RegExp(String.raw`^[0-9]{1,4}$`);

  judge(entry: PlateEntry): PlateValidation {
    if (!MontserratValidator._type.test(entry.group('type'))) {
      return invalid(MontserratValidator.reasonType);
    }
    if (!MontserratValidator._serial.test(entry.group('serial'))) {
      return invalid(MontserratValidator.reasonSerial);
    }
    return valid;
  }
}
