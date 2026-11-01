import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigits, valid } from '../../core/validators/plate_validator';

/** Judges an `AnguillaPlates.private` value: a vehicle-type letter and one to
 * four digits (`A 1234`). The article names only `A` and `P` (personal) for
 * the letter, so any capital passes. Reports, never bars a keystroke. */
export class AnguillaValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly maxDigits = 4;

  static readonly reasonType = 'The plate starts with a type letter.';

  static readonly reasonSerial = 'The serial is one to four digits.';

  judge(entry: PlateEntry): PlateValidation {
    return AnguillaValidator.validateFields({
      type: entry.group('type'),
      serial: entry.group('serial'),
    });
  }

  static validateFields({ type, serial }: { type: string; serial: string }): PlateValidation {
    if (!new RegExp(String.raw`^[A-Z]$`).test(type)) {
      return invalid(AnguillaValidator.reasonType);
    }
    if (!isDigits(serial) || serial.length > AnguillaValidator.maxDigits) {
      return invalid(AnguillaValidator.reasonSerial);
    }
    return valid;
  }
}
