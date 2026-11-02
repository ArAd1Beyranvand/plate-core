import type { ReadonlyStore, Unsubscribe } from '../core/input/store';
import {
  ColorTween, cssColor, faceTargets, isHighlight, keyGap, keyHeight, turnDelayMs,
} from './keypad_motion';
import { type KeyCell, KeypadModel, type PlateKeypadOptions } from './keypad_model';

export type { PlateKeypadOptions } from './keypad_model';

export interface PlateKeypadHooks {
  /** Fires with the reported key when an enabled key is tapped. */
  readonly onKey?: (key: string) => void;
  /** [D7] The key to flash; each key subscribes on its own so a flash repaints one key. */
  readonly highlighted?: ReadonlyStore<string | null>;
  readonly now?: () => number;
  readonly frame?: (cb: () => void) => unknown;
}

const wheelchair =
  '<svg viewBox="0 0 24 24" width="22" height="22" fill="currentColor"><circle cx="12" cy="4" r="2"/><path d="M19 13v-2c-1.5 0-3.3-.9-4.1-2l-1-1.6a2 2 0 0 0-1.7-.9c-.3 0-.5.1-.8.2L6 8.3V13h2V9.6l1.8-.7L8.2 17a2 2 0 0 0 2 2h5.4l3.2 3 1.4-1.4-4-3.6h-4.1l.5-2.7c1 1 2.7 1.7 4.5 1.7v-2Z"/></svg>';

class Key {
  readonly el = document.createElement('button');
  private readonly fill: ColorTween;
  private readonly border: ColorTween;
  private readonly ink: ColorTween;
  private shown: boolean;
  private highlighted = false;
  private turn?: ReturnType<typeof setTimeout>;
  private off?: Unsubscribe;

  constructor(private readonly pad: PlateKeypad, private cell: KeyCell, private readonly count: number, now: number) {
    const el = this.el;
    el.type = 'button';
    el.setAttribute('aria-label', cell.text);
    el.style.cssText = 'border-radius:8px;font:500 18px system-ui;padding:0 3px;cursor:pointer;background:none;white-space:nowrap;overflow:hidden';
    if (cell.text.includes('♿')) el.innerHTML = wheelchair;
    else el.textContent = cell.text;
    el.addEventListener('pointerdown', (e) => e.preventDefault());
    el.addEventListener('click', () => this.cell.enabled && pad.hooks.onKey?.(this.cell.key));
    this.shown = cell.enabled;
    const t = faceTargets(pad.model.theme, false, this.shown);
    this.fill = new ColorTween(t.fill);
    this.border = new ColorTween(t.border);
    this.ink = new ColorTween(t.ink);
    this.off = pad.hooks.highlighted?.subscribe(() => this.retarget(pad.now()));
    this.highlighted = this.lit();
    this.retarget(now, 0);
  }

  private lit(): boolean {
    const held = this.pad.hooks.highlighted?.value ?? null;
    return isHighlight(held, this.cell.key, this.pad.model.digitsOf(this.pad.letters));
  }

  /** [H14] The grey-out trails the real enabled state by a per-key stagger. */
  setCell(cell: KeyCell): void {
    this.cell = cell;
    if (cell.enabled === this.shown) {
      clearTimeout(this.turn);
      this.turn = undefined;
    } else if (!this.turn) {
      this.turn = setTimeout(() => {
        this.turn = undefined;
        this.shown = this.cell.enabled;
        this.retarget(this.pad.now());
      }, turnDelayMs(cell.enabled, cell.index, this.count));
    }
  }

  private retarget(now: number, ms?: number): void {
    this.highlighted = this.lit();
    const t = faceTargets(this.pad.model.theme, this.highlighted, this.shown);
    this.fill.set(t.fill, now, ms ?? t.ms);
    this.border.set(t.border, now, ms ?? t.ms);
    this.ink.set(t.ink, now, ms ?? t.ms);
    this.pad.wake();
  }

