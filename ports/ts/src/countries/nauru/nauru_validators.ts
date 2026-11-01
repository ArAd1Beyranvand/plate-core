import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** Judges a Nauruan plate by its groups: `letters` (three) with `serial`
/// (three digits) on the 2015 plate, `serial` alone (four digits) on the
/// 1975 plate, `prefix` (one digit) with `serial` (three) on the 1970 plate.
/// Reports, never bars a keystroke. */
export class NauruValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonLetters = 'The register is three letters.';
  static readonly reasonPrefix = 'The prefix is one digit.';
  static readonly reasonSerial = 'The number has the wrong digit count.';

  judge(entry: PlateEntry): PlateValidation {
    const letters = entry.group('letters');
    const prefix = entry.group('prefix');
    const serial = entry.group('serial');
    const hasLetters = letters.length > 0;
    const hasPrefix = prefix.length > 0;
    if (hasLetters && !/^[A-Z]{3}$/.test(letters)) {
      return invalid(NauruValidator.reasonLetters);
    }
    if (hasPrefix && !isDigitsOfLength(prefix, 1)) {
      return invalid(NauruValidator.reasonPrefix);
    }
    const digits = hasLetters || hasPrefix ? 3 : 4;
    if (!isDigitsOfLength(serial, digits)) {
      return invalid(NauruValidator.reasonSerial);
    }
    return valid;
  }
}
