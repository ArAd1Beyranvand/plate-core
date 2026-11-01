import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

const personalised = /^[A-Z0-9]{1,10}$/;
const lettersRe = /^[A-Z]{3}$/;

/**
 * Judges a Maltese plate by its groups. Reports, never bars a keystroke.
 *
 * A private plate is three letters and three digits (`WTO 110`); the bus
 * (`BUS 105`), trailer (`TR 1818`) and taxi (`TAXI 119 M`) plates have fixed
 * text and are judged on the digits and the island letter alone. A
 * personalised plate is one to ten letters and digits; its slots cannot hold
 * more than eight.
 */
export class MaltaValidator extends GatedPlateValidator {
  readonly gateGroup = 'digits';

  static readonly reasonPrivate = 'A plate is three letters, three digits.';
  static readonly reasonBus = 'A bus plate is BUS and three digits.';
  static readonly reasonTrailer = 'A trailer plate is TR and four digits.';
  static readonly reasonTaxi = 'A taxi plate is TAXI, three digits and M or G.';
  static readonly reasonPersonalised = 'A personalised plate is one to ten letters or digits.';

  judge(entry: PlateEntry): PlateValidation {
    const digits = entry.group('digits');
    const letters = entry.group('letters');
    const island = entry.group('island');
    const text = entry.group('text');
    const V = MaltaValidator;
    if (text !== '') return personalised.test(text) ? valid : invalid(V.reasonPersonalised);
    if (island !== '') return isDigitsOfLength(digits, 3) && (island === 'M' || island === 'G') ? valid : invalid(V.reasonTaxi);
    if (letters !== '') return isDigitsOfLength(digits, 3) && lettersRe.test(letters) ? valid : invalid(V.reasonPrivate);
    return isDigitsOfLength(digits, 3) || isDigitsOfLength(digits, 4) ? valid : invalid(V.reasonBus);
  }
}
