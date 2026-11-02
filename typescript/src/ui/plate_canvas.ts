import { PlateController } from '../core/input/plate_controller';
import type { PlateInputSource } from '../core/input/plate_input_source';
import { type PlateMode, type SlotBehavior, resolveSlotBehavior } from '../core/input/slot_behavior';
import type { PlateTheme } from '../core/theme/plate_theme';
import type { Rect } from '../core/values/plate_box';
import type { PlateCountry } from '../core/values/plate_country';
import type { PlateSpec } from '../core/values/plate_spec';
import type { DisplayOp } from '../render/display_list';
import { lerpTheme, plateTheme, renderPlate } from '../render/plate_canvas';
import type { Frames } from '../render/plate_frame';
import { StaggeredText } from '../render/plate_text_row';
import { PartClock } from './part_clock';
import { opsToSvg } from './svg';
import { type PlateAnimationController, curveTransform } from '../core/timing/plate_animation';

type Values = readonly (string | null)[];

export interface PlateCanvasOptions {
  readonly spec: PlateSpec;
  /** A host controller is adopted and never disposed here. */
  readonly controller?: PlateController;
  readonly values?: Values;
  readonly theme?: PlateTheme;
  readonly country?: PlateCountry;
  readonly mode?: PlateMode;
  readonly inputSource?: PlateInputSource;
  /** Called after each change, once per microtask, with the new display list. */
  readonly onRender?: (ops: readonly DisplayOp[]) => void;
  /** Drives part frames; the canvas re-renders while any part moves. */
  readonly animation?: PlateAnimationController;
  /** Input mode: the focused slot. */
  readonly activeIndex?: number | null;
}

const liveryKeys = ['plateBackground', 'plateBorder', 'ink', 'dividerColor', 'activeColor', 'inactiveColor'] as const;
const sameLivery = (a: PlateTheme, b: PlateTheme) => liveryKeys.every((k) => a[k] === b[k]);

/** [H15] A livery change cross-fades over this long when the spec resolves its theme from the values. */
const liveryMs = 350;

/** Where the UI places a native input over the painted plate [D2]. */
export interface SlotInput {
  readonly index: number;
  readonly behavior: SlotBehavior;
  /** In spec units; the host scales by its own width / canvasWidth. */
  readonly box: Rect;
}

/**
 * [D1][D7] The headless half of `<plate-canvas>`: core state in, display list out.
 * Painting is opsToSvg; native inputs go at slotInputs().
 */
export class PlateCanvas {
  readonly controller: PlateController;
  private readonly owns: boolean;
  private readonly unsubscribe: () => void;
  private pending = false;
  frames?: Frames;
  private readonly clock?: PartClock;
  private tween?: { from: PlateTheme; to: PlateTheme; at: number; ms: number };
  private morph?: { from: PlateTheme; ms: number };
  private readonly labels = new Map<number, StaggeredText>();

  constructor(private o: PlateCanvasOptions) {
    this.owns = !o.controller;
    this.controller = o.controller ?? new PlateController({ spec: o.spec, values: o.values });
    const changed = () => this.schedule();
    const subs = [this.controller.subscribe(changed), this.controller.rejection.subscribe(changed), this.controller.hints.subscribe(changed)];
    if (o.animation) {
      this.clock = new PartClock(o.animation);
      subs.push(o.animation.subscribe(changed));
    }
    this.unsubscribe = () => subs.forEach((u) => u());
  }

  get options(): PlateCanvasOptions {
    return this.o;
  }

  /** The face starts as [from] and fades to its own colours over [ms]; call before the first render. */
  morphFrom(from: PlateTheme, ms: number): void {
    this.morph = { from, ms };
  }

  /** [H15] The resolved theme now: a change of livery fades from where the last one had got to. */
  private theme(): PlateTheme {
    const c = this.controller, target = plateTheme(c.spec, this.o.theme, c.values), now = performance.now();
    let tw = this.tween;
    if (!tw) tw = this.tween = { from: this.morph?.from ?? target, to: target, at: now, ms: this.morph?.ms ?? 0 };
    else if (!sameLivery(tw.to, target)) tw = this.tween = { from: this.themeAt(now), to: target, at: now, ms: c.spec.resolveTheme ? liveryMs : 0 };
    return this.themeAt(now);
  }

