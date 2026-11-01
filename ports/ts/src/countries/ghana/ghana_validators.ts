import { GatedPlateValidator, type PlateEntry, type PlateValidation, type PlateValidator, invalid, isDigits, isDigitsOfLength, restrictionVerdict, valid } from '../../core/validators/plate_validator';

/**
 * Judges a Ghanaian plate field by field: region code, one to four digits,
 * two-digit year (`AS 2567-12`, `CR 1-09`). The motorcycle plate leads with
 * `M` and the year (`M-10-AS 1620`). Quiet until the last field has
 * something in it. Reports, never bars a keystroke.
 */
export class GhanaValidator implements PlateValidator {
  /** Region codes from the article. The services print their own (`GA`, `GP`, `FS`, `PS`) and `FZB` is the Free Zones Board's. */
  static readonly regions: ReadonlySet<string> = new Set([
    'AC', 'AE', 'AK', 'AP', 'AS', 'AW',
    'BA', 'BR', 'BW', 'BT', 'CR',
    'EN', 'ER', 'ES',
    'GB', 'GC', 'GE', 'GG', 'GH', 'GL', 'GM', 'GN', 'GT', 'GS', 'GW', 'GX', 'GY',
    'NR', 'UE', 'UW', 'VA', 'VD', 'VR', 'WR', 'WT',
    'GA', 'GP', 'FS', 'PS',
  ]);

  private static readonly rules: Record<string, readonly [RegExp, string]> = {
    number: [/^[0-9]{1,4}$/, 'The number is 1 to 4 digits.'],
    year: [/^[0-9]{2}$/, 'The year is 2 digits.'],
    class: [/^M$/, 'A motorcycle plate starts with M.'],
  };

  validate(entry: PlateEntry): PlateValidation {
    const refused = restrictionVerdict(entry);
    if (refused !== null) return refused;
    const groups = entry.spec.textGroups;
    if (groups.length === 0 || entry.group(groups[groups.length - 1].key!) === '') return valid;
    for (const g of groups) {
      const rule = Object.hasOwn(GhanaValidator.rules, g.key!) ? GhanaValidator.rules[g.key!] : undefined;
      if (rule && !rule[0].test(entry.group(g.key!))) return invalid(rule[1]);
    }
    return GhanaValidator.regions.has(entry.group('region')) ? valid : invalid('Unknown region code.');
  }
}
