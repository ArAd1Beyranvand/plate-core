import { type PlateEntry, type PlateValidation, type PlateValidator, invalid, restrictionVerdict, valid } from '../../core/validators/plate_validator';

const letters12 = /^[A-Z]{1,2}$/;
const digits15 = /^\d{1,5}$/;
const district = { a: letters12, b: digits15, c: letters12 };

/** Spec id -> one pattern per field key, in field order. */
const formats: Record<string, Record<string, RegExp>> = {
  'at.private': district,
  'at.electric': district,
  'at.trailer': district,
  'at.export': { a: letters12, b: /^\d{1,3}$/, c: letters12 },
  'at.temporary': { a: letters12, b: /^\d{1,2}$/, c: letters12, d: /^\d{2}$/ },
  'at.fire': { a: /^FW$/, b: /^\d{1,4}$/, c: letters12 },
  'at.federal': { a: letters12, b: digits15 },
  'at.diplomatic': { a: /^[A-Z]{2}$/, mission: /^\d{1,2}$/ },
  'at.personalised': { a: letters12, b: /^[A-Z]{1,5}$/, c: /^\d{1,3}$/ },
  'at.moped': { a: letters12, b: /^\d{1,3}$/, c: /^[A-Z]{1,3}$/ },
};

/**
 * Judges an Austrian plate field by field, `a`, `b`, `c`.
 *
 * Ordinary plates are one or two district letters, one to five digits and one
 * or two letters; federal plates letters and digits; diplomatic plates `WD`
 * and a mission code (1-2 digits); personalised plates a block of letters
 * then a block of digits, at least three characters together.
 * Reports, never bars a keystroke; judged once the last register has content.
 */
export class AustriaValidator implements PlateValidator {
  static readonly reason = 'The plate does not match its format.';

  validate(entry: PlateEntry): PlateValidation {
    const refused = restrictionVerdict(entry);
    if (refused !== null) return refused;
    const format = formats[entry.spec.id];
    const keys = format ? Object.keys(format) : [];
    if (!format || entry.group(keys[keys.length - 1]) === '') return valid;
    if (keys.some((k) => !format[k].test(entry.group(k)))) return invalid(AustriaValidator.reason);
    if (entry.spec.id === 'at.personalised' && entry.group('b').length + entry.group('c').length < 3) return invalid(AustriaValidator.reason);
    return valid;
  }
}
