import { PlateValidator, type PlateEntry, type PlateValidation, invalid, valid } from '../../core/validators/plate_validator';

/** Every field at least at its minimum length. The article gives no rule beyond the format, and the
 * letter list is incomplete, so nothing else is judged. */
export class OmanPlateValidator implements PlateValidator {
  validate(entry: PlateEntry): PlateValidation {
    const refused = restrictionVerdict(entry);
    if (refused != null) return refused;
    for (const g of entry.spec.textGroups) {
      const key = g.key;
      if (key == null) continue;
      for (const i of g.indices) {
        if (!entry.spec.slots[i].isComplete(entry.values[i])) {
          return invalid(`The ${key} is incomplete.`);
        }
      }
    }
    return valid;
  }
}

function restrictionVerdict(entry: PlateEntry): PlateValidation | null {
  return null;
}
