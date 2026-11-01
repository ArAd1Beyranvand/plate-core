import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigits, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

export type GeorgiaFieldKind = 'digits' | 'letters' | 'alphanumeric';

const kindPattern: Record<GeorgiaFieldKind, RegExp> = { digits: /^[0-9]*$/, letters: /^[A-Z]*$/, alphanumeric: /^[0-9A-Z]*$/ };

/** One field's rule: its kind and its length range. */
export interface GeorgiaFieldRule {
  readonly key: string;
  readonly kind: GeorgiaFieldKind;
  readonly min: number;
  readonly max: number;
}

const accepts = (r: GeorgiaFieldRule, value: string): boolean => value.length >= r.min && value.length <= r.max && kindPattern[r.kind].test(value);

const rule = (key: string, kind: GeorgiaFieldKind, min: number, max = min): GeorgiaFieldRule => ({ key, kind, min, max });

/**
 * Judges a Georgian plate field by field; reports, never bars a keystroke.
 * Quiet until the last field has content, and an embassy plate's refused
 * mission code is reported first (see `GeorgiaCountryMissions`).
 */
export class GeorgiaCountryValidator extends GatedPlateValidator {
  readonly rules: readonly GeorgiaFieldRule[];

  constructor({ rules }: { readonly rules: readonly GeorgiaFieldRule[] }) {
    super();
    this.rules = rules;
  }

  get gateGroup(): string {
    return this.rules[this.rules.length - 1].key;
  }

  /** `AB-123-CD`. */
  static readonly private = new GeorgiaCountryValidator({ rules: [rule('prefix', 'letters', 2), rule('serial', 'digits', 3), rule('suffix', 'letters', 2)] });
  /** `AA-123-A`. */
  static readonly trailer = new GeorgiaCountryValidator({ rules: [rule('prefix', 'letters', 2), rule('serial', 'digits', 3), rule('suffix', 'letters', 1)] });
  /** `GP-5891`: the article says the letters are `GA GE GG GC GP`. */
  static readonly temporary = new GeorgiaCountryValidator({ rules: [rule('prefix', 'letters', 2), rule('serial', 'digits', 4)] });
  static readonly vanity = new GeorgiaCountryValidator({ rules: [rule('text', 'alphanumeric', 1, 7)] });
  /** `AA` over `1234`. */
  static readonly motorcycle = new GeorgiaCountryValidator({ rules: [rule('prefix', 'letters', 2), rule('serial', 'digits', 4)] });
  /** `0092 04 AK`. */
  static readonly export = new GeorgiaCountryValidator({ rules: [rule('serial', 'digits', 4), rule('year', 'digits', 2), rule('suffix', 'letters', 2)] });
  /** `5045 AT`. */
  static readonly transit = new GeorgiaCountryValidator({ rules: [rule('serial', 'digits', 4), rule('suffix', 'letters', 2)] });
  /** `EUMM 085`. */
  static readonly mission = new GeorgiaCountryValidator({ rules: [rule('prefix', 'letters', 4), rule('serial', 'digits', 3)] });
  /** `AD 217`. */
  static readonly military = new GeorgiaCountryValidator({ rules: [rule('prefix', 'letters', 2), rule('serial', 'digits', 3)] });
  /** `004 CMD 001`: a three-digit mission code, `CMD`, `D` or `AS`, a serial. */
  static readonly diplomatic = new GeorgiaCountryValidator({ rules: [rule('mission', 'digits', 3), rule('kind', 'letters', 1, 3), rule('serial', 'digits', 3)] });

  static readonly reason = 'A field is the wrong length or has a wrong character for this plate.';

  judge(entry: PlateEntry): PlateValidation {
    return this.rules.every((r) => accepts(r, entry.group(r.key))) ? valid : invalid(GeorgiaCountryValidator.reason);
  }
}
