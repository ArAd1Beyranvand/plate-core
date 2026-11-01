import { type PlateEntry, type PlateValidation, type PlateValidator, invalid, restrictionVerdict, valid } from '../../core/validators/plate_validator';

/** Judges a Senegalese plate field by field: the 1989–2019 `DK-1234-AB`, the
 * current `AA-123-BC [DK / 01]`. Quiet until the last field has something in
 * it. Reports, never bars a keystroke. */
export class SenegalValidator implements PlateValidator {
  /** The regional codes: Dakar, Diourbel, Fatick, Kaffrine, Kaolack,
   * Kédougou, Kolda, Louga, Matam, Saint-Louis, Sédhiou, Tambacounda, Thiès,
   * Ziguinchor. */
  static readonly regions: ReadonlySet<string> = new Set(['DK', 'DB', 'FK', 'KA', 'KL', 'KE', 'KD', 'LG', 'MT', 'SL', 'SE', 'TC', 'TH', 'ZG']);

  private static readonly _letters2 = /^[A-Z]{2}$/;
  private static readonly _letters1or2 = /^[A-Z]{1,2}$/;
  private static readonly _digits2 = /^[0-9]{2}$/;
  private static readonly _digits3 = /^[0-9]{3}$/;
  private static readonly _digits4 = /^[0-9]{4}$/;

  validate(entry: PlateEntry): PlateValidation {
    const refused = restrictionVerdict(entry);
    if (refused !== null) return refused;
    const groups = entry.spec.textGroups;
    if (groups.length === 0 || entry.group(groups[groups.length - 1].key!) === '') return valid;
    const old = entry.spec.id === 'sn.old';
    for (const g of groups) {
      const value = entry.group(g.key!);
      let rule: [RegExp, string] | null = null;
      switch (g.key) {
        case 'number':
          rule = old ? [SenegalValidator._digits4, 'The number is 4 digits.'] : [SenegalValidator._digits3, 'The number is 3 digits.'];
          break;
        case 'letters':
          rule = old
            ? [SenegalValidator._letters1or2, 'The closing series is 1 or 2 letters.']
            : [SenegalValidator._letters2, 'The closing series is 2 letters.'];
          break;
        case 'series':
          rule = [SenegalValidator._letters2, 'The series is 2 letters.'];
          break;
        case 'department':
          rule = [SenegalValidator._digits2, 'The department is 2 digits.'];
          break;
      }
      if (rule !== null && !rule[0].test(value)) return invalid(rule[1]);
    }
    return SenegalValidator.regions.has(entry.group('region')) ? valid : invalid('Unknown regional code.');
  }
}
