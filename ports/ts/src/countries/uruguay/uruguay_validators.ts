import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, valid } from '../../core/validators/plate_validator';

/**
 * Judges a Uruguayan serial `A BC 1234`: three letters in `first`, the first
 * a department code (A to S), and one to four digits in `number` (the
 * President of a Departmental Assembly's plate carries one).
 *
 * The category letters are not checked. Reports, never bars a keystroke.
 */
export class UruguayValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';

  static readonly reasonLetters = 'A serial is three letters, the first a department code (A to S).';
  static readonly reasonNumber = 'The number is one to four digits.';

  private static readonly _letters = new RegExp(String.raw`^[A-S][A-Z]{2}$`);
  private static readonly _digits = new RegExp(String.raw`^[0-9]{1,4}$`);

  judge(entry: PlateEntry): PlateValidation {
    if (!UruguayValidator._letters.test(entry.group('first')!)) {
      return invalid(UruguayValidator.reasonLetters);
    }
    if (!UruguayValidator._digits.test(entry.group('number')!)) {
      return invalid(UruguayValidator.reasonNumber);
    }
    return valid;
  }
}
