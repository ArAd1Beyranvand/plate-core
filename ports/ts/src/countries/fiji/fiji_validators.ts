import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigits, valid } from '../../core/validators/plate_validator';

/** Judges a Fijian plate: letters then digits (`AA 001`, `E 0845`) or, for a
 * motorcycle, digits then a letter (`001 A`). Reports, never bars a keystroke. */
export class FijiValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonLetters = 'The register is one or two letters.';
  static readonly reasonSerial = 'The number is three or four digits.';

  judge(entry: PlateEntry): PlateValidation {
    const letters = entry.group('letters');
    if (!/^[A-Z]{1,2}$/.test(letters)) {
      return invalid(FijiValidator.reasonLetters);
    }
    const serial = entry.group('serial');
    if (!isDigits(serial) || serial.length < 3 || serial.length > 4) {
      return invalid(FijiValidator.reasonSerial);
    }
    return valid;
  }
}
