import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** Judges a standard plate: three letters and three digits (`ABC 123`). Reports, never bars a keystroke. */
export class NewZealandValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonLetters = 'The letters are three capitals.';
  static readonly reasonSerial = 'The number is three digits.';

  judge(entry: PlateEntry): PlateValidation {
    if (!/^[A-Z]{3}$/.test(entry.group('letters'))) return invalid(NewZealandValidator.reasonLetters);
    if (!isDigitsOfLength(entry.group('serial'), 3)) return invalid(NewZealandValidator.reasonSerial);
    return valid;
  }
}

/** Judges the older plate: two letters and four digits (`GG 9094`). */
export class NewZealandLegacyValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonLetters = 'The letters are two capitals.';
  static readonly reasonSerial = 'The number is four digits.';

  judge(entry: PlateEntry): PlateValidation {
    if (!/^[A-Z]{2}$/.test(entry.group('letters'))) return invalid(NewZealandLegacyValidator.reasonLetters);
    if (!isDigitsOfLength(entry.group('serial'), 4)) return invalid(NewZealandLegacyValidator.reasonSerial);
    return valid;
  }
}

/** Judges a personalised plate: one to six letters and digits, one field. */
export class NewZealandPersonalisedValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonRun = 'A personalised plate is one to six letters or digits.';

  judge(entry: PlateEntry): PlateValidation {
    return /^[A-Z0-9]{1,6}$/.test(entry.group('serial')) ? valid : invalid(NewZealandPersonalisedValidator.reasonRun);
  }
}
