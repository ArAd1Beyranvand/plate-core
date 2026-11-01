import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** Judges a plate: six digits on a car (`686120`), `M` and five digits on a
 * motorcycle (`M 42421`). Reports, never bars a keystroke.
 *
 * The 2013 `AB1234` format and its class letters (T, B, G, D, CD, ...) are
 * not modelled: no reference of it was measured. */
export class PanamaValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonClass = 'A motorcycle plate starts with M.';
  static readonly reasonSerial = 'The number is six digits, five on a motorcycle.';

  judge(entry: PlateEntry): PlateValidation {
    const serial = entry.group('serial');
    const prefix = entry.group('class');
    if (prefix !== '' && prefix !== 'M') {
      return invalid(PanamaValidator.reasonClass);
    }
    if (!isDigitsOfLength(serial, prefix === '' ? 6 : 5)) {
      return invalid(PanamaValidator.reasonSerial);
    }
    return valid;
  }
}
