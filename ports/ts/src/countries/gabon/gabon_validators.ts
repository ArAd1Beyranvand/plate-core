import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** Judges `AB-123-CD`: two letters, three digits, two letters. Reports, never
 * bars a keystroke. */
export class GabonValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';

  private static readonly _twoLetters = new RegExp('^[A-Z]{2}$');

  judge(entry: PlateEntry): PlateValidation {
    if (!GabonValidator._twoLetters.test(entry.group('series'))) {
      return invalid('The first group is 2 letters.');
    }
    if (!isDigitsOfLength(entry.group('number'), 3)) {
      return invalid('The number is 3 digits.');
    }
    if (!GabonValidator._twoLetters.test(entry.group('suffix'))) {
      return invalid('The last group is 2 letters.');
    }
    return valid;
  }
}
