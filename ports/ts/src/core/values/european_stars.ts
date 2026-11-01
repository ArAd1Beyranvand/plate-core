import { plateDrawing } from './plate_asset';
import { plateRectShape, plateStarRingShape } from './plate_shape';

const gold = 0xffffcc00;

/** The EU's twelve gold stars, drawn rather than shipped, for every EU country to share. */
export const EuropeanStars = {
  /** Just the ring, on no field, for a panel that is already blue (46 x 70.4). */
  band: plateDrawing(46, 70.4, [plateStarRingShape(23, 35.2, 14.36, 2.9, 12, gold)]),

  /** The EU flag: 3:2, blue, ring of twelve stars at its centre. */
  flag: plateDrawing(900, 600, [
    plateRectShape(0, 0, 900, 600, 0xff003399),
    plateStarRingShape(450, 300, 200, 37.5, 12, gold),
  ]),
} as const;
