import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, valid } from '../../core/validators/plate_validator';

/** The first letter of a plate names the town or district of registration. */
const regionCodes = new Set(['A', 'B', 'E', 'K', 'P', 'C', 'T', 'H']);

/** Judges a Transnistrian registration: each field the right length and
 * alphabet, and the region letter one of the district letters. Reports,
 * never bars a keystroke. */
export class TransnistriaValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonField = 'A field has the wrong length or letters.';
  static readonly reasonRegion = 'The region letter is not in use.';

  judge(entry: PlateEntry): PlateValidation {
    const spec = entry.spec;
    for (let i = 0; i < spec.slots.length; i++) {
      const slot = spec.slots[i];
      const value = entry.group(spec.textGroups[i].key!);
      if (!slot.accepts(value) || value.length < slot.minLength || value.length > slot.length) {
        return invalid(TransnistriaValidator.reasonField);
      }
    }
    const region = entry.group('region');
    if (region !== '' && !regionCodes.has(region)) {
      return invalid(TransnistriaValidator.reasonRegion);
    }
    return valid;
  }
}
