import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, valid } from '../../core/validators/plate_validator';

/** Judges a Paraguayan Mercosur serial `AAAA 123`: four letters in `letters`
 * and three digits in `number`. (Motorcycles print `123 ABC`; not modelled.)
 *
 * Reports, never bars a keystroke. */
export class ParaguayValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';

  static readonly reasonLetters = 'The series is four letters.';
  static readonly reasonNumber = 'The number is three digits.';

  static readonly _letters = new RegExp('^[A-Z]{4}$');
  static readonly _digits = new RegExp('^[0-9]{3}$');

  judge(entry: PlateEntry): PlateValidation {
    if (!ParaguayValidator._letters.test(entry.group('letters'))) {
      return invalid(ParaguayValidator.reasonLetters);
    }
    if (!ParaguayValidator._digits.test(entry.group('number'))) {
      return invalid(ParaguayValidator.reasonNumber);
    }
    return valid;
  }
}
