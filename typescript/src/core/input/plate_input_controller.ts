/**
 * What a PlateController drives: a plate's focus and navigation. The DOM
 * adapter implements it over absolutely positioned inputs; a host may attach another.
 */
export interface PlateInputTarget {
  readonly activeIndex: number | null;
  /** Whether the platform keyboard has been requested under keypadFirst. */
  readonly systemKeyboardActive: boolean;
  submitCharacter(character: string): void;
  backspaceCharacter(): void;
  focusFirstEmptySlot(): void;
  focusSlot(index: number): void;
}
