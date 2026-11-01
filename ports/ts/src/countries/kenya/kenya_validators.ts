import { GatedPlateValidator, type PlateEntry, type PlateValidation, type PlateValidator, invalid, isDigits, isDigitsOfLength, restrictionVerdict, valid, isLetters } from '../../core/validators/plate_validator';

const oneToThreeDigits = /^[0-9]{1,3}$/;

/** Judges a Kenyan plate: three letters, three digits and a letter. Reports, never bars a keystroke. */
export class KenyaValidator extends GatedPlateValidator {
  readonly gateGroup = 'suffix';

  static readonly reasonLetters = 'The register is three letters.';
  static readonly reasonDigits = 'The number is three digits.';
  static readonly reasonSuffix = 'The number ends in a letter.';

  judge(entry: PlateEntry): PlateValidation {
    if (!isLetters(entry.group('letters'), 3)) return invalid(KenyaValidator.reasonLetters);
    if (!isDigitsOfLength(entry.group('digits'), 3)) return invalid(KenyaValidator.reasonDigits);
    return isLetters(entry.group('suffix'), 1) ? valid : invalid(KenyaValidator.reasonSuffix);
  }
}

/** Judges a diplomatic plate: a mission code, `CD` or `UN`, a serial and two letters. Refuses mission `24` on its own account. */
export class KenyaDiplomaticValidator extends GatedPlateValidator {
  readonly gateGroup = 'letters';

  static readonly reasonMission = 'The mission is one to three digits.';
  static readonly reasonType = 'Pick CD or UN.';
  static readonly reasonDigits = 'The serial is one to three digits.';
  static readonly reasonLetters = 'The register is two letters.';
  static readonly refusedMissions: readonly string[] = ['24'];
  static readonly notFound = 'COUNTRY NOT FOUND';

  override validate(entry: PlateEntry): PlateValidation {
    if (KenyaDiplomaticValidator.refusedMissions.includes(entry.group('mission'))) return invalid(KenyaDiplomaticValidator.notFound);
    return super.validate(entry);
  }

  judge(entry: PlateEntry): PlateValidation {
    if (!oneToThreeDigits.test(entry.group('mission'))) return invalid(KenyaDiplomaticValidator.reasonMission);
    if (entry.group('type') === '') return invalid(KenyaDiplomaticValidator.reasonType);
    if (!oneToThreeDigits.test(entry.group('digits'))) return invalid(KenyaDiplomaticValidator.reasonDigits);
    return isLetters(entry.group('letters'), 2) ? valid : invalid(KenyaDiplomaticValidator.reasonLetters);
  }
}
