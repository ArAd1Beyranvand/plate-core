import {
  type PlateAnimationStyle,
  type PlatePartId,
  type PlateSpecTransition,
  allOf,
  partId,
  plateCueLength,
  staggerSequence,
  transitionKeeps,
} from '../core/timing/plate_animation';
import type { PlateSpec } from '../core/values/plate_spec';

/** [D1][D9] What a spec change plays: the ghost takes the old plate apart, the new one comes in after it. */
export interface SpecTransitionPlan {
  /** The outgoing parts' goingOut delays; kept and morphed parts are absent. */
  readonly outDelays: ReadonlyMap<PlatePartId, number>;
  /** The incoming parts' comingIn delays, each after the out stagger. */
  readonly inDelays: ReadonlyMap<PlatePartId, number>;
  /** Parts of the old plate the ghost shows settled until it goes. */
  readonly kept: ReadonlySet<PlatePartId>;
  /** Parts of the new plate hidden while the ghost shows their old twin. */
  readonly hidden: ReadonlySet<PlatePartId>;
  /** The face and border: the new plate's settle at once, its colour tweening, and the ghost leaves them out. */
  readonly morphed: ReadonlySet<PlatePartId>;
  /** How long the ghost runs, and so how long the canvas takes to resize. */
  readonly outLengthMs: number;
}

const faceParts = [partId('background'), partId('corner'), partId('borderWidth'), partId('borderColor'), partId('border')];

export function planSpecTransition(
  t: PlateSpecTransition,
  style: PlateAnimationStyle,
  from: PlateSpec,
  to: PlateSpec,
  fromValues: readonly (string | null)[],
  toValues: readonly (string | null)[],
): SpecTransitionPlan {
  const keeps = (id: PlatePartId) => transitionKeeps(t, id, from, to, { fromValues, toValues });
  const morphed = new Set(t.morphBackground ? faceParts : []);
  const outDelays = staggerSequence(from, { stepMs: t.stepMs, reverse: true });
  for (const id of [...outDelays.keys()]) if (keeps(id) || morphed.has(id)) outDelays.delete(id);
  const outLengthMs = plateCueLength(style, outDelays.keys(), outDelays);
  const inDelays = new Map([...staggerSequence(to, { stepMs: t.stepMs })].map(([id, d]) => [id, d + outLengthMs]));
  return {
    outDelays,
    inDelays,
    kept: new Set(allOf(from).filter(keeps)),
    hidden: new Set(allOf(to).filter(keeps)),
    morphed,
    outLengthMs,
  };
}
