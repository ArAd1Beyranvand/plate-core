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

/** ASCII A-Z only, min..max long. */
export const isLetters = (value: string, min: number, max = min): boolean => value.length >= min && value.length <= max && /^[A-Z]+$/.test(value);

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

/** One field rule of a `RuledPlateValidator`: the group named `group` must match `pattern` whole, or the plate is invalid
 * for `reason`. An `optional` group may also be empty. Keep classes explicit (`[0-9]`, not `\d`) so only ASCII passes. */
export class PlateCheck {
  private readonly re: RegExp;

  constructor(
    readonly group: string,
    pattern: string,
    readonly reason: string,
    private readonly optional = false,
  ) {
    this.re = new RegExp(`^(?:${pattern})$`);
  }

  passes(value: string): boolean {
    return (this.optional && value === '') || this.re.test(value);
  }
}

/** A gated validator that is a list of `checks`, judged in order; the first to fail gives the verdict. The gate is the
 * last check's group unless a subclass says otherwise. */
export abstract class RuledPlateValidator extends GatedPlateValidator {
  abstract readonly checks: readonly PlateCheck[];

  get gateGroup(): string {
    return this.checks[this.checks.length - 1]!.group;
  }

  judge(entry: PlateEntry): PlateValidation {
    const failed = this.checks.find((c) => !c.passes(entry.group(c.group)));
    return failed ? invalid(failed.reason) : valid;
  }
}
