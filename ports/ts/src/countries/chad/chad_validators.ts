import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** Judges a Chadian plate: `12 V 3456 B` — region 01–23, a vehicle-type
 * letter, a four-digit number and a series letter. Temporary plates end in
 * `TT` instead of the series letter. Reports, never bars a keystroke. */
export class ChadValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';

  private static readonly _letter = /^[A-Z]$/;

  judge(entry: PlateEntry): PlateValidation {
    const region = entry.group('region');
    if (!isDigitsOfLength(region, 2)) {
      return invalid('The region is 01 to 23.');
    }
    const regionNum = parseInt(region, 10);
    if (regionNum === null || regionNum < 1 || regionNum > 23) {
      return invalid('The region is 01 to 23.');
    }
    if (!ChadValidator._letter.test(entry.group('type'))) {
      return invalid('The vehicle type is 1 letter (B, C, M, P, S, T, V).');
    }
    if (!isDigitsOfLength(entry.group('number'), 4)) {
      return invalid('The number is 4 digits.');
    }
    const tail = entry.group('tail');
    if (tail.length > 0 && !ChadValidator._letter.test(tail) && tail !== 'TT') {
      return invalid('The series is 1 letter, or TT on a temporary plate.');
    }
    return valid;
  }
}
