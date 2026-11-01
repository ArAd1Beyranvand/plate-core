import { type PlateEntry, type PlateValidation, type PlateValidator, invalid, isDigits, restrictionVerdict, valid } from '../../core/validators/plate_validator';

/** One field's rule: letters or digits, between `min` and `max` of them. */
interface Rule {
  readonly key: string;
  readonly digits: boolean;
  readonly min: number;
  readonly max: number;
}

const rule = (key: string, digits: boolean, min: number, max = min): Rule => ({ key, digits, min, max });

const threeFields = [rule('series', true, 1), rule('letters', false, 3), rule('serial', true, 3)];

const rules: Record<string, readonly Rule[]> = {
  'be.private': threeFields,
  'be.plain': threeFields,
  'be.motorcycle': [rule('series', false, 1), rule('letters', false, 3), rule('serial', true, 3)],
  'be.temporary': [rule('kind', false, 2), rule('number', true, 2), rule('letters', false, 3)],
  'be.vintage': [rule('series', true, 3), rule('serial', true, 3)],
  'be.diplomatic': [rule('letters', false, 2), rule('serial', true, 3)],
  'be.royal': [rule('number', true, 1, 2)],
  'be.military': [rule('serial', true, 5)],
};

/**
 * Judges a Belgian plate field by field. Reports, never bars a keystroke.
 *
 * A plate is judged once any field holds a character; every field must then
 * be of its kind and within its length. Standard plates are `1-ABC-123`;
 * dealers' start with Z and a second letter A to Y (ZZ is reserved).
 */
export class BelgiumValidator implements PlateValidator {
  static readonly reasonLength = 'A field has the wrong number of symbols.';
  static readonly reasonKind = 'A field mixes letters and digits.';
  static readonly reasonDealer = 'A dealer plate (first letter Z) has a second letter from A to Y.';

  validate(entry: PlateEntry): PlateValidation {
    const refused = restrictionVerdict(entry);
    if (refused !== null) return refused;
    const rs = rules[entry.spec.id] ?? [];
    if (rs.every((r) => entry.group(r.key) === '')) return valid;
    for (const r of rs) {
      const v = entry.group(r.key);
      if (v.length < r.min || v.length > r.max) return invalid(BelgiumValidator.reasonLength);
      if (r.digits ? !isDigits(v) : /[0-9]/.test(v)) return invalid(BelgiumValidator.reasonKind);
    }
    if (entry.spec.id === 'be.plain' && entry.group('letters').startsWith('ZZ')) return invalid(BelgiumValidator.reasonDealer);
    return valid;
  }
}
