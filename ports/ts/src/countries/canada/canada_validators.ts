import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** Judges a `CanadaPlates.federal` value: five digits. Reports, never bars a
 * keystroke. */
export class CanadaFederalValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';

  static readonly reasonNumber = 'A federal plate has five digits.';

  judge(entry: PlateEntry): PlateValidation {
    if (!isDigitsOfLength(entry.group('number'), 5)) {
      return invalid(CanadaFederalValidator.reasonNumber);
    }
    return valid;
  }
}

/** Judges a `CanadaPlates.permit` value: a letter, then six digits. I, O, Q
 * and U are reported as unused. */
export class CanadaPermitValidator extends GatedPlateValidator {
  readonly gateGroup = 'letter';

  static readonly reasonLetter = 'A permit starts with one letter.';
  static readonly reasonUnused = 'I, O, Q and U are not used in serials.';
  static readonly reasonNumber = 'A permit has six digits.';

  judge(entry: PlateEntry): PlateValidation {
    const letter = entry.group('letter');
    if (letter.length !== 1) {
      return invalid(CanadaPermitValidator.reasonLetter);
    }
    if ('IOQU'.includes(letter)) {
      return invalid(CanadaPermitValidator.reasonUnused);
    }
    if (!isDigitsOfLength(entry.group('number'), 6)) {
      return invalid(CanadaPermitValidator.reasonNumber);
    }
    return valid;
  }
}
