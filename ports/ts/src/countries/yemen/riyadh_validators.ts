import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigits, valid } from '../../core/validators/plate_validator';

/** Judges a Riyadh plate: three letters from the seventeen issued and one to
 * four digits. The combinations banned since 2009 are not checked; only
 * examples are published, not the list. */
export class RiyadhValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonLetters = 'The register is three letters.';
  static readonly reasonSerial = 'The number is one to four digits.';
  static readonly _letters = new RegExp('^[ABJDRSXTEGKLZNHUV]{3}$');

  judge(entry: PlateEntry): PlateValidation {
    if (!RiyadhValidator._letters.test(entry.group('letters'))) {
      return invalid(RiyadhValidator.reasonLetters);
    }
    const serial = entry.group('serial');
    if (!isDigits(serial) || serial.length > 4) {
      return invalid(RiyadhValidator.reasonSerial);
    }
    return valid;
  }
}
