import { type PlateAlphabet, splitRunes } from '../alphabet/plate_alphabet';
import type { PlateRestriction } from '../values/plate_restriction';
import type { PlateSlot, PlateSpec } from '../values/plate_spec';
import { type PlateValidation, type PlateValidator, PlateEntry, invalid } from '../validators/plate_validator';
import type { PlateInputTarget } from './plate_input_controller';
import { Notifier, type ReadonlyStore, Store, alwaysNull } from './store';

type Values = readonly (string | null)[];

/** What happens to the characters on a plate when adoptSpec swaps its spec. */
export type PlateValuePreservation =
  /** Start the new plate empty. */
  | 'none'
  /** Copy slot by slot while both plates have a slot at that position. */
  | 'byIndex'
  /** Copy register by register, matching PlateTextGroup.key between the specs. */
  | 'byGroupKey';

/**
 * Owns a plate's characters and drives focus and navigation.
 *
 * Listen at three grains: slot(i) fires per position, completed on a
 * full/not-full flip, and subscribe() on every change.
 */
export class PlateController extends Notifier {
  private _spec: PlateSpec;
  private _values: (string | null)[];
  private _slots!: Store<string | null>[];
  private readonly _completed: Store<boolean>;
  private readonly _rejection: Store<PlateRestriction | null>;
  private _target: PlateInputTarget | null = null;

  /** A sample value per slot, drawn faintly; never touches values or completion. */
  readonly hints = new Store<Values | null>(null);

  /** Judges the plate for validation; rejection outranks it. */
  validator: PlateValidator | null;

  constructor(o: { spec: PlateSpec; values?: Values; validator?: PlateValidator | null }) {
    super();
    const spec = (this._spec = o.spec);
    this.validator = o.validator ?? null;
    this._values = spec.slots.map((_, i) => printedCharacter(spec, i));
    const values = o.values;
    if (values) {
      for (let i = 0; i < spec.slotCount && i < values.length; i++) {
        if (printedCharacter(spec, i) !== null) continue;
        this._values[i] = sanitize(spec, i, values[i]);
      }
    }
    const refused = clearRestricted(spec, this._values);
    this.foundSlots();
    this._completed = new Store(this.computeCompleted());
    this._rejection = new Store(refused);
  }

  /**
   * Pours text into the slots in order, each taking up to its length.
   * Characters the current slot refuses, such as separators, are skipped without consuming it.
   */
  static fromText(spec: PlateSpec, text: string): PlateController {
    const values: (string | null)[] = new Array(spec.slotCount).fill(null);
    let index = 0;
    for (const character of splitRunes(text)) {
      if (index >= spec.slotCount) break;
      const slot = spec.slots[index];
      if (!slot.accepts(character)) continue;
      values[index] = (values[index] ?? '') + slot.canonical(character);
      if (slot.isFull(values[index])) index++;
    }
    return new PlateController({ spec, values });
  }

  /** Changed only through adoptSpec. */
  get spec(): PlateSpec {
    return this._spec;
  }

  /** hints at slot index, rendered through alphabet (a mirror's) or the slot's own; null for none. */
  hintAt(index: number, alphabet?: PlateAlphabet): string | null {
    const hint = this.hints.value;
    if (hint === null || index >= hint.length || index >= this._spec.slotCount) return null;
    const v = hint[index];
    if (v == null || v === '') return null;
    return alphabet?.renderAll(v) ?? this._spec.slots[index].render(v);
  }

  /** A snapshot in slot order. */
  get values(): Values {
    return Object.freeze([...this._values]);
  }

  valueAt(index: number): string | null {
    return this._values[index] ?? null;
  }

  /**
   * Stores value at index; '' or null clears. A refused character or a write
   * to a printed slot is a no-op; a restricted value is refused and published
   * on rejection. Returns whether it was stored.
   */
  setAt(index: number, value: string | null): boolean {
    if (index < 0 || index >= this._values.length) return false;
    if (printedCharacter(this._spec, index) !== null) return false;
    const next = sanitize(this._spec, index, value);
    if (next === null && value) return false;
    return this.store(new Map([[index, next]]));
  }

