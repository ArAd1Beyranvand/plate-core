import { GatedPlateValidator, type PlateEntry, type PlateValidation, type PlateValidator, invalid, isDigits, isDigitsOfLength, restrictionVerdict, valid } from '../../core/validators/plate_validator';

/**
 * Judges an Eswatini plate field by field: `JSD 884 BM` — a letter and the
 * fixed `SD`, three digits, then a letter and the region's initial. Quiet
 * until the last field has something in it. Reports, never bars a keystroke.
 */
export class EswatiniValidator implements PlateValidator {
  /** Region initials: Hhohho, Lubombo, Manzini, Shiselweni. */
  static readonly regions: ReadonlySet<string> = new Set(['H', 'L', 'M', 'S']);

  validate(entry: PlateEntry): PlateValidation {
    const refused = restrictionVerdict(entry);
    if (refused !== null) return refused;
    const suffix = entry.group('suffix');
    if (suffix === '') return valid;
    if (!/^[A-Z]SD$/.test(entry.group('series'))) return invalid('The series is a letter then SD.');
    if (!/^[0-9]{3}$/.test(entry.group('number'))) return invalid('The number is 3 digits.');
    if (!/^[A-Z]{2}$/.test(suffix)) return invalid('The suffix is 2 letters.');
    if (!EswatiniValidator.regions.has(suffix[1])) return invalid('Unknown region letter.');
    return valid;
  }
}
