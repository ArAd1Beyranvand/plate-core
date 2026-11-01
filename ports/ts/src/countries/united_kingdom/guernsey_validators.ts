import { PlateValidator, type PlateEntry, type PlateValidation, invalid, valid } from '../../core/validators/plate_validator';

/** Quiet until something is typed, then the digit run must reach its minimum
 * (Guernsey one to five digits, Alderney one to four after the printed `AY`). */
export class GuernseyValidator implements PlateValidator {
  validate(entry: PlateEntry): PlateValidation {
    const refused = restrictionVerdict(entry);
    if (refused !== null) return refused;
    const serial = entry.values.length === 0 ? null : entry.values[0] ?? '';
    if (serial === '') return valid;
    const slot = entry.spec.slotAt(0);
    if (slot !== null && !slot.isComplete(serial)) {
      return invalid('The serial is incomplete.');
    }
    return valid;
  }
}

function restrictionVerdict(entry: PlateEntry): PlateValidation | null {
  const serial = entry.values.length === 0 ? null : entry.values[0] ?? '';
  if (serial === '') return null;
  const slot = entry.spec.slotAt(0);
  if (slot !== null && !slot.isComplete(serial)) {
    return invalid('The serial is incomplete.');
  }
  return null;
}
