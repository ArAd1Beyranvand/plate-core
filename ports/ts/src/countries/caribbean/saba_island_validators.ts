import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigits, valid } from '../../core/validators/plate_validator';

/**
 * Judges a Saba value: one prefix letter and a run of digits. The 2011 plate
 * is `S 240` (three or four digits; the article's `R` and `D` prefixes mark
 * other vehicle types), the 1978 plate `S-163` (up to three). Reports, never
 * bars a keystroke.
 */
export class SabaIslandValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';

  readonly minDigits: number;
  readonly maxDigits: number;

  constructor({ minDigits = 3, maxDigits = 4 }: { minDigits?: number; maxDigits?: number } = {}) {
    super();
    this.minDigits = minDigits;
    this.maxDigits = maxDigits;
  }

  /** The 1978 plate: `S-123`, one to three digits. */
  static classic1978 = () => new SabaIslandValidator({ minDigits: 1, maxDigits: 3 });

  private static readonly prefix = /^[SRD]$/;

  static readonly reasonPrefix = 'The prefix is S, R or D.';

  get reasonNumber(): string {
    return this.minDigits === this.maxDigits ? `The number is ${this.maxDigits} digits.` : `The number is ${this.minDigits} to ${this.maxDigits} digits.`;
  }

  judge(entry: PlateEntry): PlateValidation {
    if (!SabaIslandValidator.prefix.test(entry.group('prefix'))) return invalid(SabaIslandValidator.reasonPrefix);
    const number = entry.group('number');
    if (number.length < this.minDigits || number.length > this.maxDigits || !isDigits(number)) return invalid(this.reasonNumber);
    return valid;
  }
}
