import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** Judges a Beninese plate: two letters (the series) and four digits, `AB 1234`.
 * Reports, never bars a keystroke. */
export class BeninValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';

  static readonly _series = new RegExp('^[A-Z]{2}$');

  judge(entry: PlateEntry): PlateValidation {
    if (!BeninValidator._series.test(entry.group('series'))) {
      return invalid('The series is 2 letters.');
    }
    if (!isDigitsOfLength(entry.group('number'), 4)) {
      return invalid('The number is 4 digits.');
    }
    return valid;
  }
}
