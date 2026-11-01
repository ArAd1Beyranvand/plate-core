import { GatedPlateValidator, type PlateEntry, type PlateValidation, type PlateValidator, invalid, isDigits, isDigitsOfLength, restrictionVerdict, valid } from '../../core/validators/plate_validator';

/**
 * Judges an Ecuadorian plate field by field: `ABC-123` or `ABC-1234` on
 * `EcuadorPlates.standard`, `CD-0123` on `EcuadorPlates.protocol`. Quiet
 * until the number has something in it. Reports, never bars a keystroke.
 */
export class EcuadorValidator implements PlateValidator {
  /** The first letter of a standard plate names the province of issue. */
  static readonly provinces: ReadonlySet<string> = new Set('ABUCXHOEWGILRMVNSPQKTZYJ');

  /** Consular corps, diplomatic corps, international organisation, administrative and technical personnel, and temporary international organisation. */
  static readonly protocolCodes: ReadonlySet<string> = new Set(['CC', 'CD', 'OI', 'AT', 'IT']);

  static readonly reasonProvince = 'The first letter names a province.';
  static readonly reasonLetters = 'A plate starts with three letters.';
  static readonly reasonCode = 'The code is CC, CD, OI, AT or IT.';
  static readonly reasonNumber = 'The number is 3 or 4 digits.';

  validate(entry: PlateEntry): PlateValidation {
    const refused = restrictionVerdict(entry);
    if (refused !== null) return refused;
    const letters = entry.group('letters');
    const number = entry.group('number');
    if (number === '') return valid;
    if (entry.spec.id === 'ec.protocol') {
      if (!EcuadorValidator.protocolCodes.has(letters)) return invalid(EcuadorValidator.reasonCode);
    } else if (!/^[A-Z]{3}$/.test(letters)) {
      return invalid(EcuadorValidator.reasonLetters);
    } else if (!EcuadorValidator.provinces.has(letters[0])) {
      return invalid(EcuadorValidator.reasonProvince);
    }
    return /^[0-9]{3,4}$/.test(number) ? valid : invalid(EcuadorValidator.reasonNumber);
  }
}
