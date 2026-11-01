import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, valid } from '../../core/validators/plate_validator';

/** Every field must use its alphabet and stay within its slot's length range. */
export class FrenchGuianaValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';

  static readonly reasonField = 'A field has the wrong length or characters.';

  judge(entry: PlateEntry): PlateValidation {
    const spec = entry.spec;
    for (let i = 0; i < spec.slots.length; i++) {
      const slot = spec.slots[i];
      const v = entry.group(spec.textGroups[i].key!);
      if (!slot.accepts(v) || v.length < slot.minLength || v.length > slot.length) {
        return invalid(FrenchGuianaValidator.reasonField);
      }
    }
    return valid;
  }
}
