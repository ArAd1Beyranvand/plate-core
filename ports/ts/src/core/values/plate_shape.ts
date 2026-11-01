/** Colors are ARGB32 ints. */
export type Color = number;

/** A point as an [x, y] pair. */
export type Point = readonly [number, number];

export const pentagramRatio = 0.3819660112501051;

/**
 * One filled shape of a PlateDrawing, in the drawing's own coordinate space.
 * Shapes paint in list order, so a later one covers an earlier one. Path
 * building lives in render.
 */
export type PlateShape =
  | PlateRectShape
  | PlatePolygonShape
  | PlateCircleShape
  | PlateRingShape
  | PlateCrescentShape
  | PlateStarShape
  | PlateStarRingShape;

export interface PlateRectShape {
  readonly kind: 'rect';
  readonly left: number;
  readonly top: number;
  readonly width: number;
  readonly height: number;
  readonly color: Color;
}

export interface PlatePolygonShape {
  readonly kind: 'polygon';
  readonly points: readonly Point[];
  readonly color: Color;
}

export interface PlateCircleShape {
  readonly kind: 'circle';
  readonly cx: number;
  readonly cy: number;
  readonly radius: number;
  readonly color: Color;
}

/** The outline of a circle: a band `width` wide centred on `radius`. */
export interface PlateRingShape {
  readonly kind: 'ring';
  readonly cx: number;
  readonly cy: number;
  readonly radius: number;
  readonly width: number;
  readonly color: Color;
}

/**
 * A circle with a second circle taken out of it. The bite is `biteRadius`
 * wide and sits `biteDx` to the right of the disc's centre (left when negative).
 */
export interface PlateCrescentShape {
  readonly kind: 'crescent';
  readonly cx: number;
  readonly cy: number;
  readonly radius: number;
  readonly biteDx: number;
  readonly biteRadius: number;
  readonly color: Color;
}

/**
 * A regular star. `rotation` turns it clockwise, in degrees, from one point
 * straight up. `innerRatio` is the inner radius over `radius`.
 */
export interface PlateStarShape {
  readonly kind: 'star';
  readonly cx: number;
  readonly cy: number;
  readonly radius: number;
  readonly points: number;
  readonly innerRatio: number;
  readonly rotation: number;
  readonly color: Color;
}

/**
 * `count` equal stars on a circle of `ringRadius`, the first straight above
 * the centre and the rest clockwise from it, each one upright.
 */
export interface PlateStarRingShape {
  readonly kind: 'starRing';
  readonly cx: number;
  readonly cy: number;
  readonly ringRadius: number;
  readonly starRadius: number;
  readonly count: number;
  readonly points: number;
  readonly innerRatio: number;
  readonly color: Color;
}

export const plateRectShape = (
  left: number,
  top: number,
  width: number,
  height: number,
  color: Color,
): PlateRectShape => ({ kind: 'rect', left, top, width, height, color });

export const platePolygonShape = (points: readonly Point[], color: Color): PlatePolygonShape => ({
  kind: 'polygon',
  points,
  color,
});

export const plateCircleShape = (cx: number, cy: number, radius: number, color: Color): PlateCircleShape => ({
  kind: 'circle',
  cx,
  cy,
  radius,
  color,
});

export const plateRingShape = (
  cx: number,
  cy: number,
  radius: number,
  width: number,
  color: Color,
): PlateRingShape => ({ kind: 'ring', cx, cy, radius, width, color });

export const plateCrescentShape = (
  cx: number,
  cy: number,
  radius: number,
  biteDx: number,
  biteRadius: number,
  color: Color,
): PlateCrescentShape => ({ kind: 'crescent', cx, cy, radius, biteDx, biteRadius, color });

export const plateStarShape = (
  cx: number,
  cy: number,
  radius: number,
  color: Color,
  { points = 5, innerRatio = pentagramRatio, rotation = 0 } = {},
): PlateStarShape => ({ kind: 'star', cx, cy, radius, points, innerRatio, rotation, color });

export const plateStarRingShape = (
  cx: number,
  cy: number,
  ringRadius: number,
  starRadius: number,
  count: number,
  color: Color,
  { points = 5, innerRatio = pentagramRatio } = {},
): PlateStarRingShape => ({ kind: 'starRing', cx, cy, ringRadius, starRadius, count, points, innerRatio, color });
