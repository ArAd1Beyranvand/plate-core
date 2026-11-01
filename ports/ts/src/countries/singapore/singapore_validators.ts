import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigits, valid } from '../../core/validators/plate_validator';

const weights = [9, 4, 5, 4, 3, 2];
const isLetters = (s: string): boolean => /^[A-Z]*$/.test(s);

/** The checksum letter of a Singaporean registration. Only the last two
 * letters of the prefix count (a single letter is the second, the first is
 * 0); the serial is zero-padded to four digits; the six numbers are weighted
 * 9 4 5 4 3 2, summed, and the remainder mod 19 picks the letter. */
export const SingaporeChecksum = {
  letters: 'AZYXUTSRPMLKJHGEDCB',

  /** Null when `prefix` or `serial` is not a letter run of 1 to 3 and a digit
   * run of 1 to 4. */
  of(prefix: string, serial: string): string | null {
    if (prefix === '' || prefix.length > 3 || !isLetters(prefix)) return null;
    if (!isDigits(serial) || serial.length > 4) return null;
    const tail = prefix.length > 2 ? prefix.slice(-2) : prefix;
    const numbers = [
      ...(tail.length === 1 ? [0] : []),
      ...Array.from(tail, (c) => c.charCodeAt(0) - 0x40),
      ...Array.from(serial.padStart(4, '0'), (c) => c.charCodeAt(0) - 0x30),
    ];
    const sum = weights.reduce((s, w, i) => s + numbers[i] * w, 0);
    return SingaporeChecksum.letters[sum % 19];
  },
};

/** Judges a Singaporean registration: a prefix of one to three letters, a
 * serial of one to four digits without leading zeros, and a checksum letter.
 *
 * Reports, never bars a keystroke. The checksum is absent on government and
 * event plates ("SPF 1", "SEP 1"), so an empty one passes. The series rules
 * that skip prefixes (SA, SHE, SKY, vowels in a middle letter, ...) are not
 * judged: the article lists them as policy, not as a format. */
export class SingaporeValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonPrefix = 'The prefix is one to three letters.';
  static readonly reasonSerial = 'The number is one to four digits, without leading zeros.';
  static readonly reasonCheck = 'The checksum letter does not match the number.';

  judge(entry: PlateEntry): PlateValidation {
    return SingaporeValidator.validateFields({
      prefix: entry.group('prefix'),
      serial: entry.group('serial'),
      check: entry.group('check'),
    });
  }

  static validateFields(f: { prefix: string; serial: string; check: string }): PlateValidation {
    if (SingaporeChecksum.of(f.prefix, '0') === null) {
      return invalid(SingaporeValidator.reasonPrefix);
    }
    if (!isDigits(f.serial) || f.serial.length > 4 || f.serial.startsWith('0')) {
      return invalid(SingaporeValidator.reasonSerial);
    }
    if (f.check !== '' && f.check !== SingaporeChecksum.of(f.prefix, f.serial)) {
      return invalid(SingaporeValidator.reasonCheck);
    }
    return valid;
  }
}
