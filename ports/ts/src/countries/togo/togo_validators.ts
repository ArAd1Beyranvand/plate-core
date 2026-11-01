import { PlateValidator, type PlateEntry, type PlateValidation, invalid, restrictionVerdict, valid } from '../../core/validators/plate_validator';

/** Judges a Togolese plate field by field: `1234·AB`, four digits and a
 * two-letter series. Quiet until the series has something in it. Reports,
 * never bars a keystroke. */
export class TogoValidator implements PlateValidator {
  static readonly _digits4 = new RegExp(String.raw`^[0-9]{4}$`);
  static readonly _letters2 = new RegExp(String.raw`^[A-Z]{2}$`);

  validate(entry: PlateEntry): PlateValidation {
    const refused = restrictionVerdict(entry);
    if (refused != null) return refused;
    if (entry.group('series').length === 0) return valid;
    if (!TogoValidator._digits4.test(entry.group('number'))) {
      return invalid('The number is 4 digits.');
    }
    if (!TogoValidator._letters2.test(entry.group('series'))) {
      return invalid('The series is 2 letters.');
    }
    return valid;
  }
}
