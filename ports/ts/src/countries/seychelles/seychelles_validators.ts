import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, valid } from '../../core/validators/plate_validator';

/** Judges a plate (`S 11111`): one letter and up to five digits. The tag of
 * the plate since 2018 is not judged. Reports, never bars a keystroke. */
export class SeychellesValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonLetter = 'The series is one letter.';
  static readonly reasonSerial = 'The number is one to five digits.';

  private static readonly _letter = /^[A-Z]$/;
  private static readonly _serial = /^[0-9]{1,5}$/;

  judge(entry: PlateEntry): PlateValidation {
    if (!SeychellesValidator._letter.test(entry.group('letter')!)) {
      return invalid(SeychellesValidator.reasonLetter);
    }
    if (!SeychellesValidator._serial.test(entry.group('serial')!)) {
      return invalid(SeychellesValidator.reasonSerial);
    }
    return valid;
  }
}
