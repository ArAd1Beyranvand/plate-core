import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, valid } from '../../core/validators/plate_validator';
import { RussiaMissions } from './russia_missions';

const codes = new Set('01 02 03 04 05 06 07 08 09 10 102 105 11 113 116 12 121 122 123 124 125 126 13 131 133 134 136 138 14 142 147 15 150 152 154 155 156 159 16 161 163 164 166 17 172 173 174 177 178 18 186 19 190 193 196 197 198 199 20 21 22 224 23 24 25 250 252 26 27 28 29 30 31 32 323 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 550 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 702 71 716 72 73 74 75 750 76 761 763 77 774 777 778 78 79 790 797 799 83 86 87 88 89 90 91 93 94 95 96 97 977 98 99 997'.split(' '));
const militaryCodes = new Set('09 10 12 14 15 16 17 18 20 21 23 25 26 27 29 32 34 35 39 43 45 50 56 65 67'.split(' '));

/** Judges a registration on any RussiaPlates spec. Reports, never bars a
 * keystroke. The region is a formation code on the military plate. */
export class RussiaValidator extends GatedPlateValidator {
  readonly gateGroup = 'region';

  static readonly reasonField = 'A field has the wrong length or letters.';
  static readonly reasonRegion = 'The region code is not in use.';
  static readonly reasonMission = 'The mission code is not in use.';
  static readonly reasonNumber = 'The diplomatic number is one digit after CD, three after D or T.';

  judge(entry: PlateEntry): PlateValidation {
    const spec = entry.spec;
    for (let i = 0; i < spec.slots.length; i++) {
      const slot = spec.slots[i];
      const value = entry.group(spec.textGroups[i].key!);
      const whole = slot.alphabet.input === 'chosen';
      if (!slot.accepts(value) || (!whole && (value.length < slot.minLength || value.length > slot.length))) {
        return invalid(RussiaValidator.reasonField);
      }
    }
    const region = entry.group('region');
    if (spec.id === 'ru.diplomatic') {
      if (!Object.hasOwn(RussiaMissions.all, entry.group('code'))) {
        return invalid(RussiaValidator.reasonMission);
      }
      const want = entry.group('status') === 'CD' ? 1 : 3;
      if (entry.group('number').length !== want) {
        return invalid(RussiaValidator.reasonNumber);
      }
    }
    const known = spec.id === 'ru.military' ? militaryCodes.has(region) : codes.has(region);
    return known ? valid : invalid(RussiaValidator.reasonRegion);
  }
}