  paint(now: number, presence: number): boolean {
    const s = this.el.style;
    const fill = this.fill.value(now);
    s.background = cssColor(fill);
    s.borderColor = cssColor(this.border.value(now));
    s.color = cssColor(this.ink.value(now));
    s.borderStyle = 'solid';
    s.borderWidth = '1px';
    const press = 1 - 0.06 * (((fill >>> 24) & 255) / 255);
    s.transform = `scale(${(press * (0.6 + 0.4 * presence)).toFixed(4)})`;
    s.opacity = String(presence);
    s.pointerEvents = presence < 1 ? 'none' : '';
    return this.fill.running(now) || this.border.running(now) || this.ink.running(now);
  }

  dispose(): void {
    clearTimeout(this.turn);
    this.off?.();
  }
}

/** [D8] A soft keyboard of DOM buttons; pointerdown is cancelled so the slot input keeps focus. */
export class PlateKeypad {
  readonly el = document.createElement('div');
  readonly model: KeypadModel;
  letters: boolean;
  private readonly grid = document.createElement('div');
  private keys: Key[] = [];
  private raf = false;
  private gridId = '';
  private disposed = false;

  constructor(options: PlateKeypadOptions, readonly hooks: PlateKeypadHooks = {}) {
    this.model = new KeypadModel(options);
    this.letters = !!options.showLetters;
    this.el.style.cssText = 'padding:8px;border-radius:12px;box-sizing:border-box;overflow:hidden';
    this.el.addEventListener('pointerdown', (e) => e.preventDefault());
    this.el.append(this.grid);
    this.sync(this.now());
    this.paint(this.now());
  }

  now(): number {
    return this.hooks.now?.() ?? performance.now();
  }

  update(options: PlateKeypadOptions): void {
    const now = this.now();
    this.model.update(options, now);
    this.sync(now);
    this.wake();
  }

  dispose(): void {
    this.keys.forEach((k) => k.dispose());
    this.keys = [];
    this.gridId = '';
    this.disposed = true;
  }

  /** Rebuilds the grid when the one on screen changes; otherwise only refreshes key states. */
  private sync(now: number): void {
    const letters = this.model.showingLetters(now);
    const grid = this.model.grid(letters);
    const id = `${letters}:${grid.id}`;
    const cells = this.model.cells(letters);
    if (id !== this.gridId) {
      this.keys.forEach((k) => k.dispose());
      this.gridId = id;
      this.letters = letters;
      const h = keyHeight(this.model.compact);
      const g = this.grid.style;
      g.display = 'grid';
      g.gap = `${keyGap}px`;
      g.gridTemplateColumns = `repeat(${grid.columns}, 1fr)`;
      g.gridAutoRows = `${h}px`;
      this.grid.dir = letters ? this.model.letterAlphabet.direction : 'ltr';
      this.keys = cells.map((c) => new Key(this, c, cells.length, now));
      this.grid.replaceChildren(...cells.map((c, i) => (c.label === '' ? document.createElement('span') : this.keys[i].el)));
    } else cells.forEach((c, i) => this.keys[i].setCell(c));
  }

  /** Starts the frame loop if it is not running. */
  wake(): void {
    if (this.raf) return;
    this.raf = true;
    (this.hooks.frame ?? ((cb) => requestAnimationFrame(cb)))(() => {
      this.raf = false;
      this.tick();
    });
  }

  tick(): void {
    if (this.disposed) return;
    const now = this.now();
    this.sync(now);
    if (this.paint(now)) this.wake();
  }

  private paint(now: number): boolean {
    this.el.style.background = cssColor(this.model.theme.surface);
    const h = this.model.heightAt(now);
    this.grid.style.height = this.model.animating(now) ? `${h}px` : '';
    let running = this.model.animating(now);
    const count = this.keys.length;
    this.keys.forEach((k, i) => {
      if (k.paint(now, this.model.presence(now, i, count))) running = true;
    });
    return running;
  }
}
