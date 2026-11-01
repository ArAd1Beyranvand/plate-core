import { GatedPlateValidator, type PlateEntry, type PlateValidation, type PlateValidator, invalid, isDigits, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** One register of a Turkmen plate: its group, length, kind and, optionally, the values it may hold. */
export interface TurkmenistanPart {
  readonly group: string;
  readonly length: number;
  readonly digits: boolean;
  readonly allowed: readonly string[] | null;
}

const part = (group: string, length: number, { digits = false, allowed = null }: { digits?: boolean; allowed?: readonly string[] | null } = {}): TurkmenistanPart => ({ group, length, digits, allowed });

const accepts = (p: TurkmenistanPart, value: string): boolean =>
  new RegExp(`^${p.digits ? '[0-9]' : '[A-Z]'}{${p.length}}$`).test(value) && (p.allowed === null || p.allowed.includes(value));

const reasonOf = (p: TurkmenistanPart): string =>
  p.allowed !== null ? `The ${p.group} is one of ${p.allowed.join(', ')}.` : `The ${p.group} is ${p.length} ${p.digits ? 'digits' : 'letters'}.`;

const province = part('region', 2, { allowed: ['AG', 'AH', 'AK', 'BN', 'DZ', 'LB', 'MR'] });
const privateParts = [part('series', 2), part('number', 4, { digits: true }), province];

/** Judges a Turkmen plate register by register; `parts` says which, defaulting to the private plate. Reports, never bars a keystroke. */
export class TurkmenistanValidator extends GatedPlateValidator {
  readonly parts: readonly TurkmenistanPart[];

  constructor({ parts = privateParts }: { readonly parts?: readonly TurkmenistanPart[] } = {}) {
    super();
    this.parts = parts;
  }

  static readonly classic = new TurkmenistanValidator({ parts: [part('series', 1), part('first', 2, { digits: true }), part('second', 2, { digits: true }), province] });
  static readonly trailer = new TurkmenistanValidator({ parts: [part('series', 2), part('number', 4, { digits: true }), part('letters', 2)] });
  static readonly foreign = new TurkmenistanValidator({ parts: [part('class', 1, { digits: true }), part('letter', 1, { allowed: ['H'] }), part('number', 5, { digits: true })] });
  static readonly foreignTrailer = new TurkmenistanValidator({ parts: [part('class', 1, { digits: true }), part('letters', 2, { allowed: ['HT'] }), part('number', 4, { digits: true })] });
  static readonly export = new TurkmenistanValidator({ parts: [part('letters', 3), part('number', 4, { digits: true })] });
  static readonly diplomatic = new TurkmenistanValidator({ parts: [part('embassy', 2, { digits: true }), part('letters', 2, { allowed: ['CD'] }), part('number', 3, { digits: true })] });
  static readonly government = new TurkmenistanValidator({ parts: [part('number', 4, { digits: true }), part('letters', 3)] });
  static readonly military = new TurkmenistanValidator({ parts: [part('number', 4, { digits: true }), part('letters', 2)] });
  static readonly ceremony = new TurkmenistanValidator({ parts: [part('letters', 6), part('number', 1, { digits: true })] });

  get gateGroup(): string {
    return this.parts[this.parts.length - 1].group;
  }

  judge(entry: PlateEntry): PlateValidation {
    const bad = this.parts.find((p) => !accepts(p, entry.group(p.group)));
    return bad === undefined ? valid : invalid(reasonOf(bad));
  }
}
