import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, valid } from '../../core/validators/plate_validator';

/** A field's shape, one character per position: `a` letter, `n` digit, `z` digit 1-9, `x` letter but I and O, `m` letter or digit; else literal. */
type Field = readonly [shape: string, min?: number];

const LETTERS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
const DIGITS = '0123456789';

function matches(s: string, c: string): boolean {
  switch (s) {
    case 'a': return LETTERS.includes(c);
    case 'x': return LETTERS.includes(c) && c !== 'I' && c !== 'O';
    case 'n': return DIGITS.includes(c);
    case 'z': return DIGITS.includes(c) && c !== '0';
    case 'm': return LETTERS.includes(c) || DIGITS.includes(c);
    default: return c === s;
  }
}

/** Whether `value` is a whole, legal field. */
function accepts([shape, min]: Field, value: string): boolean {
  if (value.length < (min ?? shape.length) || value.length > shape.length) return false;
  return [...value].every((c, i) => matches(shape[i], c));
}

const formats: Record<string, readonly Field[]> = {
  'au.nsw': [['aa'], ['nn'], ['xa']],
  'au.nt': [['Ca'], ['nn'], ['aa']],
  'au.federalInterstate': [['aa'], ['nn'], ['aa']],
  'au.act': [['Yaa'], ['nna']],
  'au.qld': [['nnn'], ['mmm']],
  'au.sa': [['Snnn'], ['aaa']],
  'au.tas': [['a'], ['nn'], ['aa']],
  'au.vic': [['zaa'], ['zaa']],
  'au.wa': [['zaaa'], ['nnn']],
  'au.nationalHeavyVehicle': [['aa'], ['nnaa']],
  'au.army': [['nn'], ['nnnn', 3]],
  'au.airForce': [['nnnnnn']],
  'au.defence': [['a'], ['mmmmm']],
  'au.diplomatic': [['Da'], ['nnnnn', 4]],
};

/**
 * Judges an Australian plate against its design's formats. Reports,
 * never bars a keystroke.
 *
 * Quiet until the first field has a character. Each field must then be whole
 * and match its shape (the NSW suffix skips `I` and `O`; WA and VIC skip a
 * leading 0). The jurisdictions have different formats, so the spec's id
 * picks them; an unknown spec is valid.
 */
export class AustraliaValidator extends GatedPlateValidator {
  readonly gateGroup = 'f0';

  static readonly reasonField = "A field does not fit this plate's format.";

  judge(entry: PlateEntry): PlateValidation {
    const fields = formats[entry.spec.id];
    if (!fields) return valid;
    return fields.every((f, i) => accepts(f, entry.group(`f${i}`))) ? valid : invalid(AustraliaValidator.reasonField);
  }
}
