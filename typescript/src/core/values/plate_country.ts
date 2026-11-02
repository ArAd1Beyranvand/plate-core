import type { Color } from './plate_shape';
import type { PlateGraphic } from './plate_asset';

export interface PlateCountryInit {
  readonly code: string;
  readonly captionLines: readonly string[];
  readonly panelColor: Color;
  readonly panelTextColor: Color | null;
  readonly headingLines?: readonly string[];
  readonly flagAspectRatio?: number;
  readonly flag?: PlateGraphic;
  readonly flagBorderColor?: Color;
}

/** The country chrome of a plate. Equal iff the codes match. Colours are 0xAARRGGBB. */
export class PlateCountry {
  readonly code: string;
  readonly captionLines: readonly string[];
  readonly headingLines: readonly string[];
  readonly panelColor: Color;
  readonly panelTextColor: Color | null;
  readonly flagAspectRatio: number;
  readonly flag?: PlateGraphic;
  readonly flagBorderColor?: Color;

  constructor(init: PlateCountryInit) {
    this.code = init.code;
    this.captionLines = init.captionLines;
    this.headingLines = init.headingLines ?? [];
    this.panelColor = init.panelColor;
    this.panelTextColor = init.panelTextColor;
    this.flagAspectRatio = init.flagAspectRatio ?? 7 / 4;
    this.flag = init.flag;
    this.flagBorderColor = init.flagBorderColor;
  }

  equals(other: PlateCountry): boolean {
    return other.code === this.code;
  }
}
