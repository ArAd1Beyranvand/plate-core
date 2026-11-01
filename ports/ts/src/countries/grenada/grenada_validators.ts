import { GatedPlateValidator, type PlateEntry, type PlateValidation, type PlateValidator, invalid, isDigits, isDigitsOfLength, restrictionVerdict, valid } from '../../core/validators/plate_validator';

/**
 * Judges a Grenadian plate field by field: three letters then three digits
 * (`ABC123`). Quiet until the last field has something in it. Reports, never
 * bars a keystroke.
 */
export class GrenadaValidator implements PlateValidator {
  validate(entry: PlateEntry): PlateValidation {
    const refused = restrictionVerdict(entry);
    if (refused !== null) return refused;
    if (entry.group('number') === '') return valid;
    if (!/^[A-Z]{3}$/.test(entry.group('letters'))) return invalid('The series is 3 letters.');
    if (!/^[0-9]{3}$/.test(entry.group('number'))) return invalid('The number is 3 digits.');
    return valid;
  }
}
