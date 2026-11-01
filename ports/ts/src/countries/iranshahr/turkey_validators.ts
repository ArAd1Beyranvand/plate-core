import { GatedPlateValidator, type PlateEntry, type PlateValidation, type PlateValidator, invalid, isDigits, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** Judges a Turkish plate: province 01–81, letters and a figure serial. Reports, never bars a keystroke. */
export class TurkeyPlateValidator implements PlateValidator {
  readonly limitSix: boolean;

  constructor({ limitSix = true }: { readonly limitSix?: boolean } = {}) {
    this.limitSix = limitSix;
  }

  static readonly maxLettersAndDigits = 6;

  static readonly general = new TurkeyPlateValidator();
  static readonly police = new TurkeyPlateValidator({ limitSix: false });

  static isProvince(code: string): boolean {
    if (!isDigitsOfLength(code, 2)) return false;
    const n = Number(code);
    return n >= 1 && n <= 81;
  }

  /** The 23 plate letters: A–Z without Q, W and X. */
  static isLetters(letters: string): boolean {
    return /^[A-PR-VYZ]+$/.test(letters);
  }

  validate(entry: PlateEntry): PlateValidation {
    const province = entry.group('province');
    const letters = entry.group('letters');
    const serial = entry.group('serial');
    if (province !== '' && !TurkeyPlateValidator.isProvince(province)) return invalid('Province code must be 01 to 81');
    const hasLetters = entry.spec.indicesOfGroup('letters').length > 0;
    if (hasLetters && letters !== '' && !TurkeyPlateValidator.isLetters(letters)) return invalid('Letters exclude Ç Ş İ Ö Ü Ğ Q W X');
    if (serial !== '' && !isDigits(serial)) return invalid('Serial must be figures');
    if (this.limitSix && hasLetters && letters.length + serial.length > TurkeyPlateValidator.maxLettersAndDigits) return invalid('Letters and figures number at most six');
    return valid;
  }
}
