import type { PlateRestriction } from '../values/plate_restriction';
import type { PlateSpec, PlateTextGroup } from '../values/plate_spec';

/** The verdict on a plate; `reason` explains an invalid one and is null when valid. */
export interface PlateValidation {
  readonly reason: string | null;
}

export const valid: PlateValidation = Object.freeze({ reason: null });
export const invalid = (reason: string): PlateValidation => ({ reason });
export const isValid = (v: PlateValidation): boolean => v.reason === null;

/** A plate as it stands, for a validator to judge. */
export class PlateEntry {
  constructor(
    readonly spec: PlateSpec,
    readonly values: readonly (string | null)[],
    /** The focused slot, so a validator can stay quiet about groups the user has not reached. */
    readonly activeIndex: number | null = null,
  ) {}

  /** Canonical value of the group named `key`; '' if none. */
  group(key: string): string {
    return this.spec.valueOfGroup(key, this.values);
  }

  get activeGroup(): PlateTextGroup | null {
    return this.activeIndex === null ? null : this.spec.groupAt(this.activeIndex);
  }
}

/** ASCII 0-9 only, never Unicode digits. */
export const isDigits = (value: string): boolean => /^[0-9]+$/.test(value);

/** Length is in code units, which is safe because isDigits passes ASCII alone. */
export const isDigitsOfLength = (value: string, length: number): boolean => value.length === length && isDigits(value);

/** Judges a plate. It never prevents input. */
export interface PlateValidator {
  validate(entry: PlateEntry): PlateValidation;
}

/** The verdict a spec's restrictions give on `entry`, or null when none is broken. */
export function restrictionVerdict(entry: PlateEntry): PlateValidation | null {
  const broken = entry.spec.restrictionViolatedBy(entry.values) as PlateRestriction | null;
  return broken === null ? null : invalid(broken.reason);
}

/** A validator that stays quiet until `gateGroup` has content, so only a whole plate is judged. */
export abstract class GatedPlateValidator implements PlateValidator {
  abstract readonly gateGroup: string;

  abstract judge(entry: PlateEntry): PlateValidation;

  validate(entry: PlateEntry): PlateValidation {
    return restrictionVerdict(entry) ?? (entry.group(this.gateGroup) === '' ? valid : this.judge(entry));
  }
}
