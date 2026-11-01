import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, valid } from '../../core/validators/plate_validator';

const twoLetters = /^[A-Z]{2}$/;
const oneLetter = /^[A-Z]$/;
const threeDigits = /^\d{3}$/;
const fiveDigits = /^\d{5}$/;

const lettersDigitsLetters: Record<string, RegExp> = { a: twoLetters, b: threeDigits, c: twoLetters };
const twoLine: Record<string, RegExp> = { a: twoLetters, b: oneLetter, c: threeDigits };

/** Judges a Slovak plate field by field (`a`, `b`, `c`). Reports, never bars a
 * keystroke. */
export class SlovakiaValidator extends GatedPlateValidator {
  readonly gateGroup = 'b';

  static readonly reason = 'The plate does not match its format.';

  /** Spec id -> one pattern per field key. */
  private static readonly _formats: Record<string, Record<string, RegExp>> = {
    'sk.private': lettersDigitsLetters,
    'sk.privateDash': lettersDigitsLetters,
    'sk.legacy': lettersDigitsLetters,
    'sk.temporary': twoLine,
    'sk.dealer': twoLine,
    'sk.personalised': { a: twoLetters, b: /^[A-Z0-9]{1,5}$/ },
    'sk.imported': { a: oneLetter, b: fiveDigits },
    'sk.military': { a: /^\d{2}$/, b: fiveDigits },
    'sk.diplomatic': { a: twoLetters, b: fiveDigits },
    'sk.officials': { a: twoLetters, b: oneLetter, c: threeDigits },
  };

  judge(entry: PlateEntry): PlateValidation {
    const format = SlovakiaValidator._formats[entry.spec.id];
    if (format === undefined) return valid;
    for (const [key, pattern] of Object.entries(format)) {
      if (!pattern.test(entry.group(key))) return invalid(SlovakiaValidator.reason);
    }
    return valid;
  }
}
