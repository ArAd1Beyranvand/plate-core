import { type PlateEntry, type PlateValidation, type PlateValidator, invalid, restrictionVerdict, valid } from '../../core/validators/plate_validator';

/** Quiet until something is typed, then every field must reach its minimum and
 * obey the Manx rules: the first letter is never `A`, the middle two are
 * `MN`, the serial is one to three digits and the last letter is never `O`.
 * `I`, `Q`, `S` and `Z` are excluded by the alphabets. */
export class IsleOfManValidator implements PlateValidator {
  validate(entry: PlateEntry): PlateValidation {
    const refused = restrictionVerdict(entry);
    if (refused !== null) return refused;
    if (entry.values.every((v) => v === null || v === '')) return valid;
    for (const g of entry.spec.effectiveTextGroups) {
      for (const i of g.indices) {
        const slot = entry.spec.slotAt(i);
        const value = i < entry.values.length ? (entry.values[i] ?? '') : '';
        if (slot !== null && !slot.isComplete(value)) {
          return invalid(`The ${g.key ?? 'field'} is incomplete.`);
        }
        if (g.key === 'prefix') {
          if (value.startsWith('A')) {
            return invalid('The first letter is never A.');
          }
          if (value.slice(1) !== 'MN') {
            return invalid('The prefix is a letter followed by MN.');
          }
        }
      }
    }
    return valid;
  }
}
