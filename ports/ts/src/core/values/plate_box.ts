/** A plain rectangle; the one Rect type of the model. */
export interface Rect {
  readonly left: number;
  readonly top: number;
  readonly right: number;
  readonly bottom: number;
}

export const rectFromLTWH = (left: number, top: number, width: number, height: number): Rect => ({
  left,
  top,
  right: left + width,
  bottom: top + height,
});

/**
 * A rectangle in plate coordinates: origin at the plate's top-left, units
 * shared with PlateSpec.canvasWidth and canvasHeight.
 */
export class PlateBox {
  constructor(
    readonly left: number,
    readonly top: number,
    readonly width: number,
    readonly height: number,
  ) {}

  get right(): number {
    return this.left + this.width;
  }

  get bottom(): number {
    return this.top + this.height;
  }

  get rect(): Rect {
    return rectFromLTWH(this.left, this.top, this.width, this.height);
  }
}
