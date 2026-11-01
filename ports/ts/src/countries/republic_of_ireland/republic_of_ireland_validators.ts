import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigits, valid } from '../../core/validators/plate_validator';

const yearRe = /^[0-9]{2}[12]$/;
const counties: ReadonlySet<string> = new Set(
  'C CE CN CW D DL G KE KK KY L LD LH LM LS MH MN MO OY RN SO T W WH WX WW LK TN TS WD'.split(' '),
);

/**
 * Judges a plate in the form `YYH-CC-NNNNN`: a year and half-year (`131` is
 * the first half of 2013), a county code from the article's tables, and the
 * sequence number. Reports, never bars a keystroke.
 *
 * The sequence is one to six digits (six on re-registered imports).
 */
export class RepublicOfIrelandValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonYear = 'The year is two digits and a half-year, 1 or 2.';
  static readonly reasonCounty = 'That is not a county code.';
  static readonly reasonSerial = 'The number is one to six digits.';

  judge(entry: PlateEntry): PlateValidation {
    const V = RepublicOfIrelandValidator;
    if (!yearRe.test(entry.group('year'))) return invalid(V.reasonYear);
    if (!counties.has(entry.group('county'))) return invalid(V.reasonCounty);
    const serial = entry.group('serial');
    if (!isDigits(serial) || serial.length > 6) return invalid(V.reasonSerial);
    return valid;
  }
}
