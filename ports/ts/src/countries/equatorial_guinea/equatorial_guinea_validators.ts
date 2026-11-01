import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** Judges `AB-123-C`: province code, three digits, series letter. Reports,
/// never bars a keystroke. */
export class EquatorialGuineaValidator extends GatedPlateValidator {
  readonly provinces = new Set(['AN', 'BN', 'BS', 'CS', 'KN', 'LT', 'WN']);

  static readonly _series = new RegExp(String.raw`^[A-Z]$`);

  readonly gateGroup = 'series';

  judge(entry: PlateEntry): PlateValidation {
    if (!this.provinces.has(entry.group('province'))) {
      return invalid(`The province is one of ${[...this.provinces].join(', ')}.`);
    }
    if (!isDigitsOfLength(entry.group('number'), 3)) {
      return invalid('The number is 3 digits.');
    }
    if (!EquatorialGuineaValidator._series.test(entry.group('series'))) {
      return invalid('The series is 1 letter.');
    }
    return valid;
  }
}
