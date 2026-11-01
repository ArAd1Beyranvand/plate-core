import { splitRunes } from '../alphabet/plate_alphabet';
import type { PlateSpec } from '../values/plate_spec';
import type { PlateInputTarget } from './plate_input_controller';
import type { PlateInputSource } from './plate_input_source';
import { resolveSlotBehavior } from './slot_behavior';
import { Store } from './store';

/** What the focus adapter's text fields need; an HTMLInputElement fits. */
export interface PlateTextField {
  value: string;
  setSelectionRange(start: number, end: number): void;
}

/**
 * The pure half of a plate's input: active index, submit, backspace, advance.
 * Reads values through readValues and writes through commit, so it is
 * independent of host state. Bound to its spec: a spec change builds a new machine.
 *
 * The focus adapter owns the inputs: it moves DOM focus on onFocusRequested and
 * reports DOM focus back through focusChanged (an editable mirror reports its source).
 */
export class PlateInputMachine implements PlateInputTarget {
  readonly spec: PlateSpec;
  readonly readValues: () => readonly (string | null)[];
  /** Writes one slot's value back to the host; '' clears. Focus must not advance past a refusal. */
  readonly commit: (index: number, value: string) => boolean;
  inputSource: PlateInputSource;
  /** Fired when the focused slot changes or focus leaves the plate. */
  onActiveIndexChanged?: (index: number | null) => void;
  /** Fired when a chosen slot under the sheet behavior is reached. */
  onSheetRequested?: (index: number) => void;
  /** The adapter focuses the input at index. */
  onFocusRequested?: (index: number) => void;

  /**
   * Under keypadFirst, whether typed slots use the platform keyboard: the
   * adapter sets inputmode="text" while true and "none" otherwise.
   */
  readonly systemKeyboard = new Store(false);

  // Seeded, unannounced, so a keypad driven by activeIndex starts on the first slot's alphabet.
  private _activeIndex: number | null;

  constructor(o: {
    spec: PlateSpec;
    readValues: () => readonly (string | null)[];
    commit: (index: number, value: string) => boolean;
    inputSource: PlateInputSource;
    onActiveIndexChanged?: (index: number | null) => void;
    onSheetRequested?: (index: number) => void;
    onFocusRequested?: (index: number) => void;
  }) {
    this.spec = o.spec;
    this.readValues = o.readValues;
    this.commit = o.commit;
    this.inputSource = o.inputSource;
    this.onActiveIndexChanged = o.onActiveIndexChanged;
    this.onSheetRequested = o.onSheetRequested;
    this.onFocusRequested = o.onFocusRequested;
    this._activeIndex = o.spec.slots.length > 0 ? 0 : null;
  }

  get activeIndex(): number | null {
    return this._activeIndex;
  }

  get systemKeyboardActive(): boolean {
    return this.systemKeyboard.value;
  }

  /** The plate takes the platform keyboard until a keypad key is pressed or focus leaves the plate. */
  requestSystemKeyboard(): void {
    this.systemKeyboard.value = true;
  }

  /** The adapter reports where DOM focus is; null when it left the plate. */
  focusChanged(active: number | null): void {
    // A plate without focus falls back to the keypad.
    if (active === null) this.systemKeyboard.value = false;
    if (active === this._activeIndex) return;
    this._activeIndex = active;
    this.onActiveIndexChanged?.(active);
  }

  private requestFocus(index: number): void {
    this.onFocusRequested?.(index);
    this.focusChanged(index);
  }

  /** Moves focus past index: to the next slot, or its sheet if chosen. At the end focus stays. */
  advanceFrom(index: number): void {
    const next = this.spec.nextIndex(index);
    if (next === null) return;
    const behavior = resolveSlotBehavior({ mode: 'input', input: this.spec.slots[next].alphabet.input, source: this.inputSource });
    if (behavior === 'sheet') this.onSheetRequested?.(next);
    else this.requestFocus(next);
  }

  /** Shows stored in field in display form, caret at the end, only when the text differs. */
  static setText(field: PlateTextField | null | undefined, stored: string | null, render: (s: string) => string): void {
    if (!field) return;
    const text = stored ? render(stored) : '';
    if (field.value === text) return;
    field.value = text;
    field.setSelectionRange(text.length, text.length);
  }

  submitCharacter(c: string): void {
    // A keypad key means the keypad is wanted, not the platform keyboard.
    this.systemKeyboard.value = false;
    const index = this._activeIndex;
    if (index === null) return;
    const slot = this.spec.slots[index];
    const next = (this.readValues()[index] ?? '') + slot.alphabet.canonical(c);
    if (!slot.accepts(next)) return;
    if (!this.commit(index, next)) return;
    if (slot.isFull(next)) this.advanceFrom(index);
  }

  backspaceCharacter(): void {
    this.systemKeyboard.value = false;
    const values = this.readValues();
    // Focus can drop once the plate is complete; the keypad still deletes from the end.
    let index = this._activeIndex ?? values.length - 1;
    if (this._activeIndex === null) while (index >= 0 && !values[index]) index--;
    if (index < 0) return;
    const current = values[index];
    const empty = !current;
    const target = empty ? this.spec.previousIndex(index) : index;
    if (target === null) return;
    const held = splitRunes(empty ? (values[target] ?? '') : current);
    // The Dart reference throws when stepping back onto an empty slot too.
    if (held.length === 0) throw new RangeError('backspace on two empty slots');
    this.commit(target, held.slice(0, -1).join(''));
    this.requestFocus(target);
  }

  focusFirstEmptySlot(): void {
    const values = this.readValues();
    const i = this.spec.slots.findIndex((s, k) => !s.isFull(values[k]));
    this.requestFocus(i < 0 ? 0 : i);
  }

  focusSlot(index: number): void {
    if (index < 0 || index >= this.spec.slots.length) return;
    this.requestFocus(index);
  }

  dispose(): void {
    this.systemKeyboard.dispose();
  }
}
