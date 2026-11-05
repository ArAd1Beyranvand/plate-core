import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from 'plate_core/core/validators/plate_validator';

/** State codes seen on a 2009-series plate, Latin as printed on the lower row. */
const stateLatin = ['KH', 'G', 'RS'];

/** Judges a `SudanPlates` value. Reports, never bars a keystroke.
 *
 * A single class digit (its meaning is undocumented and is not the usage), a
 * state code, and a serial of four or five digits. */
export class SudanValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonClass = 'The class is one digit.';
  static readonly reasonState = 'Unknown state code.';
  static readonly reasonSerial = 'The serial is four or five digits.';

  judge(entry: PlateEntry): PlateValidation {
    return SudanValidator.validateFields({
      classDigit: entry.group('class'),
      state: entry.group('state'),
      serial: entry.group('serial'),
    });
  }

  static validateFields(f: { classDigit: string; state: string; serial: string }): PlateValidation {
    if (!isDigitsOfLength(f.classDigit, 1)) {
      return invalid(SudanValidator.reasonClass);
    }
    if (!stateLatin.includes(f.state)) {
      return invalid(SudanValidator.reasonState);
    }
    if (!isDigitsOfLength(f.serial, 4) && !isDigitsOfLength(f.serial, 5)) {
      return invalid(SudanValidator.reasonSerial);
    }
    return valid;
  }
}
