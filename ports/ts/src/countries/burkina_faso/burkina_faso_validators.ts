import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** (group, digits rather than letters, length), in plate order, by category. */
type Rule = readonly [group: string, digits: boolean, length: number];

const rules: Record<string, readonly Rule[]> = {
  private: [['region', true, 2], ['letters', false, 2], ['serial', true, 4]],
  commercial: [['region', true, 2], ['letter', false, 1], ['serial', true, 4]],
  police: [['service', false, 2], ['serial', true, 4]],
  gendarmerie: [['unit', true, 1], ['serial', true, 4], ['corps', false, 4]],
};

/**
 * Judges a Burkinabè plate against its category's format. Reports, never
 * bars a keystroke.
 *
 * - private: `12 AB 1234` - two digits, two letters, four digits;
 * - commercial: `12 A 1234` - two digits, one letter, four digits;
 * - police: `PN 1234` - two letters, four digits;
 * - gendarmerie: `1 2345 EMGN` - one digit, four digits, four letters.
 *
 * With no `category` it is read from the spec id (`bf.private`, ...).
 */
export class BurkinaFasoValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  constructor(readonly category?: string) {
    super();
  }

  static private = () => new BurkinaFasoValidator('private');
  static commercial = () => new BurkinaFasoValidator('commercial');
  static police = () => new BurkinaFasoValidator('police');
  static gendarmerie = () => new BurkinaFasoValidator('gendarmerie');

  judge(entry: PlateEntry): PlateValidation {
    for (const [group, digits, length] of rules[this.category ?? entry.spec.id.split('.')[1]] ?? []) {
      const value = entry.group(group);
      const ok = digits ? isDigitsOfLength(value, length) : new RegExp(`^[A-Z]{${length}}$`).test(value);
      if (!ok) return invalid(`The ${group} is ${length} ${digits ? 'digit' : 'letter'}${length === 1 ? '' : 's'}.`);
    }
    return valid;
  }
}
