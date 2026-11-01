import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigits, valid } from '../../core/validators/plate_validator';

/** One digit field a [MoroccoValidator] checks: its text-group key and how many digits the plate takes. */
export interface MoroccoField {
  readonly group: string;
  readonly min: number;
  readonly max: number;
}

/**
 * Judges a Moroccan plate from its fields. Reports, never bars a keystroke.
 *
 * Checks that every digit field is digits within its length, that a
 * registration plate carries a series letter, and that a number is not all
 * zeros. Does not check which regions or series have been issued.
 */
export class MoroccoValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';
  readonly fields: readonly MoroccoField[];
  readonly requiresSeries: boolean;

  constructor(o: { readonly fields: readonly MoroccoField[]; readonly requiresSeries?: boolean }) {
    super();
    this.fields = o.fields;
    this.requiresSeries = o.requiresSeries ?? false;
  }

  static reasonFor(f: MoroccoField): string {
    return f.min === f.max ? `The ${f.group} is ${f.max} digits.` : `The ${f.group} is ${f.min} to ${f.max} digits.`;
  }
  static readonly reasonSeries = 'The series letter is missing.';
  static readonly reasonZero = 'The number cannot be all zeros.';

  judge(entry: PlateEntry): PlateValidation {
    for (const f of this.fields) {
      const v = entry.group(f.group);
      if (v.length < f.min || v.length > f.max || !isDigits(v)) return invalid(MoroccoValidator.reasonFor(f));
      if (v.replaceAll('0', '') === '') return invalid(MoroccoValidator.reasonZero);
    }
    if (this.requiresSeries && entry.group('series') === '') return invalid(MoroccoValidator.reasonSeries);
    return valid;
  }
}
