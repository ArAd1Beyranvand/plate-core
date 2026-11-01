import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, valid } from '../../core/validators/plate_validator';

/** Judges a registration on any [AbkhaziaPlates] spec. Reports, never bars a
 * keystroke. The diplomatic number is one digit after `CD`, three after `D`
 * or `T` (assumed from Russia). */
export class AbkhaziaValidator extends GatedPlateValidator {
  readonly gateGroup = 'series';

  static readonly reasonField = 'A field has the wrong length or letters.';
  static readonly reasonNumber = 'The diplomatic number is one digit after CD, three after D or T.';

  judge(entry: PlateEntry): PlateValidation {
    const spec = entry.spec;
    for (let i = 0; i < spec.slots.length; i++) {
      const slot = spec.slots[i];
      const value = entry.group(spec.textGroups[i].key!);
      const whole = slot.alphabet.input === 'chosen';
      if (!slot.accepts(value) || (!whole && (value.length < slot.minLength || value.length > slot.length))) {
        return invalid(AbkhaziaValidator.reasonField);
      }
    }
    if (spec.id === 'diplomatic') {
      const want = entry.group('status') === 'CD' ? 1 : 3;
      if (entry.group('number').length !== want) {
        return invalid(AbkhaziaValidator.reasonNumber);
      }
    }
    return valid;
  }
}
