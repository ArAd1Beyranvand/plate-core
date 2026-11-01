import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, valid } from '../../core/validators/plate_validator';

/** Judges a diplomatic plate: one to three digits (the mission), `CD` or `CMD`,
then a number (`1 CD 13`). Reports, never bars a keystroke.
///
/// The article says "up to three numbers, followed by CD or CMD and another
/// number" and gives no length for the last; the photo shows two digits, so
/// one or two are accepted. */
export class LiberiaValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';

  static readonly reasonMission = 'The mission is one to three digits.';
  static readonly reasonStatus = 'The status is CD or CMD.';
  static readonly reasonNumber = 'The number is one or two digits.';

  judge(entry: PlateEntry): PlateValidation {
    if (!/^[0-9]{1,3}$/.test(entry.group('mission')!)) {
      return invalid(LiberiaValidator.reasonMission);
    }
    if (!/^[CM]?D$/.test(entry.group('status')!)) {
      return invalid(LiberiaValidator.reasonStatus);
    }
    if (!/^[0-9]{1,2}$/.test(entry.group('number')!)) {
      return invalid(LiberiaValidator.reasonNumber);
    }
    return valid;
  }
}
