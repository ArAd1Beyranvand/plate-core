import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigits, valid } from '../../core/validators/plate_validator';

/** Judges a St. Eustatius value: the island letter `E` and a number of up to
 * four digits (`E 30`, `E191`). The article says "three or four digits" for
 * the 2007 plate and `E123` for 1976, but the 2007 photo shows two digits,
 * so one to four are accepted; the picture wins. Reports, never bars a
 * keystroke. */
export class SintEustatiusValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';

  static readonly reasonPrefix = 'The prefix is E.';
  static readonly reasonNumber = 'The number is up to four digits.';

  judge(entry: PlateEntry): PlateValidation {
    if (entry.group('prefix') !== 'E') {
      return invalid(SintEustatiusValidator.reasonPrefix);
    }
    const number = entry.group('number');
    if (number === '' || number.length > 4 || !isDigits(number)) {
      return invalid(SintEustatiusValidator.reasonNumber);
    }
    return valid;
  }
}
