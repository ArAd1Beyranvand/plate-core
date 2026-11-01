import { GatedPlateValidator, type PlateEntry, type PlateValidation, type PlateValidator, invalid, isDigits, isDigitsOfLength, restrictionVerdict, valid } from '../../core/validators/plate_validator';

const lettersRe = /^[A-Z]{1,3}$/;
const serialRe = /^[A-Z0-9]{1,8}$/;

/**
 * Judges a Palauan registration. Reports, never bars a keystroke.
 *
 * The article gives no format except the odd example (`A 123`, `1234`,
 * `K79-123`, `BNM-1234`, `PICRC-12`), so this checks only what the plates
 * show: optional `letters` (one to three capitals), an optional two-digit
 * `code`, and a run of one to five `digits`, or a single mixed `serial`
 * (Koror's black plate, `2K5136`).
 */
export class PalauValidator implements PlateValidator {
  static readonly reasonLetters = 'The letters are one to three capitals.';
  static readonly reasonCode = 'The code is two digits.';
  static readonly reasonDigits = 'The number is one to five digits.';
  static readonly reasonSerial = 'The serial is up to eight letters and digits.';

  validate(entry: PlateEntry): PlateValidation {
    const V = PalauValidator;
    const refused = restrictionVerdict(entry);
    if (refused !== null) return refused;
    const digits = entry.group('digits');
    const serial = entry.group('serial');
    if (digits === '' && serial === '') return valid;
    const letters = entry.group('letters');
    if (letters !== '' && !lettersRe.test(letters)) return invalid(V.reasonLetters);
    const code = entry.group('code');
    if (code !== '' && !isDigitsOfLength(code, 2)) return invalid(V.reasonCode);
    if (digits !== '' && (!isDigits(digits) || digits.length > 5)) return invalid(V.reasonDigits);
    if (serial !== '' && !serialRe.test(serial)) return invalid(V.reasonSerial);
    return valid;
  }
}
