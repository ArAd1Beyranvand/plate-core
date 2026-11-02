import { GatedPlateValidator, type PlateEntry, type PlateValidation, type PlateValidator, invalid, isDigits, isDigitsOfLength, restrictionVerdict, valid } from '../../core/validators/plate_validator';

const keysOf = (codes: string): ReadonlySet<string> => new Set(codes.split(' '));
const stateCodes = keysOf('AN AP AR AS BR CG CH DD DL GA GJ HP HR JH JK KA KL LA LD MH ML MN MP MZ NL OD PB PY RJ SK TG TN TR UK UP WB UA OR DN TS');
const militaryClasses = keysOf('A B C D E F G H J K P Q R X');
const missions = keysOf('CD CC UN');
const tradeCategories = keysOf('A B C D E F G H I J');

/** Judges an Indian plate, once every slot is complete, against the code tables of the groups its spec has. Reports, never bars a keystroke. */
export class IndiaValidator implements PlateValidator {
  static readonly reasonState = 'Not a state or union-territory code.';
  static readonly reasonRto = 'RTO number 00 is not issued.';
  static readonly reasonNumber = 'Number 0000 is not issued.';
  static readonly reasonMonth = 'The month is not 01–12.';
  static readonly reasonClass = 'Not an armed-forces vehicle class.';
  static readonly reasonMission = 'Mission type is CD, CC or UN.';
  static readonly reasonCategory = 'Trade category is A to J.';

  validate(entry: PlateEntry): PlateValidation {
    const slots = entry.spec.slots;
    if (entry.values.length < slots.length || !slots.every((s, i) => s.isComplete(entry.values[i]))) return valid;
    const keys = new Set(entry.spec.effectiveTextGroups.map((g) => g.key));
    const g = (key: string) => entry.group(key);

    if (keys.has('state') && !stateCodes.has(g('state'))) return invalid(IndiaValidator.reasonState);
    if (keys.has('rto') && g('rto') === '00') return invalid(IndiaValidator.reasonRto);
    if (keys.has('number') && isDigits(g('number')) && Number(g('number')) === 0) return invalid(IndiaValidator.reasonNumber);
    if (keys.has('date')) {
      const month = Number.parseInt(g('date').slice(0, 2), 10) || 0;
      if (month < 1 || month > 12) return invalid(IndiaValidator.reasonMonth);
    }
    if (keys.has('class') && !militaryClasses.has(g('class'))) return invalid(IndiaValidator.reasonClass);
    if (keys.has('type') && !missions.has(g('type'))) return invalid(IndiaValidator.reasonMission);
    if (keys.has('category') && !tradeCategories.has(g('category'))) return invalid(IndiaValidator.reasonCategory);
    return valid;
  }
}