  private themeAt(now: number): PlateTheme {
    const { from, to, at, ms } = this.tween!;
    return ms > 0 && now - at < ms ? lerpTheme(from, to, curveTransform('easeInOut', (now - at) / ms)) : to;
  }

  private get fading(): boolean {
    const tw = this.tween;
    return !!tw && performance.now() - tw.at < tw.ms;
  }

  get spec(): PlateSpec {
    return this.controller.spec;
  }

  setValues(values: Values): boolean {
    return this.controller.setValues(values);
  }

  get values(): Values {
    return this.controller.values;
  }

  /** Replaces theme, country, mode or source; the next render uses them. */
  update(o: Partial<Omit<PlateCanvasOptions, 'spec' | 'controller'>>): void {
    this.o = { ...this.o, ...o };
    this.schedule();
  }

  displayList(): DisplayOp[] {
    const c = this.controller;
    return renderPlate({
      spec: c.spec,
      values: c.values,
      theme: this.o.theme,
      resolvedTheme: this.theme(),
      labelText: (i, value) => {
        let t = this.labels.get(i);
        if (!t) this.labels.set(i, (t = new StaggeredText(value)));
        return t.frame(value, performance.now());
      },
      country: this.o.country,
      frames: this.frames ?? this.clock?.frames(),
      mode: this.o.mode ?? 'display',
      inputSource: this.o.inputSource,
      isCompleted: c.isCompleted,
      rejection: c.rejection.value,
      hintAt: (i) => c.hintAt(i),
      activeIndex: this.o.activeIndex,
    });
  }

  /** In input mode, the slots the display list leaves for native inputs. */
  slotInputs(): SlotInput[] {
    if ((this.o.mode ?? 'display') !== 'input') return [];
    const source = this.o.inputSource ?? 'system';
    return this.spec.slots
      .map((s, index) => ({ index, behavior: resolveSlotBehavior({ mode: 'input', input: s.alphabet.input, source }), box: s.box.rect }))
      .filter((s) => s.behavior !== 'glyph');
  }

  svg(resolveAsset?: (pkg: string, path: string) => string): string {
    const { canvasWidth: w, canvasHeight: h } = this.spec;
    return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${w} ${h}">${opsToSvg(this.displayList(), resolveAsset)}</svg>`;
  }

  /** [H14] One render per burst of changes, after the writes that caused it. */
  private schedule(): void {
    if (this.pending || !this.o.onRender) return;
    this.pending = true;
    queueMicrotask(() => {
      this.pending = false;
      this.o.onRender?.(this.displayList());
      if (this.clock?.running || this.fading || [...this.labels.values()].some((l) => l.running)) (globalThis.requestAnimationFrame ?? setTimeout)(() => this.schedule());
    });
  }

  /** [D7] Disposes only a controller this canvas made. */
  dispose(): void {
    this.unsubscribe();
    if (this.owns) this.controller.dispose();
  }
}

/** `<plate-canvas>`: set `.options`; renders an SVG and fires `plate-render` after each change. */
export function definePlateCanvasElement(name = 'plate-canvas'): void {
  if (typeof HTMLElement === 'undefined' || customElements.get(name)) return;
  customElements.define(
    name,
    class extends HTMLElement {
      private canvas?: PlateCanvas;

      set options(o: PlateCanvasOptions) {
        this.canvas?.dispose();
        this.canvas = new PlateCanvas({ ...o, onRender: (ops) => this.paint(ops) });
        this.paint(this.canvas.displayList());
      }

      get plate(): PlateCanvas | undefined {
        return this.canvas;
      }

      private paint(ops: readonly DisplayOp[]): void {
        const c = this.canvas!;
        this.innerHTML = c.svg();
        this.dispatchEvent(new CustomEvent('plate-render', { detail: { ops, slots: c.slotInputs() } }));
      }

      disconnectedCallback(): void {
        this.canvas?.dispose();
        this.canvas = undefined;
      }
    },
  );
}
