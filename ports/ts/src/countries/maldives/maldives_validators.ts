import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigits, valid } from '../../core/validators/plate_validator';

/** Advisory validator for any `MaldivesPlates` value: the category code is
 * one of the eight published and the serial is 1-4 digits. */
export class MaldivesPlateValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonCategory = 'Not a vehicle category code in the published table.';
  static readonly reasonSerial = 'The serial is 1–4 digits.';

  /** Motorcycles, passenger and goods. */
  static readonly categories = new Set(['A0', 'A1', 'B0', 'B1', 'B2', 'C0', 'C1', 'C2']);

  judge(entry: PlateEntry): PlateValidation {
    if (!MaldivesPlateValidator.categories.has(entry.group('category'))) {
      return invalid(MaldivesPlateValidator.reasonCategory);
    }
    const s = entry.group('serial');
    if (!isDigits(s) || s.length > 4) {
      return invalid(MaldivesPlateValidator.reasonSerial);
    }
    return valid;
  }
}
