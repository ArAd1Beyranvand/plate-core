import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, valid } from '../../core/validators/plate_validator';

/**
 * Checks completeness, and flags 4 as the leading class digit on regional
 * plates: class prefixes run 1-7 and skip 4.
 */
export class KPValidator extends GatedPlateValidator {
  readonly gateGroup: string;

  constructor(o: { readonly gateGroup?: string } = {}) {
    super();
    this.gateGroup = o.gateGroup ?? 'number';
  }

  static readonly reasonIncomplete = 'Every position must be filled.';
  static readonly reasonFour = 'Class codes never start with 4.';

  judge(entry: PlateEntry): PlateValidation {
    for (let i = 0; i < entry.spec.slots.length; i++) {
      const slot = entry.spec.slots[i];
      const value = entry.values[i] ?? '';
      // A chosen value (the region) is one symbol, however many characters.
      const want = slot.alphabet.input === 'chosen' ? 1 : slot.length;
      if (value === '' || (want > 1 && value.length !== want)) return invalid(KPValidator.reasonIncomplete);
    }
    if (entry.group('class').startsWith('4')) return invalid(KPValidator.reasonFour);
    return valid;
  }
}
