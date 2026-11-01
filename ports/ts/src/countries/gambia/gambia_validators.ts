import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** Judges `BJL 0123 A` field by field: `region`, `number` (4 digits) and
 * `suffix` (1 letter). Reports, never bars a keystroke. */
export class GambiaValidator extends GatedPlateValidator {
  readonly regions = new Set([
    'BJL', 'KM',
    'WCR', 'NBR', 'LRR', 'CRR', 'URR',
    'WD', 'NBD', 'LRD', 'CRD', 'URD',
  ]);

  readonly gateGroup = 'number';

  judge(entry: PlateEntry): PlateValidation {
    if (!this.regions.has(entry.group('region'))) {
      return invalid('The region code is not a known one.');
    }
    if (!isDigitsOfLength(entry.group('number'), 4)) {
      return invalid('The number is 4 digits.');
    }
    if (!/^[A-Z]$/.test(entry.group('suffix'))) {
      return invalid('The suffix is 1 letter.');
    }
    return valid;
  }
}
