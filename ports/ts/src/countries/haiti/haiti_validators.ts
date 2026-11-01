import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, valid } from '../../core/validators/plate_validator';

/** Judges a Haitian registration field by field against the lengths the spec's
 * slots give: letters on a plate that has them, then four or five digits.
 * Quiet until the number has something in it. Reports, never bars a keystroke. */
export class HaitiValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';

  judge(entry: PlateEntry): PlateValidation {
    for (const g of entry.spec.textGroups) {
      const key = g.key!;
      const slot = entry.spec.slots[entry.spec.indicesOfGroup(key)[0]];
      const value = entry.group(key);
      const kind = key === 'series' ? 'letters' : 'digits';
      const fits =
        value.length >= slot.minLength &&
        value.length <= slot.length &&
        value.split('').every((char) => slot.alphabet.accepts(char));
      if (!fits) {
        return invalid(
          slot.minLength === slot.length
            ? `The ${key} is ${slot.length} ${kind}.`
            : `The ${key} is ${slot.minLength} to ${slot.length} ${kind}.`,
        );
      }
    }
    return valid;
  }
}
