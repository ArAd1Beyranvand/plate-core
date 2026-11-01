import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, valid } from '../../core/validators/plate_validator';

/** Six digits, the printed `NC` being fixed. */
export class NewCaledoniaValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';

  static readonly reasonDigits = 'The number must be six digits.';

  judge(entry: PlateEntry): PlateValidation {
    const v = entry.group('number');
    if (!entry.spec.slots[0].accepts(v) || v.length !== 6) {
      return invalid(NewCaledoniaValidator.reasonDigits);
    }
    return valid;
  }
}
