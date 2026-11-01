import { GatedPlateValidator, type PlateEntry, type PlateValidation, type PlateValidator, invalid, isDigits, isDigitsOfLength, restrictionVerdict, valid } from '../../core/validators/plate_validator';

/** Judges an Ivorian plate field by field. Quiet until the last field has something in it. Reports, never bars a keystroke. */
export class IvoryCoastValidator implements PlateValidator {
  validate(entry: PlateEntry): PlateValidation {
    const refused = restrictionVerdict(entry);
    if (refused !== null) return refused;
    const groups = entry.spec.textGroups;
    if (groups.length === 0 || entry.group(groups[groups.length - 1].key!) === '') return valid;
    const id = entry.spec.id;
    for (const g of groups) {
      const rule: readonly [RegExp, string] | null =
        g.key === 'number'
          ? id === 'ci.private'
            ? [/^[0-9]{4}$/, 'The number is 4 digits.']
            : id === 'ci.military'
              ? [/^[0-9]{5}$/, 'The number is 5 digits.']
              : [/^[0-9]{3}$/, 'The number is 3 digits.']
          : g.key === 'series'
            ? [/^[A-Z]{2}$/, 'The series is 2 letters.']
            : g.key === 'region'
              ? [/^[0-9]{2}$/, 'The region code is 2 digits.']
              : null;
      if (rule !== null && !rule[0].test(entry.group(g.key!))) return invalid(rule[1]);
    }
    return valid;
  }
}
