import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigits, isDigitsOfLength, valid, isLetters } from '../../core/validators/plate_validator';

const regionCodes: readonly string[] = ['01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11'];
const foreignClasses: readonly string[] = ['H', 'K', 'M', 'P'];
const diplomaticClasses: readonly string[] = ['C', 'D', 'T'];
/** Mission codes: 01 to 19 for countries, 50 to 64 for organisations. */
const missionCodes: readonly string[] = [...Array.from({ length: 19 }, (_, i) => String(i + 1).padStart(2, '0')), ...Array.from({ length: 15 }, (_, i) => String(50 + i))];

const isMonth = (value: string): boolean => value.length === 2 && isDigits(value) && Number(value) >= 1 && Number(value) <= 12;

/** Judges a Kyrgyz plate: region, three digits and two or three letters. Reports, never bars a keystroke. */
export class KyrgyzstanValidator extends GatedPlateValidator {
  readonly gateGroup = 'letters';

  static readonly reasonRegion = 'The region code is 01 to 11.';
  static readonly reasonNumber = 'The number is three digits.';
  static readonly reasonLetters = 'The serial ends in two or three letters.';

  judge(entry: PlateEntry): PlateValidation {
    if (!regionCodes.includes(entry.group('region'))) return invalid(KyrgyzstanValidator.reasonRegion);
    if (!isDigitsOfLength(entry.group('number'), 3)) return invalid(KyrgyzstanValidator.reasonNumber);
    return isLetters(entry.group('letters'), 2, 3) ? valid : invalid(KyrgyzstanValidator.reasonLetters);
  }
}

/** Judges a foreign-registered plate: region, four digits and a class letter. */
export class KyrgyzstanForeignValidator extends GatedPlateValidator {
  readonly gateGroup = 'letters';

  static readonly reasonRegion = 'The region code is 01 to 11.';
  static readonly reasonNumber = 'The number is four digits.';
  static readonly reasonLetter = 'The class letter is H, K, M or P.';

  judge(entry: PlateEntry): PlateValidation {
    if (!regionCodes.includes(entry.group('region'))) return invalid(KyrgyzstanForeignValidator.reasonRegion);
    if (!isDigitsOfLength(entry.group('number'), 4)) return invalid(KyrgyzstanForeignValidator.reasonNumber);
    return foreignClasses.includes(entry.group('letters')) ? valid : invalid(KyrgyzstanForeignValidator.reasonLetter);
  }
}

/** Judges a diplomatic, honorary-consul or mission-head plate: a class, an optional mission code, a number and, when dated, a month and year. */
export class KyrgyzstanDiplomaticValidator extends GatedPlateValidator {
  readonly classes: readonly string[];
  readonly numberLength: number;
  readonly hasMission: boolean;
  readonly dated: boolean;

  constructor({ classes, numberLength, hasMission = false, dated = false }: { readonly classes: readonly string[]; readonly numberLength: number; readonly hasMission?: boolean; readonly dated?: boolean }) {
    super();
    this.classes = classes;
    this.numberLength = numberLength;
    this.hasMission = hasMission;
    this.dated = dated;
  }

  static readonly diplomatic = new KyrgyzstanDiplomaticValidator({ classes: diplomaticClasses, numberLength: 3, hasMission: true, dated: true });
  static readonly honorary = new KyrgyzstanDiplomaticValidator({ classes: ['HC'], numberLength: 4, dated: true });
  static readonly mission = new KyrgyzstanDiplomaticValidator({ classes: ['CMD'], numberLength: 3 });

  readonly gateGroup = 'number';

  static readonly reasonClass = 'The class is not one this plate uses.';
  static readonly reasonMission = 'The mission code is 01 to 19 (countries) or 50 to 64 (organisations).';
  static readonly reasonNumber = 'The number has the wrong length.';
  static readonly reasonMonth = 'The month is 01 to 12.';
  static readonly reasonYear = 'The year is two digits.';

  judge(entry: PlateEntry): PlateValidation {
    if (!this.classes.includes(entry.group('class'))) return invalid(KyrgyzstanDiplomaticValidator.reasonClass);
    if (this.hasMission && !missionCodes.includes(entry.group('mission'))) return invalid(KyrgyzstanDiplomaticValidator.reasonMission);
    if (!isDigitsOfLength(entry.group('number'), this.numberLength)) return invalid(KyrgyzstanDiplomaticValidator.reasonNumber);
    if (this.dated) {
      if (!isMonth(entry.group('month'))) return invalid(KyrgyzstanDiplomaticValidator.reasonMonth);
      if (!isDigitsOfLength(entry.group('year'), 2)) return invalid(KyrgyzstanDiplomaticValidator.reasonYear);
    }
    return valid;
  }
}
