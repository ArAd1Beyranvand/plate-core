import type { Rect } from '../core/values/plate_box';
import type { PlateGraphic } from '../core/values/plate_asset';
import type { Color } from '../core/values/plate_shape';
import { type DisplayList, boxOf, deflate } from './display_list';
import { paintDrawing } from './plate_drawing_view';

/** [D6] PlateFlag: a drawing stretched to [r], or an asset the host resolves; an optional hairline frame. */
export function paintFlag(c: DisplayList, flag: PlateGraphic | undefined, r: Rect, borderColor?: Color): void {
  if (flag?.kind === 'drawing') {
    c.save();
    c.translate(r.left, r.top);
    paintDrawing(c, flag, r.right - r.left, r.bottom - r.top, 'fill');
    c.restore();
  } else if (flag) c.asset({ kind: flag.kind, package: flag.package, path: flag.path, box: boxOf(r) });
  if (borderColor !== undefined) c.rect(deflate(r, 0.5), { color: borderColor, stroke: 1, cap: 'butt', join: 'miter' });
}
