import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid, isLetters } from '../../core/validators/plate_validator';

const regionCodes = ['CE', 'GO', 'KK', 'KP', 'KR', 'LJ', 'MB', 'MS', 'NM', 'PO', 'SG'];

/** Judges a Slovenian plate by its three groups, `region`, `a`, `b`.
 *
 * A registration is a unit code and then either three digits and two letters
 * (`LJ 898-KP`) or two letters and three digits (the export `MB LL-251`);
 * police is `P` and two plus three digits; diplomatic is `CD` and two plus
 * two digits. Reports, never bars a keystroke. */
export class SloveniaValidator extends GatedPlateValidator {
  readonly gateGroup = 'b';

  static readonly reasonRegion = 'The unit code is two letters, e.g. LJ.';
  static readonly reasonPolice = 'Police is P, two digits, three digits.';
  static readonly reasonDiplomatic = 'Diplomatic is CD, two digits, two digits.';
  static readonly reasonSerial = 'The serial is three digits and two letters, or two letters and three digits.';

  judge(entry: PlateEntry): PlateValidation {
    const region = entry.group('region');
    const a = entry.group('a');
    const b = entry.group('b');
    let ok: boolean;
    let reason: string;
    if (region === 'P') {
      [ok, reason] = [isDigitsOfLength(a, 2) && isDigitsOfLength(b, 3), SloveniaValidator.reasonPolice];
    } else if (region === 'CD') {
      [ok, reason] = [isDigitsOfLength(a, 2) && isDigitsOfLength(b, 2), SloveniaValidator.reasonDiplomatic];
    } else if (!regionCodes.includes(region)) {
      [ok, reason] = [false, SloveniaValidator.reasonRegion];
    } else {
      [ok, reason] = [
        (isDigitsOfLength(a, 3) && isLetters(b, 2)) || (isLetters(a, 2) && isDigitsOfLength(b, 3)),
        SloveniaValidator.reasonSerial,
      ];
    }
    return ok ? valid : invalid(reason);
  }
}
