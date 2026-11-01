import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

const fieldKeys = ['first', 'second', 'third'];

/** Parses a format id such as `aaa-dd-dd` into its fields. */
const fieldsOf = (format: string) => format.split('-').map((p) => ({ letters: p[0] === 'a', length: p.length }));

/**
 * Judges a Mexican plate of one format id (`aaa-dd-dd`, `aa-dd-ddd`, ...),
 * field by field. Reports, never bars a keystroke.
 *
 * The article gives the shapes (`ABC-12-34`, `AB-12-345`, `ABC-123-A`,
 * `AB-1234-A`, `12-34-ABC`, `123-ABC`) and one letter rule: Mexico City does
 * not issue I, O or Q. The numbering is national, so no letter pair is tied
 * to a state here.
 */
export class MexicoValidator extends GatedPlateValidator {
  readonly format: string;
  private readonly fields: { letters: boolean; length: number }[];

  constructor(o: { readonly format: string } = { format: 'aaa-dd-dd' }) {
    super();
    this.format = o.format;
    this.fields = fieldsOf(o.format);
  }

  get gateGroup(): string {
    return fieldKeys[this.fields.length - 1];
  }

  static readonly reasonCityLetters = 'Letters I, O and Q are not used.';

  judge(entry: PlateEntry): PlateValidation {
    for (let i = 0; i < this.fields.length; i++) {
      const field = this.fields[i];
      const value = entry.group(fieldKeys[i]);
      const ok = field.letters ? new RegExp(`^[A-Z]{${field.length}}$`).test(value) : isDigitsOfLength(value, field.length);
      if (!ok) return invalid(`Field ${i + 1} is ${field.length} ${field.letters ? 'letter' : 'digit'}${field.length === 1 ? '' : 's'}.`);
      if (this.format === 'ddd-aaa' && field.letters && /[IOQ]/.test(value)) return invalid(MexicoValidator.reasonCityLetters);
    }
    return valid;
  }
}
