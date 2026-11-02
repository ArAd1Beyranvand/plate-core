import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { expect, test } from 'vitest';
import {
  PlateAnimationController,
  PlateAnimationStyle,
  type PlatePartKind,
  type PlatePartPhase,
  allOf,
  cubics,
  curveTransform,
  partId,
  partIdLabel,
  plateCueLength,
  plateDividerCount,
  plateRegionCount,
  samePart,
  staggerSequence,
  transitionKeeps,
  plateMotion,
} from '../../src/core/timing/plate_animation';
import { frameHidden, frameShown, frameSpan, partChain, partProgress, plateRevealRect } from '../../src/core/timing/plate_part_animator';
import { rectFromLTWH } from '../../src/core/values/plate_box';
import { specOf } from './specs';

const cases: any[] = JSON.parse(readFileSync(resolve(import.meta.dirname, '../../../vectors/core/timing.json'), 'utf8')).cases;
const by = (prefix: string) => cases.filter((c) => c.name.startsWith(prefix));
const countries = cases.filter((c) => c.input.package);
const ltwh = (r: { left: number; top: number; right: number; bottom: number }) => [r.left, r.top, r.right - r.left, r.bottom - r.top];
const motionJson = (m: ReturnType<typeof plateMotion>) => ({
  effect: m.effect, durationMs: m.durationMs, curve: m.curve, delayMs: m.delayMs, origin: [m.origin.x, m.origin.y],
  startPoint: m.startPoint, clockwise: m.clockwise, softEdge: m.softEdge,
});

test('curves', () => {
  for (const c of by('curve ')) {
    expect(cubics[c.input.curve] ?? null, c.name).toEqual(c.expect.cubic);
    c.input.t.forEach((t: number, i: number) => expect(curveTransform(c.input.curve, t), c.name).toBeCloseTo(c.expect.value[i], 12));
  }
});

test('motions and style table', () => {
  expect(motionJson(plateMotion())).toEqual(by('motion')[0].expect);
  const style = new PlateAnimationStyle();
  for (const c of by('style ')) expect(motionJson(style.motionFor(partId(c.input.kind as PlatePartKind, 3))), c.name).toEqual(c.expect);
});

test('delayed progress', () => {
  const style = new PlateAnimationStyle();
  for (const c of by('progress ')) {
    const m = style.motionFor(partId(c.input.kind));
    expect(m.delayMs + c.input.cueDelayMs + m.durationMs, c.name).toBe(c.expect.totalMs);
    c.input.atMs.forEach((ms: number, i: number) => expect(partProgress(m, c.input.cueDelayMs, ms), c.name).toBeCloseTo(c.expect.progress[i], 12));
  }
});

test('part ids, staggers, cue lengths', () => {
  const style = new PlateAnimationStyle();
  for (const c of countries.filter((c) => c.input.spec)) {
    const { spec } = specOf(c.input.package, c.input.spec);
    const ids = allOf(spec);
    expect(ids.map(partIdLabel), c.name).toEqual(c.expect.allOf);
    expect(plateRegionCount(spec.background), c.name).toBe(c.expect.regionCount);
    expect(plateDividerCount(spec.background), c.name).toBe(c.expect.dividerCount);
    const fwd = staggerSequence(spec);
    const back = staggerSequence(spec, { stepMs: 25, reverse: true });
    expect(ids.map((i) => fwd.get(i)), c.name).toEqual(c.expect.stagger60);
    expect(ids.map((i) => back.get(i)), c.name).toEqual(c.expect.stagger25Reverse);
    expect(plateCueLength(style, ids, new Map()), c.name).toBe(c.expect.cueLength);
    expect(plateCueLength(style, ids, fwd), c.name).toBe(c.expect.cueLength60);
    expect(plateCueLength(style, ids, back), c.name).toBe(c.expect.cueLength25Reverse);
  }
});

