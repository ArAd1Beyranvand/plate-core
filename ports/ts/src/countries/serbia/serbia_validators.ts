import { PlateAlphabet } from '../../core/alphabet/plate_alphabet';
import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, restrictionVerdict, valid } from '../../core/validators/plate_validator';

const regionLetters = PlateAlphabet.pattern({ id: 'rs.region.letters', include: 'A-C Ć Č D-S Š T-V Z Ž', exclude: 'F H Q', input: 'typed', isNumeric: false });
const letters = PlateAlphabet.pattern({ id: 'rs.letters', include: 'A-Z', exclude: 'Q W Y', input: 'typed', isNumeric: false });

/** Judges a Serbian plate by its keyed groups; which groups exist depends on
 * the design, read off the spec id. Reports, never bars a keystroke.
 *
 * - `rs.private`: `region` (two letters) · `digits` (3–4) · `letters` (two,
 *   X allowed): `BG 1234-EC`.
 * - `rs.taxi`: `region` · five digits · `TX`; `rs.trailer`: two letters,
 *   three digits, `region`.
 * - `rs.police`: `П`, three digits, three digits; `rs.military`: a letter and
 *   four digits.
 * - `rs.diplomatic`: area code, a two-digit country code (the three-digit
 *   codes do not fit the plate), a series letter `A`/`M`/`P`, three digits
 *   and a two-digit tail. The refused code `20` is reported first by
 *   GatedPlateValidator.
 * - two-row plates: `region`, then two and three characters (`OT` and three
 *   digits; two digits and three letters on agricultural; two and three
 *   digits on moped and motorcycle).
 *
 * The article's region table is cut off after `LO`, so any two letters of the
 * region alphabet are accepted rather than a fixed list. */
export class SerbiaValidator extends GatedPlateValidator {
  readonly gateGroup = 'region';

  static readonly reasonRegion = 'The area code is two letters, e.g. BG.';
  static readonly reasonDigits = 'Check the number of digits.';
  static readonly reasonLetters = 'Check the series letters.';

  private static _inAlphabet(v: string, n: number, alphabet: PlateAlphabet): boolean {
    return v.length === n && v.split('').every((c) => alphabet.characters.includes(c));
  }

  private static _letters(v: string, n: number): boolean {
    return SerbiaValidator._inAlphabet(v, n, letters);
  }

  private _ok(ok: boolean, reason: string): PlateValidation {
    return ok ? valid : invalid(reason);
  }

  override validate(entry: PlateEntry): PlateValidation {
    const id = entry.spec.id;
    if (id === 'rs.police' || id === 'rs.military' || id === 'rs.diplomatic') {
      return restrictionVerdict(entry) ?? this._judgeSpecial(entry, id);
    }
    return super.validate(entry);
  }

  private _judgeSpecial(entry: PlateEntry, id: string): PlateValidation {
    const { reasonDigits } = SerbiaValidator;
    switch (id) {
      case 'rs.police':
        return this._ok(isDigitsOfLength(entry.group('a'), 3) && isDigitsOfLength(entry.group('b'), 3), reasonDigits);
      case 'rs.military':
        return this._ok(SerbiaValidator._letters(entry.group('letter'), 1) && isDigitsOfLength(entry.group('digits'), 4), reasonDigits);
      default:
        return this._ok(
          isDigitsOfLength(entry.group('code'), 2) &&
            isDigitsOfLength(entry.group('serial'), 3) &&
            (entry.group('tail') === '' || isDigitsOfLength(entry.group('tail'), 2)),
          reasonDigits,
        );
    }
  }

  judge(entry: PlateEntry): PlateValidation {
    const { reasonDigits, reasonLetters } = SerbiaValidator;
    if (!SerbiaValidator._inAlphabet(entry.group('region'), 2, regionLetters)) {
      return invalid(SerbiaValidator.reasonRegion);
    }
    switch (entry.spec.id) {
      case 'rs.private': {
        const d = entry.group('digits');
        return this._ok((isDigitsOfLength(d, 3) || isDigitsOfLength(d, 4)) && SerbiaValidator._letters(entry.group('letters'), 2), reasonDigits);
      }
      case 'rs.taxi':
        return this._ok(isDigitsOfLength(entry.group('digits'), 5), reasonDigits);
      case 'rs.trailer':
        return this._ok(SerbiaValidator._letters(entry.group('letters'), 2) && isDigitsOfLength(entry.group('digits'), 3), reasonDigits);
      case 'rs.oldtimer':
        return this._ok(entry.group('a') === 'OT' && isDigitsOfLength(entry.group('b'), 3), reasonDigits);
      case 'rs.agricultural':
        return this._ok(isDigitsOfLength(entry.group('a'), 2) && SerbiaValidator._letters(entry.group('b'), 3), reasonLetters);
      default:
        return this._ok(isDigitsOfLength(entry.group('a'), 2) && isDigitsOfLength(entry.group('b'), 3), reasonDigits);
    }
  }
}
