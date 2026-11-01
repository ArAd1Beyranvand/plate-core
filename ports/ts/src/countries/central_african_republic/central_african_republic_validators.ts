import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** Judges a Central African plate: `BB 534 DG` — two letters, three digits
 * (001–999), two letters naming the prefecture. Reports, never bars a
 * keystroke. */
export class CentralAfricanRepublicValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  private static readonly _letters = /^[A-Z]{2}$/;

  judge(entry: PlateEntry): PlateValidation {
    if (!CentralAfricanRepublicValidator._letters.test(entry.group('series')!)) {
      return invalid('The series is 2 letters.');
    }
    const serial = entry.group('serial')!;
    if (!isDigitsOfLength(serial, 3) || serial === '000') {
      return invalid('The number is 001 to 999.');
    }
    if (!CentralAfricanRepublicValidator._letters.test(entry.group('prefecture')!)) {
      return invalid('The prefecture is 2 letters.');
    }
    return valid;
  }
}
