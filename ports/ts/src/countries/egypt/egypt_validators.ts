import { GatedPlateValidator, type PlateEntry, type PlateValidation, type PlateValidator, invalid, isDigits, isDigitsOfLength, restrictionVerdict, valid } from '../../core/validators/plate_validator';

const plateLetters = 'ABGDRSCTEFKLMNHWY';

/**
 * Judges a plate by the length of each register. Reports, never bars a
 * keystroke.
 *
 * The groups `digits` and `code` are numerals; any other group is letters
 * from the seventeen plate letters. Digit values are not checked.
 */
export class EgyptValidator extends GatedPlateValidator {
  /** Group key to the number of cells it must hold. */
  readonly lengths: ReadonlyMap<string, number>;

  constructor({ lengths }: { readonly lengths: readonly (readonly [string, number])[] }) {
    super();
    this.lengths = new Map(lengths);
  }

  static readonly car = new EgyptValidator({ lengths: [['digits', 4], ['letters', 3]] });
  static readonly cairo = new EgyptValidator({ lengths: [['digits', 3], ['letters', 3]] });
  static readonly giza = new EgyptValidator({ lengths: [['digits', 4], ['letters', 2]] });
  static readonly diplomatic = new EgyptValidator({ lengths: [['digits', 3], ['code', 2]] });
  static readonly police = new EgyptValidator({ lengths: [['digits', 4], ['code', 2], ['letters', 1]] });
  static readonly motorcycle = new EgyptValidator({ lengths: [['letters', 3], ['digits', 4]] });

  readonly gateGroup = 'digits';

  static reasonFor(group: string, length: number): string {
    return group === 'letters' ? `The letters are ${length} of the 17 plate letters.` : `The ${group} is ${length} digits.`;
  }

  judge(entry: PlateEntry): PlateValidation {
    for (const [key, length] of this.lengths) {
      const value = entry.group(key);
      const ok = key === 'letters' ? value.length === length && [...value].every((c) => plateLetters.includes(c)) : isDigitsOfLength(value, length);
      if (!ok) return invalid(EgyptValidator.reasonFor(key, length));
    }
    return valid;
  }
}
