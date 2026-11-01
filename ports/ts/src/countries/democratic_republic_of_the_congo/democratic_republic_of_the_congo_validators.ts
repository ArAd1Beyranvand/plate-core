import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** Judges a private plate: `1234 AB 10` - four digits, two letters and a province code 01-26. Reports, never bars input. */
export class DemocraticRepublicOfTheCongoValidator extends GatedPlateValidator {
  readonly gateGroup = 'province';

  judge(entry: PlateEntry): PlateValidation {
    if (!isDigitsOfLength(entry.group('number'), 4)) return invalid('The number is 4 digits.');
    if (!/^[A-Z]{2}$/.test(entry.group('series'))) return invalid('The series is 2 letters.');
    if (!/^(0[1-9]|1[0-9]|2[0-6])$/.test(entry.group('province'))) return invalid('The province code is 01 to 26.');
    return valid;
  }
}
