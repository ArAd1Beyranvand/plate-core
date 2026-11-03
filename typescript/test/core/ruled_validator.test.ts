import { expect, it } from 'vitest';
import { PlateCheck, type PlateEntry, RuledPlateValidator } from '../../src/core/validators/plate_validator';

/** An entry that reads its groups from a record and has no restrictions. */
const entry = (groups: Record<string, string>) => ({ group: (k: string) => groups[k] ?? '', spec: { restrictionViolatedBy: () => null } }) as unknown as PlateEntry;

class Plate extends RuledPlateValidator {
  readonly checks = [new PlateCheck('letters', '[A-Z]{2}', 'two letters'), new PlateCheck('tail', '[0-9]{1,2}', 'a tail', true), new PlateCheck('serial', '[0-9]{4}', 'four digits')];
}

it('a check matches its whole group, and an optional one may be empty', () => {
  expect(new PlateCheck('g', '[A-Z]{2}', 'r').passes('AB')).toBe(true);
  expect(new PlateCheck('g', '[A-Z]{2}', 'r').passes('ABC')).toBe(false);
  expect(new PlateCheck('g', 'A|B', 'r').passes('AB')).toBe(false);
  expect(new PlateCheck('g', '[0-9]+', 'r').passes('٣')).toBe(false);
  expect(new PlateCheck('g', '[0-9]+', 'r', true).passes('')).toBe(true);
});

it('the first failing check gives the reason, and the last check is the gate', () => {
  const v = new Plate();
  expect(v.gateGroup).toBe('serial');
  expect(v.validate(entry({ letters: 'AB', serial: '1234' })).reason).toBeNull();
  expect(v.validate(entry({ letters: 'A', serial: '12' })).reason).toBe('two letters');
  expect(v.validate(entry({ letters: 'AB', tail: '123', serial: '1234' })).reason).toBe('a tail');
  expect(v.validate(entry({ letters: 'AB', serial: '12' })).reason).toBe('four digits');
});

it('stays quiet until the gate group has content', () => {
  expect(new Plate().validate(entry({ letters: 'A' })).reason).toBeNull();
});
