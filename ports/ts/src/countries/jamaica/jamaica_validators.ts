import { GatedPlateValidator, type PlateEntry, type PlateValidation, type PlateValidator, invalid, isDigits, isDigitsOfLength, restrictionVerdict, valid } from '../../core/validators/plate_validator';

/** Judges a Jamaican plate: a four-digit serial and a series of one or two letters. Reports, never bars a keystroke. */
export class JamaicaValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly serialLength = 4;
  static readonly minLetters = 1;
  static readonly maxLetters = 2;

  static readonly reasonSerial = 'The serial is four digits.';
  static readonly reasonLetters = 'The series is one or two letters.';

  judge(entry: PlateEntry): PlateValidation {
    return JamaicaValidator.validateFields({ serial: entry.group('serial'), letters: entry.group('letters') });
  }

  static validateFields({ serial, letters }: { serial: string; letters: string }): PlateValidation {
    if (!isDigitsOfLength(serial, JamaicaValidator.serialLength)) return invalid(JamaicaValidator.reasonSerial);
    if (!new RegExp(`^[A-Z]{${JamaicaValidator.minLetters},${JamaicaValidator.maxLetters}}$`).test(letters)) return invalid(JamaicaValidator.reasonLetters);
    return valid;
  }
}
