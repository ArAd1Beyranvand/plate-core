import { GatedPlateValidator, type PlateEntry, type PlateValidation, invalid, isDigitsOfLength, valid } from '../../core/validators/plate_validator';

const LATIN = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
const letters = new Set(Array.from(LATIN).filter((c) => c !== 'I' && c !== 'O'));
const diplomaticLetters = new Set('ACEMP');
const mixed = new Set([...letters, ...'0123456789']);

/** Whether `v` is exactly `n` characters, all from `set`. */
const within = (set: ReadonlySet<string>, v: string, n: number): boolean => {
  const chars = Array.from(v);
  return chars.length === n && chars.every((c) => set.has(c));
};

const ok = (good: boolean, reason: string): PlateValidation => (good ? valid : invalid(reason));

/**
 * Judges a Montenegrin plate by its keyed groups; which groups exist depends
 * on the design, read off the spec id. Reports, never bars a keystroke.
 *
 * - `me.regular`: `region` (a municipal code, two letters), `letters` (two,
 *   no `I` or `O`) and `serial` (three digits): `PG AB 123`. The article
 *   allows any letter-digit combination on paid custom plates; this judges
 *   the standard series.
 * - `me.diplomatic`: `code` (two or three digits), `letter` (`A`, `M`, `P`,
 *   `E` or `C`) and `serial` (three digits): `53 A 002`.
 * - `me.temporary`: `region`, `year` (two digits) and `serial` (three).
 * - `me.agricultural`: `region`, `letters` (two) and `serial` (two digits).
 * - `me.moped`: `region` and `serial` (four letters or digits).
 */
export class MontenegroValidator extends GatedPlateValidator {
  readonly gateGroup = 'serial';

  static readonly reasonRegion = 'The municipal code is two letters, e.g. PG.';
  static readonly reasonDigits = 'Check the number of digits.';
  static readonly reasonLetters = 'Check the series letters.';

  static readonly municipalities: readonly string[] = [
    'AN', 'BA', 'BD', 'BP', 'BR', 'CT', 'DG', 'GS', 'HN', 'KL', 'KO', 'MK',
    'NK', 'PG', 'PL', 'PT', 'PŽ', 'PV', 'RO', 'ŠN', 'TV', 'TZ', 'UL', 'ZT',
    'ŽB',
  ];

  judge(entry: PlateEntry): PlateValidation {
    const V = MontenegroValidator;
    const id = entry.spec.id;
    if (id === 'me.diplomatic') {
      const code = entry.group('code');
      return ok(
        (isDigitsOfLength(code, 2) || isDigitsOfLength(code, 3)) && within(diplomaticLetters, entry.group('letter'), 1) && isDigitsOfLength(entry.group('serial'), 3),
        V.reasonDigits,
      );
    }
    if (!V.municipalities.includes(entry.group('region'))) return invalid(V.reasonRegion);
    const serial = entry.group('serial');
    switch (id) {
      case 'me.regular':
        return ok(within(letters, entry.group('letters'), 2) && isDigitsOfLength(serial, 3), V.reasonLetters);
      case 'me.temporary':
        return ok(isDigitsOfLength(entry.group('year'), 2) && isDigitsOfLength(serial, 3), V.reasonDigits);
      case 'me.agricultural':
        return ok(within(letters, entry.group('letters'), 2) && isDigitsOfLength(serial, 2), V.reasonLetters);
      default:
        return ok(within(mixed, serial, 4), V.reasonDigits);
    }
  }
}