test('reveal rects and frames', () => {
  for (const c of by('reveal ')) {
    const [l, t, w, h] = c.input.bounds;
    const frame = { phase: c.input.phase as PlatePartPhase, progress: c.input.progress, motion: plateMotion() };
    expect(frameShown(frame), c.name).toBe(c.expect.shown);
    expect(frameHidden(frame), c.name).toBe(c.expect.hidden);
    expect(frameSpan(frame), c.name).toEqual(c.expect.span);
    const [ol, ot, ow, oh] = ltwh(plateRevealRect(rectFromLTWH(l, t, w, h), { x: c.input.origin[0], y: c.input.origin[1] }, frame));
    [ol, ot, ow, oh].forEach((v, i) => expect(v, c.name).toBeCloseTo(c.expect.rect[i], 9));
  }
});

test('chain table', () => {
  const frame = (effect: any, phase: PlatePartPhase, progress: number) => ({ phase, progress, motion: plateMotion({ effect, origin: { x: 0, y: 1 } }) });
  expect(partChain(frame('fade', 'settled', 1))).toMatchObject({ opacity: 1, clip: false, scale: 1 });
  expect(partChain(frame('fade', 'goingOut', 0.25)).opacity).toBe(0.75);
  expect(partChain(frame('wipe', 'comingIn', 0))).toMatchObject({ opacity: 0, clip: true });
  expect(partChain(frame('draw', 'comingIn', 0.1))).toMatchObject({ opacity: 1, clip: true });
  expect(partChain(frame('fadeScale', 'comingIn', 0)).scale).toBe(0.4);
  expect(partChain(frame('fadeSlide', 'comingIn', 0)).slide).toEqual({ x: 0, y: 0.6 });
});

test('spec changes keep parts', () => {
  const identical = { keepIdentical: true };
  const kinds = { keepKinds: new Set<PlatePartKind>(['panel', 'slot', 'band']) };
  for (const c of countries.filter((c) => c.input.from)) {
    const from = specOf(c.input.package, c.input.from).spec;
    const to = specOf(c.input.package, c.input.to).spec;
    const ids = [...new Set([...allOf(from), ...allOf(to)])];
    const values = { fromValues: from.slots.map(() => null), toValues: to.slots.map(() => null) };
    const label = (f: (id: string) => boolean) => ids.filter(f).map(partIdLabel);
    expect(label((id) => samePart(id, from, to, values)), c.name).toEqual(c.expect.samePart);
    expect(label((id) => transitionKeeps(identical, id, from, to, values)), c.name).toEqual(c.expect.keepIdentical);
    expect(label((id) => transitionKeeps(kinds, id, from, to)), c.name).toEqual(c.expect.keepPanelSlotBand);
  }
});

test('keep callback wins', () => {
  const s = specOf('albania_plate', 'al.private').spec;
  expect(transitionKeeps({ keep: () => true }, partId('border'), s, s)).toBe(true);
  expect(transitionKeeps({ keep: () => undefined, keepIdentical: true }, partId('border'), s, s)).toBe(false);
});

test('controller cues', () => {
  const c = new PlateAnimationController();
  const seen: string[] = [];
  c.cueOf(partId('slot', 0)).subscribe(() => seen.push('slot0'));
  c.cueOf(partId('slot', 1)).subscribe(() => seen.push('slot1'));
  c.comeIn(partId('slot', 0), 30);
  expect(seen).toEqual(['slot0']);
  expect(c.phaseOf(partId('slot', 0))).toBe('comingIn');
  expect(c.phaseOf(partId('slot', 5))).toBe('settled');
  c.goOutAll(new Map([[partId('slot', 1), 10]]));
  expect(c.cueOf(partId('slot', 1)).value).toMatchObject({ phase: 'goingOut', delayMs: 10 });
  expect(c.cueOf(partId('slot', 9)).value.phase).toBe('goingOut');
  c.hide(partId('slot', 0));
  expect(c.cueOf(partId('slot', 0)).value.instant).toBe(true);
});
