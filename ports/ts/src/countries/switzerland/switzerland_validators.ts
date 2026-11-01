import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigits, valid } from '../../core/validators/plate_validator';

/** The 26 cantons' two-letter codes. */
export const switzerlandCantons: readonly string[] = [
  'AG', 'AI', 'AR', 'BE', 'BL', 'BS', 'FR', 'GE', 'GL', 'GR', 'JU', 'LU', 'NE',
  'NW', 'OW', 'SG', 'SH', 'SO', 'SZ', 'TG', 'TI', 'UR', 'VD', 'VS', 'ZG', 'ZH',
];

const refusedCodes = ['7', '07', '007'];
const notFound = 'COUNTRY NOT FOUND';

const isPlain = (s: string): boolean => isDigits(s) && !s.startsWith('0');

/** Judges a canton-and-number plate (`SwitzerlandPlates.high`, `long`,
 * `front`, `dealer`, `temporary`, `customs`, `motorcycle`, `scooter`).
 * Reports, never bars a keystroke; gated on the number.
 *
 * The canton is one of `switzerlandCantons` (a `military` plate may instead
 * open with a lone `M`), and the number is digits with no leading zero, at
 * most as long as the number slot. The registry also issues no number 0. */
export class SwitzerlandValidator extends GatedPlateValidator {
  /** Whether a lone `M` is a legal canton field. */
  readonly military: boolean;

  constructor({ military = false }: { military?: boolean } = {}) {
    super();
    this.military = military;
  }

  readonly gateGroup = 'number';

  static readonly reasonCanton = 'The canton is a Swiss canton code.';
  static readonly reasonNumber = 'The number is digits without a leading 0.';

  judge(entry: PlateEntry): PlateValidation {
    const canton = entry.group('canton');
    if (!switzerlandCantons.includes(canton) && !(this.military && canton === 'M')) {
      return invalid(SwitzerlandValidator.reasonCanton);
    }
    return isPlain(entry.group('number')) ? valid : invalid(SwitzerlandValidator.reasonNumber);
  }
}

/** Judges a `SwitzerlandPlates.diplomatic` or `consular` value: a canton, a
 * serial and a country code, none with a leading zero. Code 7 is refused on
 * its own account as well, so it holds even against a spec built without
 * SwitzerlandMissions.restriction. */
export class SwitzerlandDiplomaticValidator extends GatedPlateValidator {
  readonly gateGroup = 'code';

  static readonly reasonSerial = 'The serial is one to three digits.';
  static readonly reasonCode = 'The code is one to three digits.';

  override validate(entry: PlateEntry): PlateValidation {
    if (refusedCodes.includes(entry.group('code'))) {
      return invalid(notFound);
    }
    return super.validate(entry);
  }

  judge(entry: PlateEntry): PlateValidation {
    if (!switzerlandCantons.includes(entry.group('canton'))) {
      return invalid(SwitzerlandValidator.reasonCanton);
    }
    if (!isPlain(entry.group('serial'))) {
      return invalid(SwitzerlandDiplomaticValidator.reasonSerial);
    }
    if (!isPlain(entry.group('code'))) {
      return invalid(SwitzerlandDiplomaticValidator.reasonCode);
    }
    return valid;
  }
}
