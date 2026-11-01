import { type PlateEntry, type PlateValidation, type PlateValidator, invalid, restrictionVerdict, valid } from '../../core/validators/plate_validator';

/** Quiet until something is typed, then every field must reach its minimum
 * length. The `prefix` is `G`, or `GT` on a trailer plate. */
export class GibraltarValidator implements PlateValidator {
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
        if (g.key === 'prefix' && value !== 'G' && value !== 'GT') {
          return invalid('The prefix is G or GT.');
        }
        if (g.key === 'serial' && entry.spec.id === 'gi.private' && value.length === 4 && value.startsWith('0')) {
          return invalid('A four-digit serial runs 1000 to 9999.');
        }
      }
    }
    return valid;
  }
}
