"""[D1][H14] One SVG tree for the whole plate: a display list painted as nested groups (ts/src/ui/svg.ts)."""
from __future__ import annotations

import itertools
from typing import Callable

AssetResolver = Callable[[str, str], str]


def _spans(o: dict) -> str:
    alphas = o.get("alphas")
    if not alphas:
        return _attr(o["text"])
    return "".join(f'<tspan fill-opacity="{(alphas[i] if i < len(alphas) else 1):.3f}">{_attr(ch)}</tspan>'
                   for i, ch in enumerate(o["text"]))


def css(c: int) -> str:
    return f"rgba({(c >> 16) & 255},{(c >> 8) & 255},{c & 255},{((c >> 24) & 255) / 255:.3f})"


def _attr(s: str) -> str:
    return s.replace("&", "&amp;").replace("<", "&lt;").replace('"', "&quot;")


def _n(v: float) -> str:
    return str(int(v)) if v == int(v) else repr(v)


def _tf(m) -> str:
    return f' transform="matrix({" ".join(map(_n, m))})"' if m else ""


def rrect_d(r) -> str:
    """An rrect list as path data; each corner takes its own x/y radii."""
    l, t, w, h, tlx, tly, trx, try_, brx, bry, blx, bly = r
    R, B = l + w, t + h
    return (f"M{_n(l + tlx)} {_n(t)} H{_n(R - trx)} A{_n(trx)} {_n(try_)} 0 0 1 {_n(R)} {_n(t + try_)} "
            f"V{_n(B - bry)} A{_n(brx)} {_n(bry)} 0 0 1 {_n(R - brx)} {_n(B)} H{_n(l + blx)} "
            f"A{_n(blx)} {_n(bly)} 0 0 1 {_n(l)} {_n(B - bly)} V{_n(t + tly)} A{_n(tlx)} {_n(tly)} 0 0 1 {_n(l + tlx)} {_n(t)} Z")


def _fill(p: dict, defs: list[str], new_id: Callable[[], str]) -> str:
    if "stroke" in p:
        return (f' fill="none" stroke="{css(p["color"])}" stroke-width="{_n(p["stroke"])}" '
                f'stroke-linecap="{p.get("cap", "butt")}" stroke-linejoin="{p.get("join", "miter")}"')
    sh = p.get("shader")
    if sh:
        g, c = new_id(), css(sh["color"])
        defs.append(f'<radialGradient id="{g}" cx="0" cy="0" r="1" gradientUnits="userSpaceOnUse">'
                    f'<stop offset="0" stop-color="{c}"/><stop offset="{sh["plateau"]}" stop-color="{c}"/>'
                    f'<stop offset="1" stop-color="{css(sh["color"] & 0xFFFFFF)}"/></radialGradient>')
        return f' fill="url(#{g})"'
    return f' fill="{css(p["color"])}"'


def _box(tag: str, m: str, b, extra: str = "") -> str:
    return f'<{tag}{m} x="{_n(b[0])}" y="{_n(b[1])}" width="{_n(b[2])}" height="{_n(b[3])}"{extra}/>'


_serial = itertools.count()


def ops_to_svg(ops: list[dict], resolve_asset: AssetResolver = lambda p, a: f"packages/{p}/{a}") -> str:
    """The display list as the inside of an `<svg>`. Clips stay open to the matching restore, as on a
    canvas; `resolve_asset` turns a package asset into a URL the host serves."""
    defs: list[str] = []
    out: list[str] = []
    opened = [0]
    count = [0]
    # Ids are document-wide: a second plate on the page (a spec swap's ghost) must not resolve to this one's clips.
    k = next(_serial)

    def new_id() -> str:
        count[0] += 1
        return f"p{k}_{count[0] - 1}"

    def clip(shape: str) -> None:
        c = new_id()
        defs.append(f'<clipPath id="{c}">{shape}</clipPath>')
        out.append(f'<g clip-path="url(#{c})">')
        opened[-1] += 1

    for o in ops:
        op, m = o["op"], _tf(o.get("m"))
        if op in ("save", "layer"):
            opened.append(0)
            if op == "layer":
                out.append(f'<g opacity="{((o["paint"]["color"] >> 24) & 255) / 255:.3f}">')
                opened[-1] += 1
        elif op == "restore":
            out.append("</g>" * (opened.pop() if opened else 0))
        elif op == "clipRect":
            clip(_box("rect", m, o["rect"]))
        elif op == "clipRRect":
            clip(f'<path{m} d="{rrect_d(o["rrect"])}"/>')
        elif op == "clipPath":
            rule, d = o["path"].split(":", 1)
            clip(f'<path{m} clip-rule="{rule}" d="{d}"/>')
        elif op == "rect":
            out.append(_box("rect", m, o["rect"], _fill(o["paint"], defs, new_id)))
        elif op == "rrect":
            out.append(f'<path{m} d="{rrect_d(o["rrect"])}"{_fill(o["paint"], defs, new_id)}/>')
        elif op == "drrect":
            out.append(f'<path{m} fill-rule="evenodd" d="{rrect_d(o["outer"])} {rrect_d(o["inner"])}"'
                       f'{_fill(o["paint"], defs, new_id)}/>')
        elif op == "path":
            rule, d = o["path"].split(":", 1)
            out.append(f'<path{m} fill-rule="{rule}" d="{d}"{_fill(o["paint"], defs, new_id)}/>')
        elif op == "circle":
            cx, cy = o["center"]
            out.append(f'<circle{m} cx="{_n(cx)}" cy="{_n(cy)}" r="{_n(o["radius"])}"{_fill(o["paint"], defs, new_id)}/>')
        elif op == "text":
            # [H12] Line height 1 from the box top: the baseline sits at about 0.8 em.
            b = o["box"]
            x = b[0] + b[2] / 2 if o["align"] == "center" else b[0] + b[2] if o.get("direction") == "rtl" else b[0]
            anchor = "middle" if o["align"] == "center" else "start"
            out.append(f'<text{m} x="{_n(x)}" y="{_n(b[1] + b[3] / 2)}" dominant-baseline="central" text-anchor="{anchor}" '
                       f'direction="{o.get("direction", "ltr")}" font-family="{_attr(o["fontFamily"])}" '
                       f'font-size="{_n(o["fontSize"])}" font-weight="{o["fontWeight"]}" '
                       f'letter-spacing="{_n(o["letterSpacing"])}" fill="{css(o["color"])}">{_spans(o)}</text>')
        elif op == "asset":
            out.append(_box("image", m, o["box"], f' preserveAspectRatio="xMidYMid meet" '
                                                    f'href="{_attr(resolve_asset(o["package"], o["path"]))}"'))
    out.append("</g>" * sum(opened))
    return f'<defs>{"".join(defs)}</defs>{"".join(out)}'
