import { PlateController } from '../core/input/plate_controller';
import type { PlateTheme } from '../core/theme/plate_theme';
import type { PlateCountry } from '../core/values/plate_country';
import type { PlateSpec } from '../core/values/plate_spec';
import { PlateCanvas } from './plate_canvas';

/** [D1] PlateTextView as a formatter: the slot values in order, empty slots skipped. */
export function plateText(values: readonly (string | null)[]): string {
  return values.filter((v): v is string => !!v).join('');
}

/** [D1] Read-only plate: spec + values in, SVG out; null while empty and [emptySvg] is unset. */
export function plateViewSvg(o: { spec: PlateSpec; values: readonly (string | null)[]; theme?: PlateTheme; country?: PlateCountry; emptySvg?: string }): string {
  if (o.emptySvg !== undefined && o.values.every((v) => !v)) return o.emptySvg;
  const controller = new PlateController({ spec: o.spec, values: o.values });
  const canvas = new PlateCanvas({ spec: o.spec, controller, theme: o.theme, country: o.country, mode: 'display' });
  try {
    return canvas.svg();
  } finally {
    canvas.dispose();
    controller.dispose();
  }
}
