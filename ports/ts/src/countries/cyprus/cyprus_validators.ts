import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigits, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

const letters = /^[A-Z]{3}$/;

const between = (v: string, min: number, max: number): boolean => isDigits(v) && v.length >= min && v.length <= max;

/**
 * Judges a Cypriot plate by its groups. Reports, never bars a keystroke.
 *
 * Every design names its last field `digits`, which gates the verdict; the
 * spec id picks the rule. A standard plate is three letters and three digits
 * (`KQL 343`); a trailer plate is `P` and five digits; a diplomatic plate is
 * a two-digit country code, `CD`, `CC` or `AT`, and one to three digits; a
 * Sovereign Base Areas plate is `SBAA` and two digits; a dealer plate is the
 * dealer's number (one or two digits) and a serial of one to three.
 */
export class CyprusValidator extends GatedPlateValidator {
  readonly gateGroup = 'digits';

  static readonly reasonStandard = 'A plate is three letters, three digits.';
  static readonly reasonTrailer = 'A trailer plate is P and five digits.';
  static readonly reasonDiplomatic = 'A diplomatic plate is a two-digit code, CD, CC or AT, and 1-3 digits.';
  static readonly reasonSba = 'An SBA plate is SBAA and two digits.';
  static readonly reasonDealer = 'A dealer plate is the dealer number (1-2 digits) and a serial (1-3).';

  static readonly diplomaticClasses = ['CD', 'CC', 'AT'];

  judge(entry: PlateEntry): PlateValidation {
    const digits = entry.group('digits');
    let ok: boolean;
    let reason: string;
    switch (entry.spec.id) {
      case 'cy.trailer':
        ok = isDigitsOfLength(digits, 5);
        reason = CyprusValidator.reasonTrailer;
        break;
      case 'cy.sba':
        ok = isDigitsOfLength(digits, 2);
        reason = CyprusValidator.reasonSba;
        break;
      case 'cy.diplomatic':
        ok = isDigitsOfLength(entry.group('code'), 2) && CyprusValidator.diplomaticClasses.includes(entry.group('class')) && between(digits, 1, 3);
        reason = CyprusValidator.reasonDiplomatic;
        break;
      case 'cy.dealer':
        ok = between(entry.group('dealer'), 1, 2) && between(digits, 1, 3);
        reason = CyprusValidator.reasonDealer;
        break;
      default:
        ok = letters.test(entry.group('letters')) && isDigitsOfLength(digits, 3);
        reason = CyprusValidator.reasonStandard;
    }
    return ok ? valid : invalid(reason);
  }
}
