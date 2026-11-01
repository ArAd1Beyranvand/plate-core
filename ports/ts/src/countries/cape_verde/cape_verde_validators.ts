import { type PlateEntry, type PlateValidation, type PlateValidator, invalid, restrictionVerdict, valid } from '../../core/validators/plate_validator';

/**
 * Judges a plate by whichever registers its spec has (`AB-12-CD`,
 * `ST-16-KD-G`, `FA-12-34`, `CD-12-345`). Quiet until the last register has
 * something in it. Reports, never bars a keystroke.
 */
export class CapeVerdeValidator implements PlateValidator {
  static readonly islands: ReadonlySet<string> = new Set(['BR', 'BV', 'FG', 'MA', 'SA', 'SL', 'SN', 'ST', 'SV']);

  private static readonly shape: Record<string, readonly [RegExp, string]> = {
    series: [/^[A-Z]{2}$/, 'The island code is 2 letters.'],
    number: [/^[0-9]{2}$/, 'The number is 2 digits.'],
    letters: [/^[A-Z]{2}$/, 'The closing series is 2 letters.'],
    suffix: [/^[A-Z]$/, 'The suffix is 1 letter.'],
    first: [/^[0-9]{2}$/, 'The first number is 2 digits.'],
    second: [/^[0-9]{2}$/, 'The second number is 2 digits.'],
    country: [/^[0-9]{2}$/, 'The country code is 2 digits.'],
    serial: [/^[0-9]{3}$/, 'The serial is 3 digits.'],
  };

  validate(entry: PlateEntry): PlateValidation {
    const refused = restrictionVerdict(entry);
    if (refused !== null) return refused;
    const groups = entry.spec.textGroups;
    if (groups.length === 0 || entry.group(groups[groups.length - 1].key!) === '') return valid;
    for (const g of groups) {
      const rule = Object.hasOwn(CapeVerdeValidator.shape, g.key!) ? CapeVerdeValidator.shape[g.key!] : undefined;
      if (rule && !rule[0].test(entry.group(g.key!))) return invalid(rule[1]);
    }
    if (entry.spec.id === 'cv.regular' && !CapeVerdeValidator.islands.has(entry.group('series'))) return invalid('Unknown island code.');
    return valid;
  }
}
