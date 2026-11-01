import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, valid } from '../../core/validators/plate_validator';

export interface PapuaNewGuineaLengths {
  readonly leadMin?: number;
  readonly leadMax?: number;
  readonly numberMin?: number;
  readonly numberMax?: number;
  /** The fixed prefix of the category, or null. */
  readonly leadStartsWith?: string | null;
}

/**
 * Judges `ABC 123` field by field: `lead` (letters) and `number` (digits).
 * Reports, never bars a keystroke.
 *
 * The lengths and the fixed prefix differ by category, so each plate has its
 * own constructor.
 */
export class PapuaNewGuineaValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';
  readonly leadMin: number;
  readonly leadMax: number;
  readonly numberMin: number;
  readonly numberMax: number;
  readonly leadStartsWith: string | null;

  constructor(o: PapuaNewGuineaLengths = {}) {
    super();
    this.leadMin = o.leadMin ?? 3;
    this.leadMax = o.leadMax ?? 3;
    this.numberMin = o.numberMin ?? 3;
    this.numberMax = o.numberMax ?? 3;
    this.leadStartsWith = o.leadStartsWith ?? null;
  }

  /** `BAA-000`. */
  static general = () => new PapuaNewGuineaValidator();
  /** `AA-000`. */
  static motorcycle = () => new PapuaNewGuineaValidator({ leadMin: 2, leadMax: 2 });
  /** `TR-0001`. */
  static trailer = () => new PapuaNewGuineaValidator({ leadMin: 2, leadMax: 2, numberMin: 4, numberMax: 4 });
  /** `T-0000`, then `T-00000` once 9999 was passed. */
  static taxi = () => new PapuaNewGuineaValidator({ leadMin: 1, leadMax: 1, numberMin: 4, numberMax: 5, leadStartsWith: 'T' });
  /** `H-0001`. */
  static hire = () => new PapuaNewGuineaValidator({ leadMin: 1, leadMax: 1, numberMin: 4, numberMax: 4, leadStartsWith: 'H' });
  /** `P-0000`. */
  static publicMotorVehicle = () => new PapuaNewGuineaValidator({ leadMin: 1, leadMax: 1, numberMin: 4, numberMax: 4, leadStartsWith: 'P' });
  /** `ZA-000` (motorcycles), `ZPD-000`. */
  static government = () => new PapuaNewGuineaValidator({ leadMin: 2, leadMax: 3, leadStartsWith: 'Z' });
  /** `PAA-000`. */
  static provincial = () => new PapuaNewGuineaValidator({ leadStartsWith: 'P' });
  /** `CC-033`. */
  static consular = () => new PapuaNewGuineaValidator({ leadMin: 2, leadMax: 2, leadStartsWith: 'CC' });
  /** `DC-053`. */
  static diplomatic = () => new PapuaNewGuineaValidator({ leadMin: 2, leadMax: 2, leadStartsWith: 'DC' });
  /** `TT-3447`. */
  static trade = () => new PapuaNewGuineaValidator({ leadMin: 2, leadMax: 2, numberMin: 4, numberMax: 4, leadStartsWith: 'TT' });

  judge(entry: PlateEntry): PlateValidation {
    const { leadMin, leadMax, numberMin, numberMax, leadStartsWith: prefix } = this;
    const lead = entry.group('lead');
    if (!new RegExp(`^[A-Z]{${leadMin},${leadMax}}$`).test(lead)) {
      return invalid(leadMin === leadMax ? `The letters are ${leadMin}.` : `The letters are ${leadMin} to ${leadMax}.`);
    }
    if (prefix !== null && !lead.startsWith(prefix)) return invalid(`The letters start with ${prefix}.`);
    if (!new RegExp(`^[0-9]{${numberMin},${numberMax}}$`).test(entry.group('number'))) {
      return invalid(numberMin === numberMax ? `The number is ${numberMin} digits.` : `The number is ${numberMin} to ${numberMax} digits.`);
    }
    return valid;
  }
}
