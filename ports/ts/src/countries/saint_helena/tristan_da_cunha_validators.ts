import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, valid } from '../../core/validators/plate_validator';

/** Every field must use its alphabet and fit its slot's length range. */
export class TristanDaCunhaValidator extends GatedPlateValidator {
  readonly gateGroup = 'digits';

  static readonly reasonField = 'A field has the wrong length or characters.';

  judge(entry: PlateEntry): PlateValidation {
    const spec = entry.spec;
    for (let i = 0; i < spec.slots.length; i++) {
      const slot = spec.slots[i];
      const v = entry.group(spec.textGroups[i].key!);
      if (!slot.accepts(v) || v.length < slot.minLength || v.length > slot.length) {
        return invalid(TristanDaCunhaValidator.reasonField);
      }
    }
    return valid;
  }
}
