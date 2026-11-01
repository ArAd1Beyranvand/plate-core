import { type PlateEntry, type PlateValidation, type PlateValidator, invalid, isDigitsOfLength, restrictionVerdict, valid } from '../../core/validators/plate_validator';

const regionCodes = [
  'BJ', 'BM', 'ČK', 'DA', 'DE', 'DJ', 'DU', 'GS', 'IM', 'KA', 'KC', 'KR',
  'KT', 'KŽ', 'MA', 'NA', 'NG', 'OG', 'OS', 'PU', 'PŽ', 'RI', 'SB', 'SK',
  'SL', 'ST', 'ŠI', 'VK', 'VT', 'VU', 'VŽ', 'ZD', 'ZG', 'ŽU',
];

/**
 * Judges a Croatian plate by its groups.
 *
 * Registration (`region`, `number`, `letters`): a city code, three or four
 * digits and one or two letters (`ZG 543-AA`). Customized (`region`, `word`,
 * `suffix`): a city code, a chosen word of four to five letters, then one or
 * two digits. Police (`first`, `second`): three plus three digits.
 * Diplomatic (`mission`, `class`, `serial`): three digits, a letter, three
 * digits. Reports, never bars a keystroke.
 */
export class CroatiaValidator implements PlateValidator {
  static readonly reasonRegion = 'The city code is two letters, e.g. ZG.';
  static readonly reasonNumber = 'The number is three or four digits.';
  static readonly reasonLetters = 'The series is one or two letters.';
  static readonly reasonWord = 'The word is four to five letters.';
  static readonly reasonSuffix = 'The suffix is one or two digits.';
  static readonly reasonPolice = 'Police is three digits, three digits.';
  static readonly reasonDiplomatic = 'Diplomatic is three digits, a letter, three digits.';

  validate(entry: PlateEntry): PlateValidation {
    const broken = restrictionVerdict(entry);
    if (broken !== null) return broken;
    const groups = entry.spec.textGroups;
    if (groups.length === 0 || entry.group(groups[groups.length - 1].key ?? '') === '') return valid;
    const reason = CroatiaValidator.reasonFor(entry);
    return reason === null ? valid : invalid(reason);
  }

  private static reasonFor(e: PlateEntry): string | null {
    const first = e.spec.textGroups[0].key;
    if (first === 'mission') {
      return isDigitsOfLength(e.group('mission'), 3) && /^[A-Z]$/.test(e.group('class')) && isDigitsOfLength(e.group('serial'), 3) ? null : CroatiaValidator.reasonDiplomatic;
    }
    if (first === 'first') {
      return isDigitsOfLength(e.group('first'), 3) && isDigitsOfLength(e.group('second'), 3) ? null : CroatiaValidator.reasonPolice;
    }
    if (!regionCodes.includes(e.group('region'))) return CroatiaValidator.reasonRegion;
    if (e.spec.textGroups.some((g) => g.key === 'word')) {
      if (!/^[A-Z]{4,5}$/.test(e.group('word'))) return CroatiaValidator.reasonWord;
      return /^[0-9]{1,2}$/.test(e.group('suffix')) ? null : CroatiaValidator.reasonSuffix;
    }
    if (!/^[0-9]{3,4}$/.test(e.group('number'))) return CroatiaValidator.reasonNumber;
    return /^[A-Z]{1,2}$/.test(e.group('letters')) ? null : CroatiaValidator.reasonLetters;
  }
}
