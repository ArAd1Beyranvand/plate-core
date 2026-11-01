import { type PlateEntry, type PlateValidation, type PlateValidator, invalid, restrictionVerdict, valid } from '../../core/validators/plate_validator';

/** Judges a South African plate field by field: `ABC 123 EC` and
 * `AB 12 CD GP`. Quiet until the last field has something in it. Reports,
 * never bars a keystroke. */
export class SouthAfricaValidator implements PlateValidator {
  /** Province suffixes. `L` is Limpopo; the Western Cape's `WP` and
   * KwaZulu-Natal's `ZN` are included, and `G`, `M`, `B` mark government,
   * defence-force and police vehicles. */
  static readonly provinces: ReadonlySet<string> = new Set(['EC', 'FS', 'GP', 'L', 'MP', 'NC', 'NW', 'WP', 'ZN', 'G', 'M', 'B']);

  private static readonly _letters3 = /^[A-Z]{3}$/;
  private static readonly _letters2 = /^[A-Z]{2}$/;
  private static readonly _digits1to3 = /^[0-9]{1,3}$/;
  private static readonly _digits2 = /^[0-9]{2}$/;

  validate(entry: PlateEntry): PlateValidation {
    const refused = restrictionVerdict(entry);
    if (refused !== null) return refused;
    const groups = entry.spec.textGroups;
    if (groups.length === 0 || entry.group(groups[groups.length - 1].key!) === '') return valid;
    const modern = entry.spec.id === 'za.modern';
    const { _letters2, _letters3, _digits1to3, _digits2 } = SouthAfricaValidator;
    for (const g of groups) {
      const value = entry.group(g.key!);
      let rule: [RegExp, string] | null = null;
      switch (g.key) {
        case 'series':
          rule = modern ? [_letters2, 'The series is 2 letters.'] : [_letters3, 'The series is 3 letters.'];
          break;
        case 'number':
          rule = modern ? [_digits2, 'The number is 2 digits.'] : [_digits1to3, 'The number is 1 to 3 digits.'];
          break;
        case 'letters':
          rule = [_letters2, 'The closing letters are 2 letters.'];
          break;
      }
      if (rule !== null && !rule[0].test(value)) return invalid(rule[1]);
    }
    return SouthAfricaValidator.provinces.has(entry.group('province')) ? valid : invalid('Unknown province suffix.');
  }
}
