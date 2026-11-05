import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigits, isDigitsOfLength, valid } from 'plate_core/core/validators/plate_validator';

/** The plate letters: the towns' and the special series. */
const letters: readonly string[] = ['A', 'B', 'Y', 'G', 'N', 'O', 'S', 'T', 'K', 'Z', 'J', 'R', 'M', 'C', 'D', 'P', 'MP'];

/** Judges a Lebanese plate: a letter and a serial of one to six digits. Reports, never bars a keystroke. */
export class LebanonValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonLetterMissing = 'A plate starts with a letter.';
  static readonly reasonLetterUnknown = 'That is not a Lebanese plate letter.';
  static readonly reasonSerialNotNumeric = 'The number is digits only.';
  static readonly reasonSerialLength = 'The number is one to six digits.';
  static readonly reasonParliamentRange = 'A parliament plate is numbered 1 to 128.';

  static readonly minSerialLength = 1;
  static readonly maxSerialLength = 6;
  static readonly maxParliamentNumber = 128;

  judge(entry: PlateEntry): PlateValidation {
    return LebanonValidator.validateFields({ letter: entry.group('letter'), serial: entry.group('serial') });
  }

  static validateFields({ letter, serial }: { letter: string; serial: string }): PlateValidation {
    if (letter === '') return invalid(LebanonValidator.reasonLetterMissing);
    const code = letter.toUpperCase();
    if (!letters.includes(code)) return invalid(LebanonValidator.reasonLetterUnknown);
    if (serial.length < LebanonValidator.minSerialLength || serial.length > LebanonValidator.maxSerialLength) return invalid(LebanonValidator.reasonSerialLength);
    if (!isDigits(serial)) return invalid(LebanonValidator.reasonSerialNotNumeric);
    if (code === 'MP') {
      const number = Number(serial);
      if (number < 1 || number > LebanonValidator.maxParliamentNumber) return invalid(LebanonValidator.reasonParliamentRange);
    }
    return valid;
  }
}
