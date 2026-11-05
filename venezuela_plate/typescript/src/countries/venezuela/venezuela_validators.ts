import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigits, valid } from 'plate_core/core/validators/plate_validator';

/** The state letters: A Distrito Capital to Y Zulia, no Q or Z. */
const stateCodes = 'ABCDEFGHIJKLMNOPRSTUVWXY';

/** One vehicle category's serial: the six cells before the state letter.
 * `L` is a letter, `D` a digit, and any other character is printed as is. */
export class VenezuelaCategory {
  constructor(
    readonly name: string,
    readonly pattern: string,
  ) {}

  matches(serial: string): boolean {
    if (serial.length !== this.pattern.length) return false;
    return this.pattern.split('').every((p, i) => {
      const c = serial[i];
      return p === 'L' ? VenezuelaCategory.isLetter(c) : p === 'D' ? isDigits(c) : c === p;
    });
  }

  static isLetter(c: string): boolean {
    return c.length === 1 && c.charCodeAt(0) >= 0x41 && c.charCodeAt(0) <= 0x5a;
  }
}

/** Reports, never throws, never bars a keystroke. Quiet until the state
 * letter is in; then the six serial cells must match one of `categories`
 * and the last letter must name a state. */
export class VenezuelaValidator extends GatedPlateValidator {
  readonly gateGroup = 'state';

  /** The seven-character categories in the article's table, in its order.
   * Animal traction (`x1xx2`) and vehicles for the disabled (`x12x3`) have
   * six characters and so do not fit this plate; the provisional and Free
   * Port series are other designs. */
  static readonly categories: readonly VenezuelaCategory[] = [
    new VenezuelaCategory('Private car', 'LLDDDL'),
    new VenezuelaCategory('Motorcycle', 'LLDLDD'),
    new VenezuelaCategory('Freight', 'LDDLLD'),
    new VenezuelaCategory('Crane', 'LDDLDD'),
    new VenezuelaCategory('School transport', 'LDDDLD'),
    new VenezuelaCategory('Private transport', 'LDDDDL'),
    new VenezuelaCategory('Tourist transport, rustic', 'LDLLDD'),
    new VenezuelaCategory('Tourist transport, minibus', 'LDDLDL'),
    new VenezuelaCategory('Tourist transport, bus', 'LDLDLD'),
    new VenezuelaCategory('Urban public transport', '0DLLDL'),
    new VenezuelaCategory('Suburban public transport, car', '1DLDLD'),
    new VenezuelaCategory('Suburban public transport, minibus', '2DLDDL'),
    new VenezuelaCategory('Suburban public transport, bus', '3DLLDD'),
    new VenezuelaCategory('Intercity public transport, car', '4DDLDL'),
    new VenezuelaCategory('Intercity public transport, minibus', '5DDLLD'),
    new VenezuelaCategory('Intercity public transport, bus', '6DDDLD'),
    new VenezuelaCategory('Taxi', '7LDLDL'),
    new VenezuelaCategory('Peripheral public transport, rustic', '8LDLDD'),
    new VenezuelaCategory('Peripheral public transport, minibus', '9LDDDL'),
  ];

  /** The category `serial` is written in, or null if it fits none. */
  static categoryOf(serial: string): VenezuelaCategory | null {
    return VenezuelaValidator.categories.find((c) => c.matches(serial)) ?? null;
  }

  static readonly reasonSerialLength = 'The serial fills every cell.';
  static readonly reasonNoCategory = "The letters and digits are in no category's order.";
  static readonly reasonState = 'The last letter names no state.';

  judge(entry: PlateEntry): PlateValidation {
    const serial = entry.group('serial');
    if (serial.length !== 6) {
      return invalid(VenezuelaValidator.reasonSerialLength);
    }
    const state = entry.group('state');
    if (state.length !== 1 || !stateCodes.includes(state)) {
      return invalid(VenezuelaValidator.reasonState);
    }
    if (VenezuelaValidator.categoryOf(serial) === null) {
      return invalid(VenezuelaValidator.reasonNoCategory);
    }
    return valid;
  }
}
