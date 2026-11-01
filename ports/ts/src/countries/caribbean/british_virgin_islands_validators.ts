import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/**
 * Judges a Virgin Islands plate: a class prefix and a serial. `PV` takes five
 * digits, `TAXI` three, every other two-letter prefix (`GV`, `CM`, `TX`,
 * `RT`) four. Reports, never bars a keystroke.
 */
export class BritishVirginIslandsValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonPrefix = 'The plate starts with a class prefix: two letters, or TAXI.';
  static readonly reasonSerial = 'The serial has the wrong digit count.';

  judge(entry: PlateEntry): PlateValidation {
    return BritishVirginIslandsValidator.validateFields({ prefix: entry.group('prefix'), serial: entry.group('serial') });
  }

  static digitsFor(prefix: string): number {
    return prefix === 'PV' ? 5 : prefix === 'TAXI' ? 3 : 4;
  }

  static validateFields({ prefix, serial }: { prefix: string; serial: string }): PlateValidation {
    if (!/^([A-Z]{2}|TAXI)$/.test(prefix)) return invalid(BritishVirginIslandsValidator.reasonPrefix);
    if (!isDigitsOfLength(serial, BritishVirginIslandsValidator.digitsFor(prefix))) return invalid(BritishVirginIslandsValidator.reasonSerial);
    return valid;
  }
}
