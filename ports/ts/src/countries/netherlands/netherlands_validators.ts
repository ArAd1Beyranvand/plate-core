import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, valid } from '../../core/validators/plate_validator';

const consonants = 'BDFGHJKLNPRSTVXZ';
const alphanumeric = /^[A-Z0-9]+$/;
const upper = /^[A-Z]+$/;

/**
 * Judges a Dutch plate, field by field. Reports, never bars a keystroke.
 *
 * Fields are the groups `a`, `b`, `c` of the plate. Each is letters or digits
 * as its slot's alphabet says. Ordinary registrations use only the
 * consonants `BDFGHJKLNPRSTVXZ`; the special series (`CD`, `AA`, `OK`, `WX`,
 * `EM`, `GV`, `BN`) print other letters, so a letter outside the consonants
 * is only reported when a field mixes it into an otherwise ordinary run of
 * three letters. The other article rules (no double zero in some sidecodes,
 * no SD/SS pairs) are series-specific and not enforced.
 */
export class NetherlandsValidator extends GatedPlateValidator {
  readonly gateGroup = 'a';

  static readonly reasonCharacters = 'A field is letters A–Z or digits 0–9 only.';
  static readonly reasonLetters = 'Ordinary plates use only the letters B D F G H J K L N P R S T V X Z.';

  judge(entry: PlateEntry): PlateValidation {
    for (const key of ['a', 'b', 'c']) {
      const field = entry.group(key);
      if (field !== '' && !alphanumeric.test(field)) return invalid(NetherlandsValidator.reasonCharacters);
      if (field.length === 3 && upper.test(field) && field !== 'CDJ' && field !== 'BFG' && !Array.from(field).every((c) => consonants.includes(c))) {
        return invalid(NetherlandsValidator.reasonLetters);
      }
    }
    return valid;
  }
}
