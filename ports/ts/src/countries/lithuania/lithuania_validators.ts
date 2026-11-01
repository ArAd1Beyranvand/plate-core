import { GatedPlateValidator, type PlateEntry, type PlateValidation, type PlateValidator, invalid, isDigits, isDigitsOfLength, restrictionVerdict, valid } from '../../core/validators/plate_validator';

const letterSet = new Set('ABCDEFGHIJKLMNOPRSTUVYZ');
const missionCodes = new Set('01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 18 19 20 21 22 23 24 25 26 28 29 30 31 32 33 34 36 37 39 40 42 43'.split(' '));
const letters = (value: string): boolean => Array.from(value).every((c) => letterSet.has(c));

function prefixed(prefix: string, number: string, expected: string, reason: string): string | null {
  if (prefix === '' || number === '') return null;
  return prefix === expected && isDigitsOfLength(number, 5) ? null : reason;
}

/**
 * Judges a Lithuanian plate, field by field. Reports, never bars a keystroke.
 *
 * Letters exclude Q, W and X. Regular plates are three letters and three
 * digits; taxi `T` and dealer `P` plates a letter and five digits; temporary
 * plates four digits and one or two letters; military `LK`, three digits and
 * a letter; agricultural a letter, three or four digits and a letter;
 * diplomatic a listed mission, a status 1–4 and two or three digits.
 */
export class LithuaniaValidator implements PlateValidator {
  static readonly reasonLetters = 'Letters exclude Q, W and X.';
  static readonly reasonRegular = 'Three letters then three digits.';
  static readonly reasonTaxi = 'T then five digits.';
  static readonly reasonDealer = 'P then five digits.';
  static readonly reasonTemporary = 'Four digits then one or two letters.';
  static readonly reasonMilitary = 'LK, three digits, then a letter.';
  static readonly reasonAgricultural = 'A letter, three or four digits, then a letter.';
  static readonly reasonMission = 'Not a listed mission code.';
  static readonly reasonStatus = 'The status digit is 1 to 4.';
  static readonly reasonSerial = 'Two or three digits.';

  validate(entry: PlateEntry): PlateValidation {
    const refused = restrictionVerdict(entry);
    if (refused !== null) return refused;
    const g = (key: string) => entry.group(key);
    const V = LithuaniaValidator;
    let bad: string | null = null;
    switch (entry.spec.id) {
      case 'lt.private': {
        const l = g('letters'), n = g('number');
        if (l === '' || n === '') break;
        bad = !letters(l) ? V.reasonLetters : null;
        if (bad === null && !(l.length === 3 && isDigitsOfLength(n, 3))) bad = V.reasonRegular;
        break;
      }
      case 'lt.taxi':
        bad = prefixed(g('prefix'), g('number'), 'T', V.reasonTaxi);
        break;
      case 'lt.dealer':
        bad = prefixed(g('prefix'), g('number'), 'P', V.reasonDealer);
        break;
      case 'lt.temporary': {
        const n = g('number'), l = g('letters');
        if (n === '' || l === '') break;
        if (!letters(l)) bad = V.reasonLetters;
        else if (!(isDigitsOfLength(n, 4) && l.length <= 2)) bad = V.reasonTemporary;
        break;
      }
      case 'lt.military': {
        const c = g('code'), n = g('number'), l = g('letters');
        if (c === '' || n === '' || l === '') break;
        if (c !== 'LK' || !isDigitsOfLength(n, 3) || !letters(l)) bad = V.reasonMilitary;
        break;
      }
      case 'lt.agricultural': {
        const p = g('prefix'), n = g('number'), s = g('suffix');
        if (p === '' || n === '' || s === '') break;
        if (!letters(p + s)) bad = V.reasonLetters;
        else if (!isDigits(n) || n.length < 3) bad = V.reasonAgricultural;
        break;
      }
      case 'lt.diplomatic': {
        const m = g('mission'), s = g('status'), n = g('serial');
        if (m.length === 2 && !missionCodes.has(m)) bad = V.reasonMission;
        else if (s !== '' && !'1234'.includes(s)) bad = V.reasonStatus;
        else if (n !== '' && !(isDigits(n) && n.length >= 2)) bad = V.reasonSerial;
        break;
      }
    }
    return bad === null ? valid : invalid(bad);
  }
}
