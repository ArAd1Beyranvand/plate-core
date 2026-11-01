import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** Judges a Sri Lankan plate: a province code (`CP`, `EP`, `NC`, `NP`, `NW`,
 * `SG`, `SP`, `UP` or `WP`), two or three letters and four digits. Reports,
 * never bars a keystroke. */
export class SriLankaValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';

  static readonly reasonProvince = 'The province is CP, EP, NC, NP, NW, SG, SP, UP or WP.';
  static readonly reasonLetters = 'The series is two or three letters.';
  static readonly reasonNumber = 'The number is four digits.';

  static readonly provinces = new Set(['CP', 'EP', 'NC', 'NP', 'NW', 'SG', 'SP', 'UP', 'WP']);
  static readonly _letters = new RegExp('^[A-Z]{2,3}$');

  judge(entry: PlateEntry): PlateValidation {
    if (!SriLankaValidator.provinces.has(entry.group('province'))) {
      return invalid(SriLankaValidator.reasonProvince);
    }
    if (!SriLankaValidator._letters.test(entry.group('letters'))) {
      return invalid(SriLankaValidator.reasonLetters);
    }
    if (!isDigitsOfLength(entry.group('number'), 4)) {
      return invalid(SriLankaValidator.reasonNumber);
    }
    return valid;
  }
}
