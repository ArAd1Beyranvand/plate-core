import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigits, valid } from '../../core/validators/plate_validator';

/** Judges a 2005-series value. Reports, never throws, never bars a keystroke.
 *
 * Quiet until the number is in. Then the department code must be one seen on
 * the series, and Managua (`M`) takes six digits where every other code takes
 * three or four. */
export class NicaraguaValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';

  /** Codes confirmed on 2005-series plates or in the sources' lists. Boaco,
   * Carazo, Madriz, Río San Juan and Rivas certainly have codes, but none was
   * confirmed, so they are not guessed at here. */
  static readonly departments: Record<string, string> = {
    'M': 'Managua',
    'MY': 'Masaya',
    'MT': 'Matagalpa',
    'CH': 'Chinandega',
    'CT': 'Chontales',
    'NS': 'Nueva Segovia',
    'ES': 'Estelí',
    'JI': 'Jinotega',
    'GR': 'Granada',
    'LE': 'León',
    'RN': 'Atlántico Norte',
    'RS': 'Atlántico Sur',
    'PN': 'Policía Nacional',
    'CD': 'Diplomatic corps',
    'CC': 'Consular corps',
    'MI': 'International mission',
  };

  static readonly reasonDepartment = 'The letters name no department.';
  static readonly reasonManagua = 'Managua numbers have six digits.';
  static readonly reasonNumber = 'The number has three or four digits.';

  judge(entry: PlateEntry): PlateValidation {
    // A split Managua number is not finished until its second half is in.
    if (entry.spec.indicesOfGroup('number_tail').length > 0 && entry.group('number_tail') === '') {
      return valid;
    }
    const code = entry.group('department');
    const number = entry.group('number') + entry.group('number_tail');
    if (!NicaraguaValidator.departments.hasOwnProperty(code)) {
      return invalid(NicaraguaValidator.reasonDepartment);
    }
    if (!isDigits(number)) {
      return invalid(NicaraguaValidator.reasonNumber);
    }
    if (code === 'M') {
      return number.length === 6 ? valid : invalid(NicaraguaValidator.reasonManagua);
    }
    return number.length === 3 || number.length === 4 ? valid : invalid(NicaraguaValidator.reasonNumber);
  }
}
