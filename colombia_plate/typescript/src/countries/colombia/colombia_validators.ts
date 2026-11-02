import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

/** One series of plate: its letters (the fixed ones included), digits, order and leading letters. */
interface Series {
  readonly english: string;
  readonly letters: number;
  readonly digits: number;
  readonly digitsFirst?: boolean;
  readonly fixed: string;
}

const plain = { letters: 3, digits: 3, fixed: '' };

const series: Record<string, Series> = {
  private: { english: 'Private', ...plain },
  commercial: { english: 'Public service', ...plain },
  official: { english: 'Official', ...plain, fixed: 'O' },
  antique: { english: 'Antique car', ...plain },
  mototaxi: { english: 'Auto rickshaw', ...plain, digitsFirst: true },
  trailer: { english: 'Trailer', letters: 1, digits: 5, fixed: 'R' },
  tank: { english: 'Tank truck', letters: 1, digits: 4, fixed: 'T' },
  cc: { english: 'Consular corps', letters: 2, digits: 4, fixed: 'CC' },
  oi: { english: 'International organization', letters: 2, digits: 4, fixed: 'OI' },
  at: { english: 'Non-diplomatic staff', letters: 2, digits: 4, fixed: 'AT' },
};

/**
 * Judges a `ColombiaPlates.standard` value. Reports, never bars a keystroke.
 *
 * Checks what the article states for each series: how many letters and
 * digits, and the letters it always starts with (`O` official, `R`
 * trailer, `T` tank truck, `CC`, `OI`, `AT`).
 */
export class ColombiaValidator extends GatedPlateValidator {
  readonly series: Series;

  constructor({ series: id = 'private' }: { series?: string } = {}) {
    super();
    this.series = series[id];
  }

  get gateGroup(): string {
    return this.series.digitsFirst ? 'letters' : 'number';
  }

  judge(entry: PlateEntry): PlateValidation {
    return ColombiaValidator.validateFields(this.series, { letters: entry.group('letters'), number: entry.group('number') });
  }

  static validateFields(s: Series, { letters, number }: { letters: string; number: string }): PlateValidation {
    if (!new RegExp(`^[A-Z]{${s.letters}}$`).test(letters)) return invalid(`The series is ${s.letters} letter${s.letters === 1 ? '' : 's'}.`);
    if (!letters.startsWith(s.fixed)) return invalid(`${s.english} plates start with ${s.fixed}.`);
    if (!isDigitsOfLength(number, s.digits)) return invalid(`The number is ${s.digits} digits.`);
    return valid;
  }
}

/** Judges a `ColombiaPlates.police` value: two digits, then four. */
export class ColombiaPoliceValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';

  static readonly reason = 'The number is two digits and four digits.';

  judge(entry: PlateEntry): PlateValidation {
    return isDigitsOfLength(entry.group('unit'), 2) && isDigitsOfLength(entry.group('number'), 4) ? valid : invalid(ColombiaPoliceValidator.reason);
  }
}

/** Judges a `ColombiaPlates.diplomatic` value: a type letter, the mission's two-letter country initials, three digits. */
export class ColombiaDiplomaticValidator extends GatedPlateValidator {
  readonly gateGroup = 'number';

  static readonly reasonLetters = 'A type letter and two country initials.';
  static readonly reasonNumber = 'The number is three digits.';

  judge(entry: PlateEntry): PlateValidation {
    if (!/^[A-Z]$/.test(entry.group('type')) || !/^[A-Z]{2}$/.test(entry.group('country'))) return invalid(ColombiaDiplomaticValidator.reasonLetters);
    return isDigitsOfLength(entry.group('number'), 3) ? valid : invalid(ColombiaDiplomaticValidator.reasonNumber);
  }
}
