import { GatedPlateValidator, type PlateEntry, type PlateValidation, type PlateValidator, invalid, isDigits, isDigitsOfLength, restrictionVerdict, valid } from '../../core/validators/plate_validator';

/** The listed diplomatic mission codes after the `W`; 049 and 095 are refused, 080 is unissued. */
const missionCodes: ReadonlySet<string> = new Set(
  [[1, 48], [50, 79], [81, 94], [96, 121]].flatMap(([lo, hi]) => Array.from({ length: hi - lo + 1 }, (_, i) => String(lo + i).padStart(3, '0'))),
);

const isLetter = (c: string): boolean => /^[A-PR-Z]$/.test(c);
const allLetters = (s: string): boolean => Array.from(s).every(isLetter);
const voivodeshipDigit = (code: string): boolean => code.length === 2 && isLetter(code[0]) && isDigits(code[1]);

/**
 * Judges a Polish plate, field by field. Reports, never bars a keystroke.
 *
 * A car or electric plate is a two- or three-letter county code and a series
 * of five characters (four after a three-letter code), whose letters exclude
 * B, D, I, O and Z. After a two-letter code the series starts with a digit,
 * and after a three-letter one four characters may be neither all digits nor
 * three digits and a letter. A custom plate has a letter and a digit, then
 * three to five characters, a letter first, at most two digits at the end and
 * no letter after a digit; any letter but Q is allowed.
 */
export class PolandValidator implements PlateValidator {
  static readonly reasonCode = 'Two or three letters.';
  static readonly reasonSeriesLetters = 'B, D, I, O and Z are not used in a series.';
  static readonly reasonCarSeries = 'Five characters, the first a digit after a two-letter code.';
  static readonly reasonThreeLetterSeries = 'Four characters after a three-letter code may not be digits only, or three digits and a letter.';
  static readonly reasonVoivodeship = 'A letter then a digit.';
  static readonly reasonCustom = 'Three to five characters: a letter first, letters before digits, at most two digits.';
  static readonly reasonProfessional = 'A letter and two digits, then two digits, P and two digits.';
  static readonly reasonTemporary = 'Four digits, or three and a letter.';
  static readonly reasonTest = 'Three digits, then the letter B.';
  static readonly reasonClassic = 'Two or three letters and two or three characters, five in all.';
  static readonly reasonMotorcycle = 'Two or three letters, then four.';
  static readonly reasonReduced = 'A letter, then three characters.';
  static readonly reasonDiplomaticLetter = 'W is the only code issued.';
  static readonly reasonMission = 'Not a listed mission code.';
  static readonly reasonDiplomaticSerial = 'Three digits.';
  private static readonly excluded = 'BDIOZ';

  validate(entry: PlateEntry): PlateValidation {
    const V = PolandValidator;
    const refused = restrictionVerdict(entry);
    if (refused !== null) return refused;
    const g = (key: string) => entry.group(key);
    const code = g('code'), serial = g('serial');
    let bad: string | null = null;
    switch (entry.spec.id) {
      case 'pl.private':
        if (code === '' || serial === '') break;
        bad = V.car(code, serial);
        break;
      case 'pl.custom':
        if (code === '' || serial === '') break;
        bad = V.custom(code, serial);
        break;
      case 'pl.professional':
        if (code === '' || serial === '') break;
        if (!(code.length === 3 && isLetter(code[0]) && isDigits(code.slice(1)) && serial.length === 5 && isDigits(serial.slice(0, 2)) && serial[2] === 'P' && isDigits(serial.slice(3)))) {
          bad = V.reasonProfessional;
        }
        break;
      case 'pl.temporary':
        if (code === '' || serial === '') break;
        if (!voivodeshipDigit(code)) bad = V.reasonVoivodeship;
        else if (!(serial.length === 4 && isDigits(serial.slice(0, 3)) && (isDigits(serial[3]) || isLetter(serial[3])))) bad = V.reasonTemporary;
        break;
      case 'pl.test': {
        const n = g('number'), s = g('suffix');
        if (code === '' || n === '' || s === '') break;
        if (!voivodeshipDigit(code)) bad = V.reasonVoivodeship;
        else if (!isDigitsOfLength(n, 3) || s !== 'B') bad = V.reasonTest;
        break;
      }
      case 'pl.classic':
        if (code === '' || serial === '') break;
        if (!(code.length + serial.length === 5 && allLetters(code))) bad = V.reasonClassic;
        break;
      case 'pl.motorcycle':
        if (code === '' || serial === '') break;
        if (!(code.length >= 2 && allLetters(code) && serial.length === 4)) bad = V.reasonMotorcycle;
        break;
      case 'pl.reduced':
        if (code === '' || serial === '') break;
        if (!(isLetter(code) && serial.length === 3)) bad = V.reasonReduced;
        break;
      case 'pl.diplomatic': {
        const w = g('voivodeship'), m = g('mission'), s = g('serial');
        if (w !== '' && w !== 'W') bad = V.reasonDiplomaticLetter;
        else if (m.length === 3 && !missionCodes.has(m)) bad = V.reasonMission;
        else if (s !== '' && !isDigits(s)) bad = V.reasonDiplomaticSerial;
        break;
      }
    }
    return bad === null ? valid : invalid(bad);
  }

  private static car(code: string, serial: string): string | null {
    const V = PolandValidator;
    if (!(code.length >= 2 && allLetters(code))) return V.reasonCode;
    if (Array.from(serial).some((c) => V.excluded.includes(c))) return V.reasonSeriesLetters;
    if (code.length === 2) return serial.length === 5 && isDigits(serial[0]) ? null : V.reasonCarSeries;
    if (serial.length === 5) return null;
    if (serial.length !== 4) return V.reasonCarSeries;
    const digitsThenLetter = isDigits(serial.slice(0, 3)) && isLetter(serial[3]);
    return isDigits(serial) || digitsThenLetter ? V.reasonThreeLetterSeries : null;
  }

  private static custom(code: string, serial: string): string | null {
    if (!voivodeshipDigit(code)) return PolandValidator.reasonVoivodeship;
    const shape = serial.length >= 3 && isLetter(serial[0]) && !/[0-9][A-Z]/.test(serial) && /^[A-Z]+[0-9]{0,2}$/.test(serial);
    return shape ? null : PolandValidator.reasonCustom;
  }
}
