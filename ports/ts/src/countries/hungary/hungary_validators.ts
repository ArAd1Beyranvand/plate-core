import { GatedPlateValidator, type PlateEntry, type PlateValidation, type PlateValidator, invalid, isDigits, isDigitsOfLength, restrictionVerdict, valid } from '../../core/validators/plate_validator';

const letter = /^[A-Z]$/;
const two = /^[A-Z]{2}$/;
const three = /^[A-Z]{3}$/;
const pairs = { a: two, b: /^\d{2}$/, c: /^\d{2}$/ };
const letterDigitsYear = { a: letter, b: /^\d{5}$/, c: /^\d{2}$/ };

/** Group key to pattern, per spec id. */
const formats: Readonly<Record<string, Readonly<Record<string, RegExp>>>> = {
  'hu.private': { a: two, b: two, c: /^\d{3}$/ },
  'hu.diplomatic': pairs,
  'hu.staff': pairs,
  'hu.agricultural': { a: letter, b: /^\d{6}$/ },
  'hu.export': letterDigitsYear,
  'hu.trial': letterDigitsYear,
  'hu.slow': { a: three, b: /^\d{3}$/ },
};

/** Judges a Hungarian plate against the format of its spec. Reports, never bars a keystroke. */
export class HungaryValidator extends GatedPlateValidator {
  readonly gateGroup = 'a';

  static readonly reason = 'The plate does not match its format.';

  judge(entry: PlateEntry): PlateValidation {
    const format = Object.hasOwn(formats, entry.spec.id) ? formats[entry.spec.id] : undefined;
    if (format === undefined) return valid;
    return Object.entries(format).every(([key, pattern]) => pattern.test(entry.group(key))) ? valid : invalid(HungaryValidator.reason);
  }
}
