import { type PlateEntry, type PlateValidation, type PlateValidator, invalid, restrictionVerdict, valid } from '../../core/validators/plate_validator';

/** Administrative division codes (article table): Awdal, Maroodi Jeex, Sool,
 * Sanaag, Sahil, Togdheer. */
const regionCodes = ['AW', 'MJ', 'SL', 'SN', 'SX', 'TG'];

/** Judges a 2018 plate: a class letter and four digits (`C1234`) and, on
 * private plates, a division code. Reports, never bars a keystroke. */
export class SomalilandValidator implements PlateValidator {
  private static readonly _serial = /^[A-E][0-9]{4}$/;
  private static readonly _old = /^[A-Z][0-9]{1,3}$/;

  validate(entry: PlateEntry): PlateValidation {
    const refused = restrictionVerdict(entry);
    if (refused !== null) return refused;
    const groups = entry.spec.textGroups;
    if (groups.length === 0 || entry.group(groups[groups.length - 1].key!) === '') return valid;
    if (groups.some((g) => g.key === 'letter')) {
      return SomalilandValidator._old.test(entry.group('letter') + entry.group('number')) ? valid : invalid('A letter and one to three digits.');
    }
    if (!SomalilandValidator._serial.test(entry.group('serial'))) {
      return invalid('A class letter A–E and four digits.');
    }
    if (groups.some((g) => g.key === 'region') && !regionCodes.includes(entry.group('region'))) {
      return invalid('Unknown division code.');
    }
    return valid;
  }
}
