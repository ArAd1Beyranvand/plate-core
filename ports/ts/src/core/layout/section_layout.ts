import type { PlateSection } from '../values/plate_spec';
import { type Rect } from '../values/plate_box';

export interface SectionLayout {
  readonly leaves: [PlateSection, Rect][];
  readonly dividers: Rect[];
}

/** The leaves and dividers of [root] laid over [bounds], depth-first. */
export function layoutSection(root: PlateSection, bounds: Rect): SectionLayout {
  const leaves: [PlateSection, Rect][] = [];
  const dividers: Rect[] = [];
  const walk = (s: PlateSection, r: Rect): void => {
    if (s.kind === 'leaf') {
      leaves.push([s, r]);
      return;
    }
    const across = s.axis === 'horizontal';
    let start = across ? r.left : r.top;
    const last = s.parts.length - 1;
    s.parts.forEach((part, i) => {
      const end = i === last ? (across ? r.right : r.bottom) : part.end!;
      walk(
        part.section,
        across ? { left: start, top: r.top, right: end, bottom: r.bottom } : { left: r.left, top: start, right: r.right, bottom: end },
      );
      if ((part.divider ?? 0) > 0 && i !== last) {
        const half = part.divider! / 2;
        dividers.push(
          across
            ? { left: end - half, top: r.top, right: end + half, bottom: r.bottom }
            : { left: r.left, top: end - half, right: r.right, bottom: end + half },
        );
      }
      start = end;
    });
  };
  walk(root, bounds);
  return { leaves, dividers };
}
