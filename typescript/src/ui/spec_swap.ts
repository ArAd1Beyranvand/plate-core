import { PlateController } from '../core/input/plate_controller';
import {
  PlateAnimationController, type PlateSpecTransition, partId, staggerSequence,
} from '../core/timing/plate_animation';
import { plateTheme } from '../render/plate_canvas';
import { planSpecTransition } from '../render/spec_transition';
import { PlateCanvas } from './plate_canvas';

/** What the app plays when a plate's spec changes. */
export const specTransition: PlateSpecTransition = { keepIdentical: true, morphBackground: true };

/** The outgoing plate: what it showed, kept after its canvas is gone. */
export interface Outgoing {
  readonly canvas: PlateCanvas;
  readonly values: readonly (string | null)[];
  readonly hints: readonly (string | null)[] | null;
}

export const outgoing = (canvas: PlateCanvas): Outgoing => ({ canvas, values: [...canvas.values], hints: canvas.controller.hints.value });

/** A plate coming in with nothing before it: every part staggers in. */
export function introduce(next: PlateCanvas, anim: PlateAnimationController): void {
  anim.comeInAll(staggerSequence(next.spec, { stepMs: specTransition.stepMs }));
}

/**
 * [D1][D9] A spec change as the canvas plays it: [from] takes itself apart in a ghost over [host]
 * while [next] waits to come in after it, the face fading between their colours and the box
 * growing to the next plate's height. Returns what ends it early.
 */
export function swapSpec(host: HTMLElement, from: Outgoing, next: PlateCanvas, anim: PlateAnimationController): () => void {
  const old = from.canvas.options;
  const plan = planSpecTransition(specTransition, anim.style, from.canvas.spec, next.spec, from.values, next.values);
  const ms = plan.outLengthMs;
  anim.comeInAll(new Map([...plan.inDelays]));
  plan.hidden.forEach((id) => anim.hide(id));
  plan.morphed.forEach((id) => anim.settle(id));
  next.morphFrom(plateTheme(from.canvas.spec, old.theme, from.values), ms);

  const ghostAnim = new PlateAnimationController(anim.style);
  ghostAnim.goOutAll(plan.outDelays);
  plan.kept.forEach((id) => ghostAnim.settle(id));
  // The corner and width draw nothing; they only shape the clip the leaving parts are held in.
  plan.morphed.forEach((id) => (id === partId('corner') || id === partId('borderWidth') ? ghostAnim.settle(id) : ghostAnim.hide(id)));
  const el = Object.assign(document.createElement('div'), { ariaHidden: 'true' });
  el.style.cssText = 'position:absolute;left:0;top:0;width:100%;pointer-events:none';
  const controller = new PlateController({ spec: from.canvas.spec, values: from.values });
  controller.hints.value = from.hints;
  const ghost = new PlateCanvas({
    spec: from.canvas.spec, controller, theme: old.theme, country: old.country, mode: old.mode, inputSource: old.inputSource,
    animation: ghostAnim, onRender: () => paintGhost(),
  });
  const paintGhost = () => {
    el.innerHTML = ghost.svg();
    (el.firstElementChild as SVGElement).style.cssText = 'width:100%;height:auto;display:block';
  };
  host.append(el);
  paintGhost();
  ghost.update({});

  const from0 = host.offsetHeight;
  if (ms > 0) {
    host.style.height = `${from0}px`;
    void host.offsetHeight; // flush, so the next height transitions from this one
    requestAnimationFrame(() => {
      host.style.transition = `height ${ms}ms ease-in-out`;
      host.style.height = `${(host.firstElementChild as HTMLElement).offsetHeight}px`;
    });
  }
  const end = () => {
    clearTimeout(timer);
    ghost.dispose();
    controller.dispose();
    ghostAnim.dispose();
    el.remove();
    host.style.transition = host.style.height = '';
  };
  const timer = setTimeout(() => {
    end();
    plan.kept.forEach((id) => anim.settle(id));
  }, ms);
  return () => {
    end();
    anim.settleAll();
  };
}
