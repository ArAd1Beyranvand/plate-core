import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, valid } from '../../core/validators/plate_validator';

const series = /^[A-Z]{3}$/;
const number = /^[0-9][A-Z][0-9]{2}$/;
const legacyPlate = /^[A-Z]{3}[0-9]{4}$/;

/**
 * Judges a `BrazilPlates` value, `LLL N L NN`. Reports, never bars a
 * keystroke; series allocation is not checked (see `BrazilSeries.stateOf`).
 */
export class BrazilPlateValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';

  static readonly reasonSeries = 'The series is three letters.';
  static readonly reasonNumber = 'The number is a digit, a letter and two digits.';

  judge(entry: PlateEntry): PlateValidation {
    if (!series.test(entry.group('series'))) return invalid(BrazilPlateValidator.reasonSeries);
    if (!number.test(entry.group('number'))) return invalid(BrazilPlateValidator.reasonNumber);
    return valid;
  }

  /**
   * The Mercosul form of a 1990-2018 plate, `ABC1234` -> `ABC1C34`: the
   * second digit becomes a letter, 0 -> A through 9 -> J. Null if `legacy` is
   * not three letters and four digits.
   */
  static fromLegacy(legacy: string): string | null {
    if (!legacyPlate.test(legacy)) return null;
    const letter = String.fromCharCode(65 + legacy.charCodeAt(4) - 48);
    return `${legacy.substring(0, 4)}${letter}${legacy.substring(5)}`;
  }
}
