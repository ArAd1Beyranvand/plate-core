import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigits, valid } from '../../core/validators/plate_validator';

/** Judges a `VanuatuPlates.standard` number: one to five digits. Reports,
 * never bars. */
export class VanuatuValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';

  static readonly reasonNumber = 'The number is 1 to 5 digits.';

  judge(entry: PlateEntry): PlateValidation {
    const number = entry.group('number');
    if (number === '' || number.length > 5 || !isDigits(number)) {
      return invalid(VanuatuValidator.reasonNumber);
    }
    return valid;
  }
}

/** Judges a `VanuatuPlates.diplomatic` value: four letters and one digit
 * (`ABCD 1`). The article lists no mission codes. */
export class VanuatuDiplomaticValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonCode = 'The code is four letters.';
  static readonly _code = new RegExp('^[A-Z]{4}$');
  static readonly reasonSerial = 'The serial is one digit.';

  judge(entry: PlateEntry): PlateValidation {
    const code = entry.group('code');
    if (!VanuatuDiplomaticValidator._code.test(code)) {
      return invalid(VanuatuDiplomaticValidator.reasonCode);
    }
    const serial = entry.group('serial');
    if (serial.length !== 1 || !isDigits(serial)) {
      return invalid(VanuatuDiplomaticValidator.reasonSerial);
    }
    return valid;
  }
}
