import type { PlateAlphabet } from '../alphabet/plate_alphabet';
import type { PlateBox, Rect } from '../values/plate_box';
import type { PlateSection, PlateSpec } from '../values/plate_spec';

/** Dart's double formatting: whole numbers keep a trailing ".0". */
const d = (n: number | undefined): string => (n === undefined ? 'null' : Number.isInteger(n) ? n.toFixed(1) : String(n));

const contentKey = (a: PlateAlphabet): string => a.characters.map((c) => `${c}=${a.render(c)}`).join(' ');

/** Everything wrong with `spec`, empty for a sound one. */
export function specProblems(spec: PlateSpec): string[] {
  const problems: string[] = [];
  const check = (ok: boolean, problem: string): void => {
    if (!ok) problems.push(problem);
  };
  const inCanvas = (b: PlateBox, what: string): void =>
    check(
      b.left >= 0 && b.top >= 0 && b.right <= spec.canvasWidth && b.bottom <= spec.canvasHeight,
      `${what} in spec "${spec.id}" has a rect outside the canvas (${d(spec.canvasWidth)}x${d(spec.canvasHeight)}).`,
    );

  spec.slots.forEach((s, i) => inCanvas(s.box, `PlateSlot ${i}`));
  spec.mirrors.forEach((m, i) => {
    inCanvas(m.box, `PlateMirror ${i}`);
    check(
      m.source >= 0 && m.source < spec.slots.length,
      `PlateMirror ${i} in spec "${spec.id}" echoes slot ${m.source}, which is not a slot index (0..${spec.slots.length - 1}).`,
    );
  });
  spec.bands.forEach((b, i) => inCanvas(b.box, `PlateBand ${i}`));

  const checkSection = (s: PlateSection, r: Rect, path: string): void => {
    if (s.kind === 'leaf') {
      if (s.fill.kind !== 'stripes') return;
      const { stripes, stops } = s.fill;
      check(
        stripes.length === stops.length + 1 && stripes.every((f) => f.kind !== 'stripes'),
        `Background leaf ${path} in spec "${spec.id}" has ${stripes.length} stripes and ${stops.length} stops; give one stop between each pair, and do not nest stripes.`,
      );
      for (let i = 1; i < stops.length; i++) {
        check(stops[i] > stops[i - 1], `Background leaf ${path} in spec "${spec.id}" has stops out of order: ${d(stops[i])} after ${d(stops[i - 1])}.`);
      }
      return;
    }
    const across = s.axis === 'horizontal';
    let previous = across ? r.left : r.top;
    const end = across ? r.right : r.bottom;
    s.parts.forEach((part, i) => {
      const last = i === s.parts.length - 1;
      check(
        last ? part.end === undefined : part.end !== undefined && part.end > previous && part.end < end,
        `Background part ${path}.${i} in spec "${spec.id}" ends at ${d(part.end)}; ${
          last ? "the last part runs to its parent's end, so leave it null" : `expected a value in (${d(previous)}, ${d(end)})`
        }.`,
      );
      const partEnd = part.end ?? end;
      checkSection(
        part.section,
        across ? { left: previous, top: r.top, right: partEnd, bottom: r.bottom } : { left: r.left, top: previous, right: r.right, bottom: partEnd },
        `${path}.${i}`,
      );
      previous = partEnd;
    });
  };
  checkSection(spec.background, { left: 0, top: 0, right: spec.canvasWidth, bottom: spec.canvasHeight }, 'background');

  // Only keyed groups of three or more cells on one row have a pitch.
  for (const g of spec.effectiveTextGroups) {
    if (g.key === undefined || g.indices.length < 3) continue;
    const boxes = g.indices.filter((i) => spec.slotAt(i) !== null).map((i) => spec.slots[i].box);
    if (boxes.length !== g.indices.length) continue;
    if (!boxes.every((b) => b.top === boxes[0].top && b.height === boxes[0].height)) continue;
    const pitch = boxes[1].left - boxes[0].left;
    for (let n = 1; n < boxes.length; n++) {
      check(
        Math.abs(boxes[n].left - boxes[0].left - n * pitch) < 0.01,
        `Register "${g.key}" in spec "${spec.id}" is unevenly pitched: cell ${n} sits at ${d(boxes[n].left)}, but a pitch of ${d(pitch)} puts it at ${d(boxes[0].left + n * pitch)}. Build it with plateRegister/plateRegisterAcross rather than cell by cell.`,
      );
    }
  }

  for (const r of spec.restrictions) {
    check(
      spec.textGroups.some((g) => g.key === r.group),
      `Restriction "${(r as { reason?: string }).reason}" in spec "${spec.id}" watches group "${r.group}", which no text group carries — it would never fire.`,
    );
  }

  // An alphabet id must map one-to-one onto rendered content.
  const byId = new Map<string, string>();
  const byContent = new Map<string, string>();
  const alphabets = [...spec.slots.map((s) => s.alphabet), ...spec.mirrors.flatMap((m) => (m.alphabet ? [m.alphabet] : []))];
  for (const a of alphabets) {
    const key = contentKey(a);
    const seenContent = byId.get(a.id);
    check(seenContent === undefined || seenContent === key, `Alphabet id "${a.id}" in spec "${spec.id}" appears with two different character/glyph sets.`);
    byId.set(a.id, key);
    const seenId = byContent.get(key);
    check(
      seenId === undefined || seenId === a.id,
      `Spec "${spec.id}" has two distinct alphabet ids ("${seenId}", "${a.id}") sharing the same characters and glyphs.`,
    );
    byContent.set(key, a.id);
  }
  return problems;
}
