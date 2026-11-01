import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigits, valid } from '../../core/validators/plate_validator';

/**
 * Judges a `BonairePlates.bonaire` or `.blue` value: a one- or two-letter
 * type prefix and three to five digits (`V-5169`, `MF-630`). Reports, never
 * bars a keystroke.
 */
export class BonaireValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';

  private static readonly prefix = /^[A-Z]{1,2}$/;

  static readonly reasonPrefix = 'The prefix is one or two letters.';
  static readonly reasonNumber = 'The number is three to five digits.';

  judge(entry: PlateEntry): PlateValidation {
    if (!BonaireValidator.prefix.test(entry.group('prefix'))) return invalid(BonaireValidator.reasonPrefix);
    const number = entry.group('number');
    if (number.length < 3 || number.length > 5 || !isDigits(number)) return invalid(BonaireValidator.reasonNumber);
    return valid;
  }
}

/**
 * Judges a St. Eustatius or Saba value: the island letter (`E` or `S`) and
 * up to four digits. The St. Eustatius photo shows two digits (`E 30`); the
 * picture wins over the article's "three or four", so one is accepted there.
 */
export class BonaireIslandValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';

  readonly island: string;
  readonly minDigits: number;

  constructor({ island, minDigits = 1 }: { island: string; minDigits?: number }) {
    super();
    this.island = island;
    this.minDigits = minDigits;
  }

  static readonly reasonNumber = 'The number is up to four digits.';

  get reasonIsland(): string {
    return `The prefix is ${this.island}.`;
  }

  judge(entry: PlateEntry): PlateValidation {
    if (entry.group('prefix') !== this.island) return invalid(this.reasonIsland);
    const number = entry.group('number');
    if (number.length < this.minDigits || number.length > 4 || !isDigits(number)) return invalid(BonaireIslandValidator.reasonNumber);
    return valid;
  }
}