  /** Writes every slot, notifying once. Printed slots keep their character. */
  setValues(values: Values): boolean {
    return this.store(
      new Map(this._values.map((_, i) => [i, printedCharacter(this._spec, i) ?? (i < values.length ? sanitize(this._spec, i, values[i]) : null)])),
    );
  }

  clear(): boolean {
    return this.setValues(new Array(this._values.length).fill(null));
  }

  /** Every text group rendered through its alphabets, joined by sep. */
  text(sep = ' '): string {
    return this._spec.effectiveTextGroups.map((g) => this._spec.renderGroup(g, this._values)).join(sep);
  }

  /** The group named key in canonical form; '' for an unknown key. */
  group(key: string): string {
    return this._spec.valueOfGroup(key, this._values);
  }

  get regionCaption(): string | null {
    return this._spec.resolveRegion?.((k) => this.group(k)) ?? null;
  }

  /**
   * Pours value across the slots of group key, each taking up to its length
   * (a chosen slot takes the rest whole). A refused share clears its slot.
   */
  setGroup(key: string, value: string): boolean {
    const group = this._spec.groupNamed(key);
    if (group === null) return false;
    const characters = splitRunes(value);
    const writes = new Map<number, string | null>();
    let offset = 0;
    for (const index of group.indices) {
      if (printedCharacter(this._spec, index) !== null) continue;
      const slot = this._spec.slots[index];
      const take = slot.alphabet.input === 'chosen' ? characters.length - offset : slot.length;
      writes.set(index, sanitize(this._spec, index, characters.slice(offset, offset + Math.max(take, 0)).join('')));
      offset += take;
    }
    return this.store(writes);
  }

  get isCompleted(): boolean {
    return this._completed.value;
  }

  get isEmpty(): boolean {
    return !this._values.some((v) => v);
  }

  /**
   * The character at index; out of range gives a store that stays null.
   * Stores are recreated by adoptSpec: call slot() per render rather than caching it.
   */
  slot(index: number): ReadonlyStore<string | null> {
    return this._slots[index] ?? alwaysNull;
  }

  /** Fires only when isCompleted flips. */
  get completed(): ReadonlyStore<boolean> {
    return this._completed;
  }

  /** The restriction the last refused write broke; null once a write is stored. */
  get rejection(): ReadonlyStore<PlateRestriction | null> {
    return this._rejection;
  }

  /** Swaps the plate, carrying characters across as preserve directs, and notifies once. */
  adoptSpec(next: PlateSpec, preserve: PlateValuePreservation = 'byGroupKey'): void {
    const migrated = migrate(this._spec, next, this._values, preserve);
    const refused = clearRestricted(next, migrated);
    this._spec = next;
    this._values = migrated;
    this._rejection.value = refused;
    for (const s of this._slots) s.dispose();
    this.foundSlots();
    this._completed.value = this.computeCompleted();
    this.notify();
  }

  /** Null without a validator; a refused write's reason outranks it. */
  get validation(): PlateValidation | null {
    const refused = this._rejection.value;
    if (refused !== null) return invalid(refused.reason);
    return this.validator?.validate(new PlateEntry(this._spec, this._values, this.activeIndex)) ?? null;
  }

  attach(target: PlateInputTarget): void {
    this._target = target;
    this.notify();
  }

  /** Guarded: an old adapter's detach runs after the new one has attached. */
  detach(target: PlateInputTarget): void {
    if (this._target !== target) return;
    this._target = null;
    this.notify();
  }

  notifyActiveSlotChanged(): void {
    this.notify();
  }

  /** Null when unfocused. */
  get activeIndex(): number | null {
    return this._target?.activeIndex ?? null;
  }

  get activeSlot(): PlateSlot | null {
    return this._spec.slotAt(this.activeIndex ?? -1);
  }

  /** True while the platform keyboard stands in for the host's keypad under keypadFirst. */
  get systemKeyboardActive(): boolean {
    return this._target?.systemKeyboardActive ?? false;
  }

