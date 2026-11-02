import { type Rect, rectFromLTWH } from '../core/values/plate_box';
import type { PlateCountry } from '../core/values/plate_country';
import type { PlatePanel } from '../core/values/plate_spec';
import type { Color } from '../core/values/plate_shape';
import { type DisplayList } from './display_list';
import { paintFlag } from './plate_flag';
import { shiftPath } from './plate_frame';
import { measureText } from './text_measure';

export interface Size {
  readonly width: number;
  readonly height: number;
}

/** The flag fills the cross axis by flagScale, then shrinks to fit the main axis. */
export function flagSize(panel: PlatePanel, country: PlateCountry, innerW: number, innerH: number): Size {
  const scale = panel.flagScale ?? 1, aspect = country.flagAspectRatio;
  if (panel.direction === 'horizontal') {
    let h = innerH * scale, w = h * aspect;
    if (w > innerW) [w, h] = [innerW, innerW / aspect];
    return { width: w, height: h };
  }
  let w = innerW * scale, h = w / aspect;
  if (h > innerH) [w, h] = [innerH * aspect, innerH];
  return { width: w, height: h };
}

/** One band of wording: its lines, the box they scale down into, and which edge they hug. */
export interface PanelWording {
  readonly lines: readonly string[];
  readonly box: Rect;
  readonly alignX: -1 | 1;
}

/** [D1] CountryPanel as plain rects in plate units: flag, then heading and caption. */
export interface PanelLayout {
  readonly block: Rect;
  readonly flag: Rect;
  readonly heading?: PanelWording;
  readonly caption: PanelWording;
}

export function panelLayout(panel: PlatePanel, country: PlateCountry): PanelLayout {
  const b = panel.box;
  const p = panel.padding ?? { left: b.height * 0.1, top: b.height * 0.1, right: b.height * 0.1, bottom: b.height * 0.1 };
  const innerW = b.width - p.left - p.right, innerH = b.height - p.top - p.bottom;
  const x0 = b.left + p.left, y0 = b.top + p.top;
  const flag = flagSize(panel, country, innerW, innerH);
  const share = country.headingLines.length > 0 ? 0.5 : 1;
  const heading = (box: Rect): PanelWording | undefined => (share < 1 ? { lines: country.headingLines, box, alignX: -1 } : undefined);
  if (panel.direction === 'horizontal') {
    // Row(spaceBetween), children centred on the cross axis.
    const slack = Math.min(Math.max(innerW - flag.width, 0), innerW) * share;
    const fy = y0 + (innerH - flag.height) / 2;
    const fx = share < 1 ? x0 + (innerW - flag.width) / 2 : x0;
    return {
      block: b.rect,
      flag: rectFromLTWH(fx, fy, flag.width, flag.height),
      heading: heading(rectFromLTWH(x0, y0, slack, innerH)),
      caption: { lines: country.captionLines, box: rectFromLTWH(x0 + innerW - slack, y0, slack, innerH), alignX: 1 },
    };
  }
  // Column(stretch, spaceBetween), the flag centred across.
  const slack = Math.min(Math.max(innerH - flag.height, 0), innerH) * share;
  const fy = share < 1 ? y0 + slack : y0;
  return {
    block: b.rect,
    flag: rectFromLTWH(x0 + (innerW - flag.width) / 2, fy, flag.width, flag.height),
    heading: heading(rectFromLTWH(x0, y0, innerW, slack)),
    caption: { lines: country.captionLines, box: rectFromLTWH(x0, y0 + innerH - slack, innerW, slack), alignX: -1 },
  };
}

const captionFontSize = 24;

/** [H12] _PanelWording: lines at 24·captionScale, scaled down (never up) to fit the box. */
function paintWording(c: DisplayList, w: PanelWording, color: Color, captionScale: number): void {
  if (w.lines.length === 0) return;
  const fontSize = captionFontSize * captionScale;
  const style = { fontSize, height: 1, color, fontFamily: 'Roboto', fontWeight: 800, letterSpacing: 0.25 } as const;
  const width = Math.max(...w.lines.map((l) => measureText(l, style)));
  const height = fontSize * w.lines.length;
  const bw = w.box.right - w.box.left, bh = w.box.bottom - w.box.top;
  const k = Math.min(1, bw / width, bh / height);
  // A FittedBox with no room paints nothing.
  if (!(k > 0)) return;
  const left = w.alignX < 0 ? w.box.left : w.box.right - width * k;
  const top = w.box.top + (bh - height * k) / 2;
  c.save();
  c.translate(left, top);
  c.scale(k);
  w.lines.forEach((text, i) => c.text({ text, box: [0, i * fontSize, measureText(text, style), fontSize], align: 'start', direction: 'ltr', ...style }));
  c.restore();
}

/** [D1] CountryPanel: the block (unless the background paints it), heading, flag, caption; cut by the panel shape. */
export function paintPanel(c: DisplayList, panel: PlatePanel, country: PlateCountry, ink: Color, paintBlock: boolean, show: { flag: boolean; caption: boolean } = { flag: true, caption: true }): void {
  const l = panelLayout(panel, country);
  const color = country.panelTextColor ?? ink;
  const scale = panel.captionScale ?? 1;
  c.save();
  if (panel.shape !== undefined) c.clipPath(shiftPath(panel.shape, panel.box.left, panel.box.top));
  if (paintBlock && country.panelColor >>> 24 !== 0) {
    c.save();
    c.translate(l.block.left, l.block.top);
    c.rect(rectFromLTWH(0, 0, l.block.right - l.block.left, l.block.bottom - l.block.top), { color: country.panelColor });
    c.restore();
  }
  if (l.heading && show.caption) paintWording(c, l.heading, color, scale);
  if (show.flag) paintFlag(c, country.flag, l.flag, country.flagBorderColor);
  if (show.caption) paintWording(c, l.caption, color, scale);
  c.restore();
}
