import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/**
 * Judges a Congolese regular plate: `123 AB 4` — three digits, two letters
 * and an area code of one or two digits (1–14). Reports, never bars input.
 */
export class RepublicOfTheCongoValidator extends GatedPlateValidator {
  readonly gateGroup = 'area';

  judge(entry: PlateEntry): PlateValidation {
    if (!isDigitsOfLength(entry.group('number'), 3)) return invalid('The number is 3 digits.');
    if (!/^[A-Z]{2}$/.test(entry.group('series'))) return invalid('The series is 2 letters.');
    const text = entry.group('area');
    const area = /^[+-]?[0-9]+$/.test(text) ? Number(text) : null;
    if (area === null || area < 1 || area > 14) return invalid('The area code is 1 to 14.');
    return valid;
  }
}
