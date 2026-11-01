import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, valid } from '../../core/validators/plate_validator';

const current = { a: /^(\d[ABCEHJKLMPSTUZ][A-Z0-9]|EL\d)$/, b: /^[A-Z0-9]{4}$/ };
const digitPairs = { b: /^\d{2}$/, c: /^\d{2}$/ };

/** Spec id -> one pattern per field key. */
const formats: Record<string, Record<string, RegExp>> = {
  'cz.private': current,
  'cz.private2001': current,
  'cz.usSize': current,
  'cz.motorcycle': { a: /^[A-Z0-9]{2}$/, b: /^\d{4}$/ },
  'cz.personalised': { a: /^[A-Z0-9]{1,3}$/, b: /^[A-Z0-9]{1,5}$/ },
  'cz.classic': { a: /^[A-Z]{2,3}$/, ...digitPairs },
  'cz.classic70s': { a: /^[A-Z]{2}$/, ...digitPairs },
  'cz.military': { a: /^\d{3}$/, ...digitPairs },
  'cz.export': { a: /^[A-Z0-9]{3}$/, b: /^[A-Z0-9]{3}$/ },
  'cz.diplomatic': { a: /^\d{3}$/, b: /^[A-Z]{2}$/, c: /^\d{2}$/ },
  'cz.veteran': { a: /^V$/, b: /^\d{4}$/ },
};

/**
 * Judges a Czech plate field by field, `a`, `b`, `c`.
 *
 * The current plate is `1A2 3456`: a digit, the regional letter
 * (`A B C E H J K L M P S T U Z`) and a digit or letter, then four characters
 * (`B174` once a series runs out of numbers, `06AC` on electric `EL1 06AC`).
 * The 1992-2001 plate is two or three district letters and two pairs of
 * digits, `ALA 40-11`.
 * Reports, never bars a keystroke.
 */
export class CzechRepublicValidator extends GatedPlateValidator {
  readonly gateGroup = 'b';

  static readonly reason = 'The plate does not match its format.';

  judge(entry: PlateEntry): PlateValidation {
    const format = formats[entry.spec.id];
    if (!format) return valid;
    return Object.entries(format).every(([k, re]) => re.test(entry.group(k))) ? valid : invalid(CzechRepublicValidator.reason);
  }
}
