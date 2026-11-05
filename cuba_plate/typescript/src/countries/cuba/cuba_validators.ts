import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigits, valid } from 'plate_core/core/validators/plate_validator';

/** The series letters: A-Y without I, O, Q, S and W; the alphabet folds case, so lowercase passes. */
const issuedLetter = /^[ABCDEFGHJKLMNPRTUVXY]$/i;

/**
 * Judges a 2013 Cuban plate value. Reports, never bars a keystroke.
 *
 * Quiet until the first serial group has a digit. Checks the letter is an
 * issued series and the serial is the full digit count of the spec: six on
 * a car (`serial` + `serial2`), five on a motorcycle (`serial`).
 */
export class CubaValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonLetterMissing = 'A plate starts with a letter.';
  static readonly reasonLetterUnissued = 'I, O, Q, S, W and Z are not issued.';
  static readonly reasonSerialNotNumeric = 'The number is digits only.';
  static readonly reasonSerialLength = 'The number fills every cell.';

  judge(entry: PlateEntry): PlateValidation {
    const letter = entry.group('letter');
    if (letter === '') return invalid(CubaValidator.reasonLetterMissing);
    if (!issuedLetter.test(letter)) return invalid(CubaValidator.reasonLetterUnissued);
    const serial = entry.group('serial') + entry.group('serial2');
    if (serial.length !== entry.spec.slotCount - 1) return invalid(CubaValidator.reasonSerialLength);
    if (!isDigits(serial)) return invalid(CubaValidator.reasonSerialNotNumeric);
    return valid;
  }
}
