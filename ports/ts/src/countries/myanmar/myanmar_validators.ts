import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** The region codes of Table 2 and the highest township numeral each takes. */
export const myanmarRegions: Readonly<Record<string, number>> = {
  AYY: 26, BGO: 28, CHN: 9, KYH: 7, KCN: 18, KYN: 7, MGY: 25,
  MDY: 28, MON: 10, NPW: 8, RKE: 17, SGG: 37, SHN: 55, TNI: 10,
  YGN: 45,
};

/**
 * Judges a plate with a `region` group (`YGN-36`) and a four-digit `serial`.
 * Reports, never bars a keystroke. The township, where the plate has one, is
 * checked against its region's range.
 */
export class MyanmarValidator extends GatedPlateValidator {
  readonly gateGroup = 'region';

  static readonly reasonRegion = 'The region is not a Myanmar code.';
  static readonly reasonTownship = 'The township is out of range.';
  static readonly reasonSerial = 'The number is four digits.';

  judge(entry: PlateEntry): PlateValidation {
    const V = MyanmarValidator;
    const max = Object.hasOwn(myanmarRegions, entry.group('region')) ? myanmarRegions[entry.group('region')] : null;
    if (max === null) return invalid(V.reasonRegion);
    const township = entry.group('township').trim();
    if (township !== '') {
      const n = /^[+-]?[0-9]+$/.test(township) ? Number(township) : null;
      if (n === null || n < 1 || n > max) return invalid(V.reasonTownship);
    }
    if (!isDigitsOfLength(entry.group('serial'), 4)) return invalid(V.reasonSerial);
    return valid;
  }
}

/** Judges a Burmese-script motorcycle or rickshaw plate: three characters over five numerals. */
export class MyanmarBurmeseValidator extends GatedPlateValidator {
  readonly gateGroup = 'letters';

  static readonly reasonLetters = 'The top row is three characters.';
  static readonly reasonSerial = 'The number is five numerals.';

  judge(entry: PlateEntry): PlateValidation {
    if (entry.group('letters').length !== 3) return invalid(MyanmarBurmeseValidator.reasonLetters);
    if (!isDigitsOfLength(entry.group('serial'), 5)) return invalid(MyanmarBurmeseValidator.reasonSerial);
    return valid;
  }
}
