import type { PlateShape } from './plate_shape';

/**
 * Anything a flag slot can show: a file a package ships, or a PlateDrawing
 * made of shapes.
 */
export type PlateGraphic = PlateDrawing | PlateAsset;

/**
 * A picture built from filled `shapes` in a `width` x `height` space, painted
 * scaled to whatever box it is given. Later shapes cover earlier ones.
 */
export interface PlateDrawing {
  readonly kind: 'drawing';
  readonly width: number;
  readonly height: number;
  readonly shapes: readonly PlateShape[];
}

/**
 * An image a country package ships, addressed by the package that owns it:
 * `svg` is rasterised at device-pixel size, `raster` is shown as is.
 */
export type PlateAsset = SvgPlateAsset | RasterPlateAsset;

export interface SvgPlateAsset {
  readonly kind: 'svg';
  readonly path: string;
  readonly package: string;
}

export interface RasterPlateAsset {
  readonly kind: 'raster';
  readonly path: string;
  readonly package: string;
}

export const plateDrawing = (width: number, height: number, shapes: readonly PlateShape[]): PlateDrawing => ({
  kind: 'drawing',
  width,
  height,
  shapes,
});

export const svgPlateAsset = (path: string, pkg: string): SvgPlateAsset => ({ kind: 'svg', path, package: pkg });

export const rasterPlateAsset = (path: string, pkg: string): RasterPlateAsset => ({
  kind: 'raster',
  path,
  package: pkg,
});