  get isAttached(): boolean {
    return this._target !== null;
  }

  /** Commits character to the active slot and advances focus, as typing does. */
  submit(character: string): void {
    this._target?.submitCharacter(character);
  }

  /** Clears the active slot's last character, or the previous slot's if it is empty. */
  backspace(): void {
    this._target?.backspaceCharacter();
  }

  focusFirstEmpty(): void {
    this._target?.focusFirstEmptySlot();
  }

  focusSlot(index: number): void {
    this._target?.focusSlot(index);
  }

  override dispose(): void {
    this._target = null;
    for (const s of this._slots) s.dispose();
    this._completed.dispose();
    this._rejection.dispose();
    this.hints.dispose();
    super.dispose();
  }

  private foundSlots(): void {
    this._slots = this._values.map((v) => new Store(v));
  }

  /** Writes changes unless they break a restriction, then notifies once. */
  private store(changes: ReadonlyMap<number, string | null>): boolean {
    const candidate = [...this._values];
    changes.forEach((v, i) => (candidate[i] = v));
    const broken = this._spec.restrictionViolatedBy(candidate) as PlateRestriction | null;
    if (broken !== null) {
      // Published although no value changed, so listeners show the error.
      this._rejection.value = broken;
      this.notify();
      return false;
    }
    changes.forEach((v, i) => {
      this._values[i] = v;
      this._slots[i].value = v;
    });
    this._completed.value = this.computeCompleted();
    this._rejection.value = null;
    this.notify();
    return true;
  }

  private computeCompleted(): boolean {
    return this._values.length > 0 && this._spec.slots.every((s, i) => s.isComplete(this._values[i]));
  }
}

/** value as the slot stores it: canonical, or null when cleared or refused. */
function sanitize(spec: PlateSpec, index: number, value: string | null | undefined): string | null {
  if (!value) return null;
  const slot = spec.slotAt(index);
  return slot !== null && slot.accepts(value) ? slot.canonical(value) : null;
}

/** The fixed character of a slot whose alphabet holds exactly one: printed, not typed. */
function printedCharacter(spec: PlateSpec, index: number): string | null {
  const slot = spec.slots[index];
  const characters = slot.alphabet.characters;
  return slot.length === 1 && characters.length === 1 ? characters[0] : null;
}

/** Empties, in place, every register that breaks a restriction; returns the last one broken. */
function clearRestricted(spec: PlateSpec, values: (string | null)[]): PlateRestriction | null {
  let broken: PlateRestriction | null = null;
  for (const r of spec.restrictions) {
    if (!r.matches(spec.valueOfGroup(r.group, values))) continue;
    for (const i of spec.indicesOfGroup(r.group)) if (i < values.length) values[i] = null;
    broken = r as PlateRestriction;
  }
  return broken;
}

const hasKeyedGroups = (spec: PlateSpec): boolean => spec.effectiveTextGroups.some((g) => g.key != null);

export function migrate(from: PlateSpec, to: PlateSpec, values: Values, preserve: PlateValuePreservation): (string | null)[] {
  if (preserve === 'none') return new Array(to.slotCount).fill(null);

  const byKey = preserve === 'byGroupKey' && (hasKeyedGroups(from) || hasKeyedGroups(to));
  if (!byKey) return to.slots.map((_, i) => (i < values.length ? sanitize(to, i, values[i]) : null));

  // Printed slots first, so a matched group still wins.
  const result = to.slots.map((_, i) => printedCharacter(to, i));
  for (const target of to.effectiveTextGroups) {
    if (target.key == null) continue;
    const source = from.groupNamed(target.key);
    if (source === null) continue;
    // Gaps are skipped, so a half-typed register carries as far as it got.
    const characters = source.indices.filter((i) => i < values.length).flatMap((i) => splitRunes(values[i] ?? ''));
    let next = 0;
    for (const index of target.indices) {
      const length = to.slots[index].length;
      result[index] = sanitize(to, index, characters.slice(next, next + length).join(''));
      next += length;
    }
  }
  return result;
}
