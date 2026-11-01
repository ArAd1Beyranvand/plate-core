import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, valid } from '../../core/validators/plate_validator';

/** Judges a plate `RXX ###X`: a register of three letters starting with `R`,
 * then three digits and a letter. Reports, never bars a keystroke. */
export class RwandaValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonRegister = 'The register is three letters starting with R.';
  static readonly reasonSerial = 'The number is three digits and a letter.';

  static readonly _register = new RegExp('^R[A-Z]{2}$');
  static readonly _serial = new RegExp('^[0-9]{3}[A-Z]$');

  judge(entry: PlateEntry): PlateValidation {
    if (!RwandaValidator._register.test(entry.group('register'))) {
      return invalid(RwandaValidator.reasonRegister);
    }
    if (!RwandaValidator._serial.test(entry.group('serial'))) {
      return invalid(RwandaValidator.reasonSerial);
    }
    return valid;
  }
}
