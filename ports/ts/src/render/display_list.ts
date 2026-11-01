import type { Rect } from '../core/values/plate_box';
import type { Color } from '../core/values/plate_shape';

/** [D1] `[a, b, c, d, tx, ty]`: x' = a·x + c·y + tx, y' = b·x + d·y + ty. */
export type Matrix = readonly [number, number, number, number, number, number];
export const identity: Matrix = [1, 0, 0, 1, 0, 0];

/** `[left, top, width, height]`. */
export type Box = readonly [number, number, number, number];
/** A box then `tl.x, tl.y, tr.x, tr.y, br.x, br.y, bl.x, bl.y`. */
export type RRectList = readonly number[];

export interface Paint {
  readonly color: Color;
  readonly stroke?: number;
  readonly cap?: 'butt' | 'round' | 'square';
  readonly join?: 'miter' | 'round' | 'bevel';
  /** A radial fog: centre alpha, plateau stop, edge transparent (see the region painter). */
  readonly shader?: { readonly kind: 'fog'; readonly color: Color; readonly plateau: number };
}

export interface TextStyle {
  readonly fontSize: number;
  readonly height: number;
  readonly color: Color;
  readonly fontFamily: string;
  readonly fontWeight: number;
  readonly letterSpacing: number;
}

/** One display-list op, the shape of ports/vectors/render. `m` maps local geometry to plate units. */
export type DisplayOp = { readonly m?: Matrix } & (
  | { readonly op: 'save' | 'restore' }
  | { readonly op: 'layer'; readonly bounds: Box | null; readonly paint: Paint }
  | { readonly op: 'clipRect'; readonly rect: Box; readonly difference?: boolean }
  | { readonly op: 'clipRRect'; readonly rrect: RRectList }
  | { readonly op: 'clipPath'; readonly path: string }
  | { readonly op: 'rect'; readonly rect: Box; readonly paint: Paint }
  | { readonly op: 'rrect'; readonly rrect: RRectList; readonly paint: Paint }
  | { readonly op: 'drrect'; readonly outer: RRectList; readonly inner: RRectList; readonly paint: Paint }
  | { readonly op: 'path'; readonly path: string; readonly paint: Paint }
  | { readonly op: 'circle'; readonly center: readonly [number, number]; readonly radius: number; readonly paint: Paint }
  | ({ readonly op: 'text'; readonly text: string; readonly box: Box; readonly align: 'start' | 'center'; readonly direction: 'ltr' | 'rtl' } & TextStyle)
  | { readonly op: 'asset'; readonly kind: 'svg' | 'raster'; readonly package: string; readonly path: string; readonly box: Box }
);

/** A rounded rect with one radius at every corner. */
export interface RRect {
  readonly rect: Rect;
  readonly radius: number;
}

export const boxOf = (r: Rect): Box => [r.left, r.top, r.right - r.left, r.bottom - r.top];
export const rrectList = ({ rect, radius }: RRect): RRectList => {
  const r = Math.max(0, radius);
  return [...boxOf(rect), r, r, r, r, r, r, r, r];
};
export const deflate = (r: Rect, d: number): Rect => ({ left: r.left + d, top: r.top + d, right: r.right - d, bottom: r.bottom - d });
export const deflateRRect = (r: RRect, d: number): RRect => ({ rect: deflate(r.rect, d), radius: r.radius - d });

const multiply = (p: Matrix, q: Matrix): Matrix => [
  p[0] * q[0] + p[2] * q[1],
  p[1] * q[0] + p[3] * q[1],
  p[0] * q[2] + p[2] * q[3],
  p[1] * q[2] + p[3] * q[3],
  p[0] * q[4] + p[2] * q[5] + p[4],
  p[1] * q[4] + p[3] * q[5] + p[5],
];

type Body<K extends DisplayOp['op']> = Omit<Extract<DisplayOp, { op: K }>, 'op' | 'm'>;

/** [D1] A canvas that keeps every call with the transform it ran under, as the Dart Recorder does. */
export class DisplayList {
  readonly ops: DisplayOp[] = [];
  private stack: Matrix[] = [identity];

  get matrix(): Matrix {
    return this.stack[this.stack.length - 1];
  }

  private add<K extends DisplayOp['op']>(op: K, body: Body<K>): void {
    const m = this.matrix;
    const plain = m.every((v, i) => v === identity[i]);
    this.ops.push({ op, ...(plain ? {} : { m }), ...body } as DisplayOp);
  }

  save(): void {
    this.add('save', {});
    this.stack.push(this.matrix);
  }

  layer(bounds: Box | null, opacity: number): void {
    this.add('layer', { bounds, paint: { color: (Math.round(opacity * 255) * 2 ** 24) } });
    this.stack.push(this.matrix);
  }

  restore(): void {
    this.stack.pop();
    this.add('restore', {});
  }

  transform(t: Matrix): void {
    this.stack[this.stack.length - 1] = multiply(this.matrix, t);
  }

  translate(dx: number, dy: number): void {
    if (dx !== 0 || dy !== 0) this.transform([1, 0, 0, 1, dx, dy]);
  }

  scale(sx: number, sy = sx): void {
    if (sx !== 1 || sy !== 1) this.transform([sx, 0, 0, sy, 0, 0]);
  }

  rotate(radians: number): void {
    const c = Math.cos(radians), s = Math.sin(radians);
    this.transform([c, s, -s, c, 0, 0]);
  }

  clipRect(r: Rect): void {
    this.add('clipRect', { rect: boxOf(r) });
  }
  clipRRect(r: RRect): void {
    this.add('clipRRect', { rrect: rrectList(r) });
  }
  clipPath(path: string): void {
    this.add('clipPath', { path });
  }
  rect(r: Rect, paint: Paint): void {
    this.add('rect', { rect: boxOf(r), paint });
  }
  rrect(r: RRect, paint: Paint): void {
    this.add('rrect', { rrect: rrectList(r), paint });
  }
  /** A rounded rect with per-corner radii, already in list form. */
  rrectRaw(rrect: RRectList, paint: Paint): void {
    this.add('rrect', { rrect, paint });
  }
  drrect(outer: RRect, inner: RRect, paint: Paint): void {
    this.add('drrect', { outer: rrectList(outer), inner: rrectList(inner), paint });
  }
  path(path: string, paint: Paint): void {
    this.add('path', { path, paint });
  }
  circle(cx: number, cy: number, radius: number, paint: Paint): void {
    this.add('circle', { center: [cx, cy], radius, paint });
  }
  text(body: Body<'text'>): void {
    this.add('text', body);
  }
  asset(body: Body<'asset'>): void {
    this.add('asset', body);
  }
}

/** [H15] Flutter's `withValues(alpha: a * f)`: the alpha channel scaled, rounded. */
export function withAlpha(c: Color, f: number): Color {
  if (f >= 1) return c;
  const a = Math.round(((c >>> 24) & 0xff) * Math.max(0, f));
  return a * 2 ** 24 + (c & 0xffffff);
}
