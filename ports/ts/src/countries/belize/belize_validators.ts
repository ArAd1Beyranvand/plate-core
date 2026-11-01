import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigits, valid } from '../../core/validators/plate_validator';

/** Judges a Belizean registration: a `prefix` of one letter (class or
 * district: `C`, `A`, `D`) or three (the defence ministry's `DFS`), absent on
 * auto-dealer plates, and a numeric `serial`. The article gives the formats
 * `A-1234`, `A-12345`, `ABC-123` and `12345`; the pictures show three to five
 * digits (`A-816` on a truck plate), so the serial is three to five.
 * Reports, never bars a keystroke. */
export class BelizeValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly minSerial = 3;
  static readonly maxSerial = 5;
  static readonly maxPrefix = 3;

  static readonly _prefix = new RegExp(`^[A-Z]{1,${BelizeValidator.maxPrefix}}$`);

  static readonly reasonSerial = 'The serial is three to five digits.';
  static readonly reasonPrefix = 'The prefix is one to three letters.';

  judge(entry: PlateEntry): PlateValidation {
    return BelizeValidator.validateFields({
      prefix: entry.group('prefix'),
      serial: entry.group('serial'),
    });
  }

  static validateFields({
    prefix,
    serial,
  }: {
    prefix: string;
    serial: string;
  }): PlateValidation {
    if (prefix.length > 0 && !BelizeValidator._prefix.test(prefix)) {
      return invalid(BelizeValidator.reasonPrefix);
    }
    if (!isDigits(serial) ||
        serial.length < BelizeValidator.minSerial ||
        serial.length > BelizeValidator.maxSerial) {
      return invalid(BelizeValidator.reasonSerial);
    }
    return valid;
  }
}
