/** A value a named register may never hold, and the error shown when something tries to store it. */
export class PlateRestriction {
  constructor(
    /** The PlateTextGroup.key of the register this restriction watches. */
    readonly group: string,
    /** Refused register values, in canonical (storage) form. */
    readonly values: readonly string[],
    readonly reason: string,
  ) {}

  matches(groupValue: string): boolean {
    return this.values.includes(groupValue);
  }
}

/** Thrown by PlateSpec.checkRestrictions; the message is the restriction's reason. */
export class PlateRestrictionException extends Error {
  override readonly name = 'PlateRestrictionError';

  constructor(readonly restriction: PlateRestriction) {
    super(restriction.reason);
  }
}
