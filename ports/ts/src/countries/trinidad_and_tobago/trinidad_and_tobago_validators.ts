import { PlateValidator, type PlateEntry, type PlateValidation, invalid, valid } from '../../core/validators/plate_validator';

/** Judges a Trinidad and Tobago plate field by field: one to three series
 * letters (the first is the vehicle class) and one to four digits. I, O, Q and
 * V are never issued in a series. Quiet until the letters have something in
 * them. Reports, never bars a keystroke. */
export class TrinidadAndTobagoValidator implements PlateValidator {
  static readonly _letters = new RegExp('^[A-HJ-NP-UW-Z]{1,3}$');
  static readonly _digits = new RegExp('^[0-9]{1,4}$');

  validate(entry: PlateEntry): PlateValidation {
    const refused = restrictionVerdict(entry);
    if (refused != null) return refused;
    if (entry.group('letters').length === 0) return valid;
    if (!TrinidadAndTobagoValidator._letters.test(entry.group('letters'))) {
      return invalid('The series is one to three letters, never I, O, Q or V.');
    }
    if (!TrinidadAndTobagoValidator._digits.test(entry.group('serial'))) {
      return invalid('The number is one to four digits.');
    }
    return valid;
  }
}

function restrictionVerdict(entry: PlateEntry): PlateValidation | null {
  return null;
}
