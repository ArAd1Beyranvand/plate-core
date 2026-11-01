import { type PlateEntry, type PlateValidation, type PlateValidator, invalid, restrictionVerdict, valid } from '../../core/validators/plate_validator';

/** Quiet until something is typed, then every field must reach its
 * minimum length (the `SHG` prefix whole, the serial one digit). */
export class SaintHelenaValidator implements PlateValidator {
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
      }
    }
    return valid;
  }
}
