import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, valid } from '../../core/validators/plate_validator';

/** Judges a Guatemalan serial `P 123 ABC`: a class letter, three digits and
 * three letters. The class letter is not checked beyond being a letter.
 *
 * Reports, never bars a keystroke. */
export class GuatemalaValidator extends GatedPlateValidator {
  readonly gateGroup = 'letters';

  static readonly reasonClass = 'The class is one letter, such as P or C.';
  static readonly reasonDigits = 'The number is three digits.';
  static readonly reasonLetters = 'The serial ends in three letters.';

  private static readonly _class = new RegExp('^[A-Z]$');
  private static readonly _digits = new RegExp('^[0-9]{3}$');
  private static readonly _letters = new RegExp('^[A-Z]{3}$');

  judge(entry: PlateEntry): PlateValidation {
    if (!GuatemalaValidator._class.test(entry.group('class'))) {
      return invalid(GuatemalaValidator.reasonClass);
    }
    if (!GuatemalaValidator._digits.test(entry.group('digits'))) {
      return invalid(GuatemalaValidator.reasonDigits);
    }
    if (!GuatemalaValidator._letters.test(entry.group('letters'))) {
      return invalid(GuatemalaValidator.reasonLetters);
    }
    return valid;
  }
}
