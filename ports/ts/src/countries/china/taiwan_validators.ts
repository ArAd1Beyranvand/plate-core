import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, valid } from '../../core/validators/plate_validator';

/** 2014 series: three letters (no I, O) then four digits. */
export class TaiwanValidator extends GatedPlateValidator {
  readonly gateGroup = 'digits';

  static readonly reasonField = 'Three letters and four digits.';

  judge(entry: PlateEntry): PlateValidation {
    const spec = entry.spec;
    for (let i = 0; i < spec.slots.length; i++) {
      const slot = spec.slots[i];
      const v = entry.group(spec.textGroups[i].key!);
      if (!slot.accepts(v) || v.length !== slot.length) {
        return invalid(TaiwanValidator.reasonField);
      }
    }
    return valid;
  }
}

/** 1992 series: two letters then four digits; the slot lengths already say so. */
export class TaiwanLegacyValidator extends TaiwanValidator {
  readonly gateGroup = 'digits';
}

/** Embassy and foreign-affairs plates: the glyph then [minDigits]–[maxDigits] digits. */
export class TaiwanProtocolValidator extends GatedPlateValidator {
  readonly minDigits: number;
  readonly maxDigits: number;

  constructor({ minDigits = 2, maxDigits = 3 }: { minDigits?: number; maxDigits?: number }) {
    super();
    this.minDigits = minDigits;
    this.maxDigits = maxDigits;
  }

  readonly gateGroup = 'digits';

  static readonly reasonDigits = 'The number has the wrong length.';

  judge(entry: PlateEntry): PlateValidation {
    const v = entry.group('digits');
    if (!entry.spec.slots[0].accepts(v) ||
        v.length < this.minDigits ||
        v.length > this.maxDigits) {
      return invalid(TaiwanProtocolValidator.reasonDigits);
    }
    return valid;
  }
}
