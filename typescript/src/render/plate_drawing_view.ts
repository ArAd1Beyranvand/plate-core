import type { PlateDrawing } from '../core/values/plate_asset';
import type { PlateShape, Point } from '../core/values/plate_shape';
import type { DisplayList } from './display_list';

/** How a drawing meets its box: fill stretches it (a flag), contain keeps its proportions, centred (a decal). */
export type DrawingFit = 'fill' | 'contain';

const n = (v: number) => String(Math.round(v * 1e4) / 1e4);
const contour = (pts: readonly Point[]) => pts.map(([x, y], i) => `${i === 0 ? 'M' : 'L'}${n(x)} ${n(y)}`).join(' ') + ' Z';

/** [H13] A circle as a closed polyline from `from` radians (clockwise on screen) over `sweep`, every 0.25 units. */
function arc(cx: number, cy: number, r: number, from = 0, sweep = 2 * Math.PI): Point[] {
  const steps = Math.min(4000, Math.max(16, Math.ceil((r * Math.abs(sweep)) / 0.25)));
  const full = Math.abs(sweep) >= 2 * Math.PI;
  const pts: Point[] = [];
  for (let i = 0; i < (full ? steps : steps + 1); i++) {
    const a = from + (sweep * i) / steps;
    pts.push([cx + r * Math.cos(a), cy + r * Math.sin(a)]);
  }
  return pts;
}

function starPoints(cx: number, cy: number, radius: number, points: number, innerRatio: number, rotation: number): Point[] {
  const turn = (rotation * Math.PI) / 180;
  return Array.from({ length: points * 2 }, (_, i): Point => {
    const r = i % 2 === 0 ? radius : radius * innerRatio;
    const a = turn + (Math.PI * i) / points;
    return [cx + r * Math.sin(a), cy - r * Math.cos(a)];
  });
}

/** [H13] Disc minus bite (Path.combine difference, evenodd like Dart's result) as one outline: the disc's arc outside the bite, the bite's inside the disc. */
function crescent(cx: number, cy: number, r: number, dx: number, br: number): string {
  const d = Math.abs(dx);
  if (d >= r + br) return contour(arc(cx, cy, r));
  if (br >= d + r) return '';
  if (r >= d + br) return `${contour(arc(cx, cy, r))} ${contour(arc(cx + dx, cy, br))}`;
  // Where the circles cross, as angles about each centre along +dx.
  const dir = dx >= 0 ? 0 : Math.PI;
  const a = Math.acos((d * d + r * r - br * br) / (2 * d * r));
  const b = Math.acos((d * d + br * br - r * r) / (2 * d * br));
  return contour([...arc(cx, cy, r, dir + a, 2 * Math.PI - 2 * a), ...arc(cx + dx, cy, br, dir + Math.PI + b, -2 * b).slice(1, -1)]);
}

/** [D1][H13] The shape as `<fillRule>:<SVG d>` in drawing units. */
export function shapePath(s: PlateShape): string {
  switch (s.kind) {
    case 'rect':
      return `nonzero:${contour([[s.left, s.top], [s.left + s.width, s.top], [s.left + s.width, s.top + s.height], [s.left, s.top + s.height]])}`;
    case 'polygon':
      return `nonzero:${contour(s.points)}`;
    case 'circle':
      return `nonzero:${contour(arc(s.cx, s.cy, s.radius))}`;
    case 'ring':
      return `evenodd:${contour(arc(s.cx, s.cy, s.radius + s.width / 2))} ${contour(arc(s.cx, s.cy, Math.max(0, s.radius - s.width / 2)))}`;
    case 'crescent':
      return `evenodd:${crescent(s.cx, s.cy, s.radius, s.biteDx, s.biteRadius)}`;
    case 'star':
      return `nonzero:${contour(starPoints(s.cx, s.cy, s.radius, s.points, s.innerRatio, s.rotation))}`;
    case 'starRing':
      return `nonzero:${Array.from({ length: s.count }, (_, i) => {
        const a = (2 * Math.PI * i) / s.count;
        return contour(starPoints(s.cx + s.ringRadius * Math.sin(a), s.cy - s.ringRadius * Math.cos(a), s.starRadius, s.points, s.innerRatio, 0));
      }).join(' ')}`;
  }
}

/** [D6][H13] PlateDrawingView: paints [drawing] into a box of [width] x [height] at the current origin. */
export function paintDrawing(c: DisplayList, drawing: PlateDrawing, width: number, height: number, fit: DrawingFit = 'fill'): void {
  const sx = width / drawing.width;
  const sy = height / drawing.height;
  const scaleX = fit === 'contain' ? Math.min(sx, sy) : sx;
  const scaleY = fit === 'contain' ? scaleX : sy;
  c.save();
  c.translate((width - drawing.width * scaleX) / 2, (height - drawing.height * scaleY) / 2);
  c.scale(scaleX, scaleY);
  for (const shape of drawing.shapes) c.path(shapePath(shape), { color: shape.color });
  c.restore();
}
