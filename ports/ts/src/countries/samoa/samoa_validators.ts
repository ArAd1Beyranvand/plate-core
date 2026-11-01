import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigits, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** Judges a Samoan plate by its `serial` field: one to four digits (`1234`;
/// the earlier plates print three, the 1979 plate one digit then three).
/// Reports, never bars a keystroke. */
export class SamoaValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonSerial = 'The number is one to four digits.';

  judge(entry: PlateEntry): PlateValidation {
    const serial = entry.group('serial');
    if (serial.length === 0 || serial.length > 4 || !isDigits(serial)) {
      return invalid(SamoaValidator.reasonSerial);
    }
    const mark = entry.spec.textGroups.some((g) => g.key === 'mark')
      ? entry.group('mark')
      : '';
    if (mark.length > 0 && !isDigitsOfLength(mark, 1)) {
      return invalid(SamoaValidator.reasonSerial);
    }
    return valid;
  }
}
