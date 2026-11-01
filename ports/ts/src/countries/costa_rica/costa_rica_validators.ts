import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigits, valid } from '../../core/validators/plate_validator';

/**
 * One field of a plate: the text group it is read from, whether it is
 * letters or digits, and how many characters it holds.
 */
export interface CostaRicaField {
  readonly key: string;
  /** What the field is called in a verdict. */
  readonly name: string;
  readonly letters: boolean;
  readonly min: number;
  readonly max: number;
}

const field = (key: string, name: string, min: number, max = min, letters = false): CostaRicaField => ({ key, name, letters, min, max });

function accepts(f: CostaRicaField, value: string): boolean {
  if (value.length < f.min || value.length > f.max) return false;
  return f.letters ? /^[A-Z]+$/.test(value) : isDigits(value);
}

function reason(f: CostaRicaField): string {
  const kind = f.letters ? 'letters' : 'digits';
  return f.min === f.max ? `The ${f.name} is ${f.max} ${kind}.` : `The ${f.name} is ${f.min} to ${f.max} ${kind}.`;
}

/**
 * The fields of one design, in print order. The category's own letters
 * (`AB`, `TSJ`, `CD`, ...) are printed, not typed, so they are not fields.
 */
export const CostaRicaFormat = {
  /** `ABC-123`: private and electric. */
  private: [field('letters', 'series', 3, 3, true), field('number', 'number', 3)],
  /** `D-123` or `D-1234`. */
  disabled: [field('number', 'number', 3, 4)],
  /** Buses and taxis: `1234` or `12345`. */
  bus: [field('number', 'number', 4, 5)],
  /** Commercial, light-load truck and motorcycle: `123456`. */
  commercial: [field('number', 'number', 6)],
  /** Diplomatic corps and international mission: a two-digit code, `123`. */
  protocol: [field('code', 'code', 2), field('number', 'number', 3)],
  /** Power executive: a two-digit code, `1234`. */
  powerExecutive: [field('code', 'code', 2), field('number', 'number', 4)],
  /** Consular corps: `1-23`. */
  consular: [field('unit', 'first number', 1), field('number', 'second number', 2)],
  /** Official vehicle: `12-3456`. */
  official: [field('unit', 'first number', 2), field('number', 'second number', 4)],
  /** Historical vehicle: two, three or four digits. */
  historical: [field('number', 'number', 2, 4)],
} as const satisfies Record<string, readonly CostaRicaField[]>;

/** Judges a Costa Rican value against a format. Reports, never bars a keystroke. */
export class CostaRicaValidator extends GatedPlateValidator {
  readonly format: readonly CostaRicaField[];

  constructor({ format = CostaRicaFormat.private }: { format?: readonly CostaRicaField[] } = {}) {
    super();
    this.format = format;
  }

  get gateGroup(): string {
    return this.format[this.format.length - 1].key;
  }

  judge(entry: PlateEntry): PlateValidation {
    for (const f of this.format) if (!accepts(f, entry.group(f.key))) return invalid(reason(f));
    return valid;
  }
}
