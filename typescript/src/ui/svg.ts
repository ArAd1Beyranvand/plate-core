import type { DisplayOp, Matrix, Paint, RRectList } from '../render/display_list';

/** [D1][H14] One SVG tree for the whole plate: a display list painted as nested groups. */

const css = (c: number) => `rgba(${(c >>> 16) & 255},${(c >>> 8) & 255},${c & 255},${(((c >>> 24) & 255) / 255).toFixed(3)})`;
const attr = (s: string) => s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/"/g, '&quot;');
const tf = (m?: Matrix) => (m ? ` transform="matrix(${m.join(' ')})"` : '');

/** An rrect list as path data; each corner takes its own x/y radii. */
function rrectD(r: RRectList): string {
  const [l, t, w, h, tlx, tly, trx, try_, brx, bry, blx, bly] = r;
  const R = l + w, B = t + h;
  return `M${l + tlx} ${t} H${R - trx} A${trx} ${try_} 0 0 1 ${R} ${t + try_} V${B - bry} A${brx} ${bry} 0 0 1 ${R - brx} ${B} H${l + blx} A${blx} ${bly} 0 0 1 ${l} ${B - bly} V${t + tly} A${tlx} ${tly} 0 0 1 ${l + tlx} ${t} Z`;
}

function fill(p: Paint, defs: string[], id: () => string): string {
  if (p.stroke !== undefined) return ` fill="none" stroke="${css(p.color)}" stroke-width="${p.stroke}" stroke-linecap="${p.cap ?? 'butt'}" stroke-linejoin="${p.join ?? 'miter'}"`;
  if (p.shader?.kind === 'fog') {
    const g = id();
    const c = css(p.shader.color);
    defs.push(`<radialGradient id="${g}" cx="0" cy="0" r="1" gradientUnits="userSpaceOnUse"><stop offset="0" stop-color="${c}"/><stop offset="${p.shader.plateau}" stop-color="${c}"/><stop offset="1" stop-color="${css(p.shader.color & 0xffffff)}"/></radialGradient>`);
    return ` fill="url(#${g})"`;
  }
  return ` fill="${css(p.color)}"`;
}

/**
 * The display list as the inside of an `<svg>`. Clips stay open to the matching restore,
 * as on a canvas; [resolveAsset] turns a package asset into a URL the host serves.
 */
export function opsToSvg(ops: readonly DisplayOp[], resolveAsset: (pkg: string, path: string) => string = (p, a) => `packages/${p}/${a}`): string {
  const defs: string[] = [];
  let n = 0;
  const id = () => `p${n++}`;
  const out: string[] = [];
  const open: number[] = [0];
  const clip = (shape: string) => {
    const c = id();
    defs.push(`<clipPath id="${c}">${shape}</clipPath>`);
    out.push(`<g clip-path="url(#${c})">`);
    open[open.length - 1]++;
  };
  for (const o of ops) {
    const m = tf(o.m);
    switch (o.op) {
      case 'save':
      case 'layer':
        open.push(0);
        if (o.op === 'layer') {
          out.push(`<g opacity="${(((o.paint.color >>> 24) & 255) / 255).toFixed(3)}">`);
          open[open.length - 1]++;
        }
        break;
      case 'restore':
        out.push('</g>'.repeat(open.pop() ?? 0));
        break;
      case 'clipRect':
        clip(`<rect${m} x="${o.rect[0]}" y="${o.rect[1]}" width="${o.rect[2]}" height="${o.rect[3]}"/>`);
        break;
      case 'clipRRect':
        clip(`<path${m} d="${rrectD(o.rrect)}"/>`);
        break;
      case 'clipPath': {
        const [rule, d] = o.path.split(':');
        clip(`<path${m} clip-rule="${rule}" d="${d}"/>`);
        break;
      }
      case 'rect':
        out.push(`<rect${m} x="${o.rect[0]}" y="${o.rect[1]}" width="${o.rect[2]}" height="${o.rect[3]}"${fill(o.paint, defs, id)}/>`);
        break;
      case 'rrect':
        out.push(`<path${m} d="${rrectD(o.rrect)}"${fill(o.paint, defs, id)}/>`);
        break;
      case 'drrect':
        out.push(`<path${m} fill-rule="evenodd" d="${rrectD(o.outer)} ${rrectD(o.inner)}"${fill(o.paint, defs, id)}/>`);
        break;
      case 'path': {
        const [rule, d] = o.path.split(':');
        out.push(`<path${m} fill-rule="${rule}" d="${d}"${fill(o.paint, defs, id)}/>`);
        break;
      }
      case 'circle':
        out.push(`<circle${m} cx="${o.center[0]}" cy="${o.center[1]}" r="${o.radius}"${fill(o.paint, defs, id)}/>`);
        break;
      case 'text': {
        // [H12] Line height 1 from the box top: the baseline sits at about 0.8 em.
        const x = o.align === 'center' ? o.box[0] + o.box[2] / 2 : o.direction === 'rtl' ? o.box[0] + o.box[2] : o.box[0];
        const anchor = o.align === 'center' ? 'middle' : 'start';
        out.push(
          `<text${m} x="${x}" y="${o.box[1] + o.box[3] / 2}" dominant-baseline="central" text-anchor="${anchor}" direction="${o.direction}" font-family="${attr(o.fontFamily)}" font-size="${o.fontSize}" font-weight="${o.fontWeight}" letter-spacing="${o.letterSpacing}" fill="${css(o.color)}">${o.alphas ? Array.from(o.text, (ch, i) => `<tspan fill-opacity="${(o.alphas![i] ?? 1).toFixed(3)}">${attr(ch)}</tspan>`).join('') : attr(o.text)}</text>`,
        );
        break;
      }
      case 'asset':
        out.push(`<image${m} x="${o.box[0]}" y="${o.box[1]}" width="${o.box[2]}" height="${o.box[3]}" preserveAspectRatio="xMidYMid meet" href="${attr(resolveAsset(o.package, o.path))}"/>`);
        break;
    }
  }
  out.push('</g>'.repeat(open.reduce((a, b) => a + b, 0)));
  return `<defs>${defs.join('')}</defs>${out.join('')}`;
}
