import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

const suffixes: ReadonlySet<string> = new Set(
  'АР БН БР БӨ БУ ГА ГС ДА ДГ ДО ДУ ОР ХЭ ХО ХӨ НА ӨМ ӨВ СЭ СҮ СБ ТӨ УБ УН УА УЕ УК УВ ЗА'.split(' '),
);
const letters: ReadonlySet<string> = new Set('А Б В Г Д Е Ё Ж З И Й К Л М Н О Ө П Р С Т У Ү Ф Х Ц Ч Ш Щ Ъ Ы Ь Э Ю Я'.split(' '));

/**
 * Judges `1234 УБ А` by its groups `number`, `suffix` and `serial`.
 *
 * Four digits (leading zeroes kept), a two-letter aimag suffix from the
 * article's table and one further Cyrillic letter. Gated on the serial, so
 * nothing is reported until the plate is complete. Reports, never bars a
 * keystroke.
 */
export class MongoliaValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonNumber = 'The number is four digits.';
  static readonly reasonSuffix = 'The aimag suffix is not a known one.';
  static readonly reasonSerial = 'The serial is one Cyrillic letter.';

  judge(entry: PlateEntry): PlateValidation {
    if (!isDigitsOfLength(entry.group('number'), 4)) return invalid(MongoliaValidator.reasonNumber);
    if (!suffixes.has(entry.group('suffix'))) return invalid(MongoliaValidator.reasonSuffix);
    if (!letters.has(entry.group('serial'))) return invalid(MongoliaValidator.reasonSerial);
    return valid;
  }
}
