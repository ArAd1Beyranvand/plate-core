import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** Judges a 2010 plate field by field: a register and a serial, with the
 * lengths of its layout (`ABC-123`, `AB-1234`, or `E UA-123`). Reports, never
 * bars a keystroke. */
export class PeruValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonRegister =
    'The register is three letters or digits ' +
    '(AB1), two on a motorcycle, two letters on a special plate.';

  static readonly reasonSerial =
    'The number is three digits, four on a ' +
    'motorcycle.';

  static readonly reasonSpecial =
    'E marks the special series; a regular ' +
    'register does not start with it.';

  private static readonly _alphanumeric = new RegExp(String.raw`^[A-Z0-9]+$`);
  private static readonly _letters = new RegExp(String.raw`^[A-Z]+$`);

  judge(entry: PlateEntry): PlateValidation {
    const id = entry.spec.id;
    const special = id === 'pe.special';
    const registerLength = id === 'pe.regular' ? 3 : 2;
    const serialLength = id === 'pe.motorcycle' ? 4 : 3;
    const register = entry.group('register');

    if (register.length !== registerLength ||
      !(special ? PeruValidator._letters : PeruValidator._alphanumeric).test(register)) {
      return invalid(PeruValidator.reasonRegister);
    }
    if (!special && register.startsWith('E')) {
      return invalid(PeruValidator.reasonSpecial);
    }
    if (!isDigitsOfLength(entry.group('serial'), serialLength)) {
      return invalid(PeruValidator.reasonSerial);
    }
    return valid;
  }
}
