import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigits, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

const regionCodes: ReadonlySet<string> = new Set(Array.from({ length: 20 }, (_, i) => String(i + 1).padStart(2, '0')));

/** The diplomatic mission codes: the three digits after the class letter (001–040). Code `007` (Israel) is deliberately absent and refused. */
const missionCodes: ReadonlySet<string> = new Set(Array.from({ length: 40 }, (_, i) => String(i + 1).padStart(3, '0')).filter((c) => c !== '007' && c !== '030'));
const refusedMissions: readonly string[] = ['007'];
const notFound = 'COUNTRY NOT FOUND';

/** Judges a Kazakh plate: three digits, `letters` letters and a region code. Reports, never bars a keystroke. */
export class KazakhstanValidator extends GatedPlateValidator {
  readonly letters: number;

  constructor({ letters = 3 }: { readonly letters?: number } = {}) {
    super();
    this.letters = letters;
  }

  readonly gateGroup = 'region';

  static readonly reasonNumber = 'The number is three digits.';
  static readonly reasonLetters = 'The serial has the wrong number of letters.';
  static readonly reasonRegion = 'The region code is 01 to 20.';

  judge(entry: PlateEntry): PlateValidation {
    if (!isDigitsOfLength(entry.group('number'), 3)) return invalid(KazakhstanValidator.reasonNumber);
    if (!new RegExp(`^[A-Z]{${this.letters}}$`).test(entry.group('letters'))) return invalid(KazakhstanValidator.reasonLetters);
    return regionCodes.has(entry.group('region')) ? valid : invalid(KazakhstanValidator.reasonRegion);
  }
}

/** Judges a diplomatic plate: a class letter, a listed mission code and three digits. Refuses code `007` on its own account. */
export class KazakhstanDiplomaticValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';

  static readonly reasonClass = 'The class is one letter.';
  static readonly reasonNumber = 'The number is three digits.';

  override validate(entry: PlateEntry): PlateValidation {
    if (refusedMissions.includes(entry.group('mission'))) return invalid(notFound);
    return super.validate(entry);
  }

  judge(entry: PlateEntry): PlateValidation {
    if (!/^[A-Z]$/.test(entry.group('class'))) return invalid(KazakhstanDiplomaticValidator.reasonClass);
    if (!missionCodes.has(entry.group('mission'))) return invalid(notFound);
    return isDigitsOfLength(entry.group('number'), 3) ? valid : invalid(KazakhstanDiplomaticValidator.reasonNumber);
  }
}
