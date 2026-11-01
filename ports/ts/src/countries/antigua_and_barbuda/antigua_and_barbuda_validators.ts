import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigits, valid } from '../../core/validators/plate_validator';

/** Judges `A 1234`: one class letter and up to [maxDigits] digits (three on
/// government plates). Reports, never bars a keystroke. */
export class AntiguaAndBarbudaValidator extends GatedPlateValidator {
  readonly maxDigits: number;

  constructor({ maxDigits = 4 }: { maxDigits?: number } = {}) {
    super();
    this.maxDigits = maxDigits;
  }

  readonly gateGroup = 'serial';

  static readonly reasonLetter = 'The class is one letter.';

  static readonly _letter = new RegExp(String.raw`^[A-Z]$`);

  judge(entry: PlateEntry): PlateValidation {
    if (!AntiguaAndBarbudaValidator._letter.test(entry.group('letter'))) {
      return invalid(AntiguaAndBarbudaValidator.reasonLetter);
    }
    const serial = entry.group('serial');
    if (serial === '' || serial.length > this.maxDigits || !isDigits(serial)) {
      return invalid(`The number is one to ${this.maxDigits} digits.`);
    }
    return valid;
  }
}
