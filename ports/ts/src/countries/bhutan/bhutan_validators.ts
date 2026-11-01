import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

const area = /^[1-5]$/;
const series = /^[A-Z]$/;

/**
 * Judges a Bhutanese plate. Reports, never bars a keystroke.
 *
 * Every category keeps its type letters in the `type` group and its serial in
 * `number`; the civil plates (`BP-1-A1234`) also have `area` (1 to 5) and
 * `series` (a letter). `types` are the type codes the category carries.
 */
export class BhutanValidator extends GatedPlateValidator {
  readonly gateGroup = 'type';
  readonly types: readonly string[];

  constructor(args?: { types?: readonly string[] }) {
    super();
    this.types = args?.types ?? ['BP', 'BT', 'BG'];
  }

  /** Royal Bhutan Police: `RBP-2300`. */
  static police = () => new BhutanValidator({ types: ['RBP'] });

  /** Royal Bodyguard: `RBG 8047`. */
  static royalGuard = () => new BhutanValidator({ types: ['RBG'] });

  judge(entry: PlateEntry): PlateValidation {
    if (!this.types.includes(entry.group('type'))) return invalid(`The type is ${this.types.join(' or ')}.`);
    const keys = new Set(entry.spec.effectiveTextGroups.map((g) => g.key));
    if (keys.has('area') && !area.test(entry.group('area'))) return invalid('The area code is 1 to 5.');
    if (keys.has('series') && !series.test(entry.group('series'))) return invalid('The series is one letter.');
    if (!isDigitsOfLength(entry.group('number'), 4)) return invalid('The number is 4 digits.');
    return valid;
  }
}

/**
 * Judges a diplomatic plate: a country or organisation number (1 or 2
 * digits), "CD" and a serial (1 or 2 digits).
 */
export class BhutanDiplomaticValidator extends GatedPlateValidator {
  readonly gateGroup = 'country';

  judge(entry: PlateEntry): PlateValidation {
    if (!/^[0-9]{1,2}$/.test(entry.group('country'))) return invalid('The country number is 1 or 2 digits.');
    if (!/^[0-9]{1,2}$/.test(entry.group('serial'))) return invalid('The serial is 1 or 2 digits.');
    return valid;
  }
}
