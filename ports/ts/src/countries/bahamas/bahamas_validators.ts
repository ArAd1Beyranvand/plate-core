import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigits, valid } from '../../core/validators/plate_validator';

const letter = /^[A-Z]$/;

/**
 * Judges a Bahamian registration: an optional class letter (`prefix`, the
 * `T` of the truck series) and a numeric `serial` of up to five digits.
 * Reports, never bars a keystroke. The 2016 format has no photograph and is
 * not modelled.
 */
export class BahamasValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly maxSerial = 5;

  static readonly reasonSerial = 'The serial is one to five digits.';
  static readonly reasonPrefix = 'The class prefix is one letter.';

  judge(entry: PlateEntry): PlateValidation {
    return BahamasValidator.validateFields({ prefix: entry.group('prefix'), serial: entry.group('serial') });
  }

  static validateFields({ prefix, serial }: { prefix: string; serial: string }): PlateValidation {
    if (prefix !== '' && !letter.test(prefix)) return invalid(BahamasValidator.reasonPrefix);
    if (!isDigits(serial) || serial.length > BahamasValidator.maxSerial) return invalid(BahamasValidator.reasonSerial);
    return valid;
  }
}
