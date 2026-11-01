import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

interface DenmarkArgs {
  readonly yearDigits?: number;
  readonly midDigits?: number;
  readonly numberDigits?: number;
  readonly allowedLetters?: readonly string[] | null;
}

/**
 * Judges a Danish serial plate field by field. Reports, never bars a
 * keystroke.
 *
 * Letters are two of A-Z. `midDigits` is the two-digit field (0 where the
 * plate has none), `numberDigits` the last field, `yearDigits` the export
 * plate's validity year (0 where absent). `allowedLetters` narrows the
 * letters, as Greenland's `GR` and `GL`.
 */
export class DenmarkValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';

  readonly yearDigits: number;
  readonly midDigits: number;
  readonly numberDigits: number;
  readonly allowedLetters: ReadonlySet<string> | null;

  constructor({ yearDigits = 0, midDigits = 2, numberDigits = 3, allowedLetters = null }: DenmarkArgs = {}) {
    super();
    this.yearDigits = yearDigits;
    this.midDigits = midDigits;
    this.numberDigits = numberDigits;
    this.allowedLetters = allowedLetters && new Set(allowedLetters);
  }

  /** Greenland: serial letters `GR` and `GL` are reserved for it. */
  static greenland = () => new DenmarkValidator({ allowedLetters: ['GR', 'GL'] });

  /** Fixed temporary plate `DD 12`: letters and two digits. */
  static fixedTemporary = () => new DenmarkValidator({ midDigits: 0, numberDigits: 2 });

  /** Faroese plate: two letters and three digits. */
  static faroeIslands = () => new DenmarkValidator({ midDigits: 0 });

  /** Temporary export plate: year, then two and three digits. */
  static exportTemporary = () => new DenmarkValidator({ yearDigits: 2 });

  static readonly reasonLetters = 'The letters are two of A–Z.';
  static readonly reasonGreenland = 'Greenland uses the letters GR or GL.';
  static readonly reasonDigits = 'The digits do not fit the plate.';

  judge(entry: PlateEntry): PlateValidation {
    const letters = entry.group('letters');
    const hasLetters = this.yearDigits === 0;
    if (hasLetters && !/^[A-Z]{2}$/.test(letters)) return invalid(DenmarkValidator.reasonLetters);
    if (hasLetters && this.allowedLetters !== null && !this.allowedLetters.has(letters)) return invalid(DenmarkValidator.reasonGreenland);
    if (
      (this.yearDigits > 0 && !isDigitsOfLength(entry.group('year'), this.yearDigits)) ||
      (this.midDigits > 0 && !isDigitsOfLength(entry.group('mid'), this.midDigits)) ||
      !isDigitsOfLength(entry.group('number'), this.numberDigits)
    ) {
      return invalid(DenmarkValidator.reasonDigits);
    }
    return valid;
  }
}

/** Judges a vanity plate: two to seven letters or digits, with Æ, Ø and Å. */
export class DenmarkVanityValidator extends GatedPlateValidator {
  readonly gateGroup = 'text';

  static readonly reasonText = 'A vanity plate is two to seven letters or digits.';

  judge(entry: PlateEntry): PlateValidation {
    return /^[A-ZÆØÅ0-9]{2,7}$/.test(entry.group('text')) ? valid : invalid(DenmarkVanityValidator.reasonText);
  }
}
