import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, valid } from '../../core/validators/plate_validator';

/** Every field must use its alphabet and fit its slot's length range. */
export abstract class _SlotsValidator extends GatedPlateValidator {
  readonly gateGroup = 'digits';

  static readonly reasonField = 'A field has the wrong length or characters.';

  judge(entry: PlateEntry): PlateValidation {
    const spec = entry.spec;
    for (let i = 0; i < spec.slots.length; i++) {
      const slot = spec.slots[i];
      const v = entry.group(spec.textGroups[i].key!);
      if (!slot.accepts(v) || v.length < slot.minLength || v.length > slot.length) {
        return invalid(_SlotsValidator.reasonField);
      }
    }
    return valid;
  }
}

/** MA-12-34: a series of letters then two pairs of digits. */
export class MacauValidator extends _SlotsValidator {
  readonly gateGroup = 'digits';
}

/** CM-x dddd: two to five digits. */
export class MacauMopedValidator extends _SlotsValidator {
  readonly gateGroup = 'digits';
}

/** The Guangdong supplement: four characters, letters without I and O. */
export class MacauMainlandValidator extends _SlotsValidator {
  readonly gateGroup = 'digits';
}
