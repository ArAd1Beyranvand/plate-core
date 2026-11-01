import { GatedPlateValidator, type PlateEntry, type PlateValidation, type PlateValidator, invalid, isDigits, isDigitsOfLength, restrictionVerdict, valid } from '../../core/validators/plate_validator';

const areas: ReadonlySet<string> = new Set(
  'BE BT DB DE DH DK GE GV KA KI KO KR KP KS KU MB MK NE OH PE PP PS RA RE SK SN SU SR ST TE VA VE VI VV'.split(' '),
);
const types = ['CC', 'CD', 'CMD'];

const ok = (good: boolean, reason: string): PlateValidation => (good ? valid : invalid(reason));
const isLetters = (v: string, n: number): boolean => v.length === n && /^[A-PR-VZ]+$/.test(v);

/**
 * Judges a North Macedonian plate by its keyed groups. Reports, never bars a
 * keystroke; quiet until the last field has content.
 *
 * - `mk.standard`, `mk.legacy`, `mk.two_row`: `region` (one of the 34 area
 *   codes), `digits` (four) and `letters` (two): `SK 1234 AB`.
 * - `mk.diplomatic`: `mission` (a listed two-digit code; the refused `35` is
 *   reported first), `type` (`CC`, `CD` or `CMD`) and `serial` (two or three
 *   digits).
 */
export class NorthMacedoniaValidator implements PlateValidator {
  static readonly reasonRegion = 'The area code is not one in use.';
  static readonly reasonDigits = 'The number is four digits.';
  static readonly reasonLetters = 'The series is two letters.';
  static readonly reasonMission = 'The mission code is not listed.';
  static readonly reasonType = 'The class is CC, CD or CMD.';
  static readonly reasonSerial = 'The serial is two or three digits.';

  validate(entry: PlateEntry): PlateValidation {
    const diplomatic = entry.spec.id === 'mk.diplomatic';
    const gate = diplomatic ? 'serial' : 'letters';
    const refused = restrictionVerdict(entry);
    if (refused !== null) return refused;
    if (entry.group(gate) === '') return valid;
    return diplomatic ? this.judgeDiplomatic(entry) : this.judgeStandard(entry);
  }

  private judgeStandard(entry: PlateEntry): PlateValidation {
    const V = NorthMacedoniaValidator;
    if (!areas.has(entry.group('region'))) return invalid(V.reasonRegion);
    if (!isDigitsOfLength(entry.group('digits'), 4)) return invalid(V.reasonDigits);
    return ok(isLetters(entry.group('letters'), 2), V.reasonLetters);
  }

  private judgeDiplomatic(entry: PlateEntry): PlateValidation {
    const V = NorthMacedoniaValidator;
    if (!isDigitsOfLength(entry.group('mission'), 2)) return invalid(V.reasonMission);
    if (!types.includes(entry.group('type'))) return invalid(V.reasonType);
    const serial = entry.group('serial');
    return ok(isDigitsOfLength(serial, 2) || isDigitsOfLength(serial, 3), V.reasonSerial);
  }
}
