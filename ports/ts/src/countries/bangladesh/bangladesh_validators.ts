import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** Judges a Bangladeshi car plate: city, class letter, a two-digit series of
 * 11–99 and a four-digit number from 0001. Quiet until the number has
 * something in it. Reports, never bars a keystroke. */
export class BangladeshValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';

  judge(entry: PlateEntry): PlateValidation {
    if (entry.group('city').length === 0) {
      return invalid('Choose a city.');
    }
    if (entry.group('class').length === 0) {
      return invalid('Choose a vehicle class letter.');
    }
    const series = entry.group('series');
    if (!isDigitsOfLength(series, 2) || parseInt(series, 10) < 11) {
      return invalid('The series is 11 to 99.');
    }
    const number = entry.group('number');
    if (!isDigitsOfLength(number, 4) || number === '0000') {
      return invalid('The number is 0001 to 9999.');
    }
    return valid;
  }
}
