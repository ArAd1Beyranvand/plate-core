import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** Judges a plate by its fields: `SH` or `GSH`, two digits and five digits, or
/// nine digits on the army plate. Reports, never bars a keystroke. */
export class SahrawiArabDemocraticRepublicValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonCivil = 'A plate is SH or GSH, two digits and five digits.';
  static readonly reasonArmy = 'An army plate is nine digits.';

  judge(entry: PlateEntry): PlateValidation {
    const serial = entry.group('serial');
    if (entry.spec.indicesOfGroup('prefix').length === 0) {
      return isDigitsOfLength(serial, 9) ? valid : invalid(SahrawiArabDemocraticRepublicValidator.reasonArmy);
    }
    const prefix = entry.group('prefix');
    return (prefix === 'SH' || prefix === 'GSH') &&
      isDigitsOfLength(entry.group('code'), 2) &&
      isDigitsOfLength(serial, 5)
      ? valid
      : invalid(SahrawiArabDemocraticRepublicValidator.reasonCivil);
  }
}
