import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

const series = /^[ABKMHPCTX]{1,2}$/;

const regionCodes = [
  'A', 'B', 'BH', 'BP', 'BT', 'E', 'EB', 'EH', 'K', 'KH', 'M', 'H', 'OB',
  'P', 'PA', 'PB', 'PK', 'PP', 'C', 'CA', 'CB', 'CH', 'CM', 'CO', 'CC',
  'CT', 'T', 'TX', 'Y', 'X',
];

/** The error every layer shows for a refused mission code. */
const missionNotFound = 'COUNTRY NOT FOUND';
const refusedMissions = ['22'];

/**
 * Judges a registration plate (`C 5096 MK`) by its `region`, `number` and
 * `series` registers: a province code from the table (or `EA`/`EM`), four
 * digits and a series of one or two of the nine series letters. Reports,
 * never bars a keystroke.
 */
export class BulgariaValidator extends GatedPlateValidator {
  readonly gateGroup = 'series';

  static readonly reasonRegion = 'The province code is not one of the table.';
  static readonly reasonNumber = 'The number is four digits.';
  static readonly reasonSeries = 'The series is one or two of A B K M H P C T X.';

  judge(entry: PlateEntry): PlateValidation {
    const region = entry.group('region');
    if (!regionCodes.includes(region) && region !== 'EA' && region !== 'EM') return invalid(BulgariaValidator.reasonRegion);
    if (!isDigitsOfLength(entry.group('number'), 4)) return invalid(BulgariaValidator.reasonNumber);
    return series.test(entry.group('series')) ? valid : invalid(BulgariaValidator.reasonSeries);
  }
}

/**
 * Judges the army `BA 509 096` and civil-protection `CP 59 096` plates by
 * their `code`, `first` and `second` registers.
 */
export class BulgariaServiceValidator extends GatedPlateValidator {
  readonly gateGroup = 'second';

  static readonly reasonCode = 'The code is BA (army) or CP (civil protection).';
  static readonly reasonDigits = 'BA takes 3 + 3 digits, CP 2 + 3.';

  judge(entry: PlateEntry): PlateValidation {
    const code = entry.group('code');
    if (code !== 'BA' && code !== 'CP') return invalid(BulgariaServiceValidator.reasonCode);
    return isDigitsOfLength(entry.group('first'), code === 'BA' ? 3 : 2) && isDigitsOfLength(entry.group('second'), 3)
      ? valid
      : invalid(BulgariaServiceValidator.reasonDigits);
  }
}

/**
 * Judges a foreigner's plate (`XX 9043 19`, `XH` since 2019) and a
 * diplomatic one (`CC 7711 20`) by their `region` and `year`, and, for a
 * diplomatic plate, the `mission` and `number` registers. The mission `22`
 * is refused on its own account as well as by the spec's restriction.
 */
export class BulgariaStampedValidator extends GatedPlateValidator {
  readonly gateGroup = 'year';

  static readonly reasonPrefix = 'Foreigners are XX or XH; diplomats C, CC or CT.';
  static readonly reasonDigits = "Four digits (a diplomat's two mission digits, then two) and a two-digit year.";

  override validate(entry: PlateEntry): PlateValidation {
    if (refusedMissions.includes(entry.group('mission'))) return invalid(missionNotFound);
    return super.validate(entry);
  }

  judge(entry: PlateEntry): PlateValidation {
    if (!['XX', 'XH', 'C', 'CC', 'CT'].includes(entry.group('region'))) return invalid(BulgariaStampedValidator.reasonPrefix);
    const digits = entry.spec.textGroups.some((g) => g.key === 'mission')
      ? isDigitsOfLength(entry.group('mission'), 2) && isDigitsOfLength(entry.group('number'), 2)
      : isDigitsOfLength(entry.group('number'), 4);
    return digits && isDigitsOfLength(entry.group('year'), 2) ? valid : invalid(BulgariaStampedValidator.reasonDigits);
  }
}
