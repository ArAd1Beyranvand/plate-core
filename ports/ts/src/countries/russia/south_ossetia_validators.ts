import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, valid } from '../../core/validators/plate_validator';

/** Judges a South Ossetian registration: each field the right length and
 * alphabet. Reports, never bars a keystroke. */
export class SouthOssetiaValidator extends GatedPlateValidator {
  readonly gateGroup = 'series';

  static readonly reasonField = 'A field has the wrong length or letters.';

  judge(entry: PlateEntry): PlateValidation {
    const spec = entry.spec;
    for (let i = 0; i < spec.slots.length; i++) {
      const slot = spec.slots[i];
      const value = entry.group(spec.textGroups[i].key!);
      if (!slot.accepts(value) ||
          value.length < slot.minLength ||
          value.length > slot.length) {
        return invalid(SouthOssetiaValidator.reasonField);
      }
    }
    return valid;
  }
}
