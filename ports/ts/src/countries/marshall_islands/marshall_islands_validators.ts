import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigits, valid } from '../../core/validators/plate_validator';

/** Judges a Marshallese plate by its `serial` group: four digits on the
 * Majuro Atoll plate, one to three on the 1972 plate (both fit one to four).
 * Reports, never bars a keystroke. */
export class MarshallIslandsValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonSerial = 'The number is one to four digits.';

  judge(entry: PlateEntry): PlateValidation {
    const serial = entry.group('serial');
    if (!isDigits(serial) || serial.length > 4) {
      return invalid(MarshallIslandsValidator.reasonSerial);
    }
    return valid;
  }
}
