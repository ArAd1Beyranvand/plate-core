import { PlateValidator, type PlateEntry, type PlateValidation, invalid, isDigits, restrictionVerdict, valid } from '../../core/validators/plate_validator';

/** One field's rule: letters or digits, `min` to `max` of them. */
export class _Rule {
  readonly key: string;
  readonly digits: boolean;
  readonly min: number;
  readonly max: number;

  constructor(key: string, { digits, min, max }: { digits: boolean; min: number; max?: number }) {
    this.key = key;
    this.digits = digits;
    this.min = min;
    this.max = max ?? min;
  }
}

/** Judges a Luxembourg plate field by field. Reports, never bars a keystroke.
 *
 * Standard plates are two letters and four digits (leading zeros allowed);
 * diplomatic plates `CD` and two pairs of digits; military plates four
 * digits. */
export class LuxembourgValidator implements PlateValidator {
  static readonly reasonLength = 'A field has the wrong number of symbols.';
  static readonly reasonKind = 'A field mixes letters and digits.';

  static readonly _rules: Record<string, _Rule[]> = {
    'lu.standard': [
      new _Rule('letters', { digits: false, min: 2 }),
      new _Rule('serial', { digits: true, min: 4 }),
    ],
    'lu.diplomatic': [
      new _Rule('series', { digits: true, min: 2 }),
      new _Rule('serial', { digits: true, min: 2 }),
    ],
    'lu.military': [
      new _Rule('serial', { digits: true, min: 4 }),
    ],
  };

  validate(entry: PlateEntry): PlateValidation {
    const refused = restrictionVerdict(entry);
    if (refused !== null) return refused;
    const rules = LuxembourgValidator._rules[entry.spec.id] ?? [];
    if (rules.every((r) => entry.group(r.key).length === 0)) {
      return valid;
    }
    for (const r of rules) {
      const v = entry.group(r.key);
      if (v.length < r.min || v.length > r.max) {
        return invalid(LuxembourgValidator.reasonLength);
      }
      const hasDigit = v.split('').some((u) => u.charCodeAt(0) >= 0x30 && u.charCodeAt(0) <= 0x39);
      if (r.digits ? !isDigits(v) : hasDigit) {
        return invalid(LuxembourgValidator.reasonKind);
      }
    }
    return valid;
  }
}
