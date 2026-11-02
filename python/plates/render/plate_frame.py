from __future__ import annotations

import math
import re
from typing import Callable, NamedTuple

from ..core.model.plate_box import Rect
from ..core.model.plate_spec import Leaf, PlateSection, Role, StripesFill, layout, resolve_fill
from ..core.theme.plate_theme import PlateTheme, _lerp_color
from ..core.timing.plate_animation import PlatePartEffect, PlatePartId, PlatePartKind, PlatePartPhase
from ..core.timing.plate_part_animator import PlatePartFrame, plate_reveal_rect
from .display_list import DisplayList, RRect, deflate, deflate_rrect, num, with_alpha
from .plate_divider import paint_divider

Frames = Callable[[PlatePartId], PlatePartFrame]
_K = PlatePartKind


def _clamp01(v: float) -> float:
    return min(1, max(0, v))


class FrameGeometry(NamedTuple):
    """[D1] The outer rim, its inner edge, and the face the regions are clipped to."""

    border: float
    outer_radius: float
    inner_radius: float
    outer: RRect
    inner: RRect
    face: RRect


def frame_geometry(theme: PlateTheme, width: float, height: float, frames: Frames) -> FrameGeometry:
    border = theme.border_width_ratio * height * _clamp01(frames(PlatePartId(_K.BORDER_WIDTH)).shown)
    outer_radius = theme.plate_radius_ratio * height * _clamp01(frames(PlatePartId(_K.CORNER)).shown)
    inner_radius = min(max(outer_radius - border, 0), outer_radius)
    outer = RRect(Rect(0, 0, width, height), outer_radius)
    # Halfway into the border: its inner edge lies over a region, which never reaches the outer rim.
    return FrameGeometry(border, outer_radius, inner_radius, outer, RRect(deflate(outer.rect, border), inner_radius),
                         deflate_rrect(outer, border / 2))


def rim_clip(g: FrameGeometry) -> RRect:
    """Content bleeds this far under the border paint (PlateRimClip)."""
    return RRect(deflate(g.outer.rect, max(0, g.border - 0.75)), g.inner_radius)


def _fades(f: PlatePartFrame) -> bool:
    return f.motion.effect not in (PlatePartEffect.WIPE, PlatePartEffect.DRAW)


def paint_frame(c: DisplayList, theme: PlateTheme, width: float, height: float, background: PlateSection,
                panel_color: int, is_completed: bool, frames: Frames) -> None:
    """[D1] PlateFrame: face, regions, dividers, border, in that order, each clipped to the face."""
    g = frame_geometry(theme, width, height, frames)
    bounds = Rect(0, 0, width, height)
    out = layout(background, bounds)
    colors = (theme.plate_background, panel_color, theme.divider_color)

    face = frames(PlatePartId(_K.BACKGROUND))
    if not face.hidden:
        c.save()
        if face.phase is not PlatePartPhase.SETTLED and not _fades(face):
            c.clip_rect(plate_reveal_rect(bounds, face.motion.origin, face))
        c.clip_rrect(g.face)
        c.rrect(g.face, {"color": with_alpha(theme.plate_background, face.shown) if _fades(face)
                         else theme.plate_background})
        c.restore()

    for i, (leaf, r) in enumerate(out.leaves):
        frame = frames(PlatePartId(_K.REGION, i))
        if frame.hidden or not isinstance(leaf, Leaf) or leaf.fill is Role.FIELD:
            continue
        c.save()
        c.clip_rrect(g.face)
        if frame.phase is not PlatePartPhase.SETTLED and not _fades(frame):
            c.clip_rect(plate_reveal_rect(r, frame.motion.origin, frame))
        opacity = frame.shown if _fades(frame) else 1
        if isinstance(leaf.fill, StripesFill):
            _paint_stripes(c, leaf.fill, r, leaf.shape, opacity, colors)
        else:
            paint = {"color": with_alpha(resolve_fill(leaf.fill, *colors), opacity)}
            if leaf.shape is None:
                c.rect(r, paint)
            else:
                c.translate(r.left, r.top)
                c.path(leaf.shape, paint)
        c.restore()

    for i, r in enumerate(out.dividers):
        paint_divider(c, r, theme.divider_color, frames(PlatePartId(_K.DIVIDER, i)), g.face)

    _paint_border(c, theme, width, height, is_completed, frames, g, bounds)


def _paint_stripes(c: DisplayList, fill: StripesFill, r: Rect, shape: str | None, opacity: float, colors) -> None:
    """Each stripe a rect in a frame turned about `r`'s centre, clipped back to `r` (or its shape); then the fog."""
    cx, cy = r.left + r.width / 2, r.top + r.height / 2
    reach = max(r.width, r.height)
    angle = fill.angle or 0
    c.save()
    if shape is None:
        c.clip_rect(r)
    else:
        c.clip_path(shift_path(shape, r.left, r.top))
    c.translate(cx, cy)
    c.rotate(-angle)
    top = -reach
    # The Dart painter reuses one Paint: the fog keeps the last stripe's colour.
    last = 0xFF000000
    for i, stripe in enumerate(fill.stripes):
        bottom = (fill.stops[i] - cy) * math.cos(angle) if i < len(fill.stops) else reach
        if stripe is not Role.FIELD:
            last = with_alpha(resolve_fill(stripe, *colors), opacity)
            c.rect(Rect(-reach, top, 2 * reach, bottom - top), {"color": last})
        top = bottom
    c.restore()
    fog = fill.fog
    if fog:
        c.save()
        c.clip_rect(r)
        c.translate(*fog.center)
        c.scale(*fog.radii)
        c.circle(0, 0, 1, {"color": last, "shader": {"kind": "fog", "color": with_alpha(colors[0], fog.opacity * opacity),
                                                      "plateau": fog.plateau}})
        c.restore()


_NUM = re.compile(r"-?\d+(?:\.\d+)?(?:e-?\d+)?")


def shift_path(path: str, dx: float, dy: float) -> str:
    """Shifts every coordinate pair of a `<rule>:<M/L/Z d>` path."""
    rule, d = path.split(":", 1)
    xs = iter(range(10 ** 9))
    return f"{rule}:" + _NUM.sub(lambda m: num(float(m.group()) + (dy if next(xs) % 2 else dx)), d)


def _centreline(width: float, height: float, g: FrameGeometry):
    """The ring's centreline clockwise from the top-left corner, as points with running lengths."""
    h = g.border / 2
    l, t, rr, b = h, h, width - h, height - h
    r = max(0, g.outer_radius - h)
    pts = [(l + r, t)]

    def corner(cx, cy, start):
        steps = max(1, math.ceil(r * math.pi / 2 / 0.25))
        pts.extend((cx + r * math.cos(start + math.pi / 2 * i / steps), cy + r * math.sin(start + math.pi / 2 * i / steps))
                   for i in range(steps + 1))

    corner(rr - r, t + r, -math.pi / 2)
    corner(rr - r, b - r, 0)
    corner(l + r, b - r, math.pi / 2)
    corner(l + r, t + r, math.pi)
    at = [0.0]
    for i in range(1, len(pts)):
        at.append(at[-1] + math.dist(pts[i], pts[i - 1]))
    return pts, at


def _extract(line, start: float, end: float) -> str:
    """[H13] The run of the centreline between lengths `start` and `end`."""
    pts, at = line

    def point(s):
        i = 1
        while i < len(at) - 1 and at[i] < s:
            i += 1
        t = 0 if at[i] == at[i - 1] else (s - at[i - 1]) / (at[i] - at[i - 1])
        return (pts[i - 1][0] + (pts[i][0] - pts[i - 1][0]) * t, pts[i - 1][1] + (pts[i][1] - pts[i - 1][1]) * t)

    run = [point(start), *(p for p, a in zip(pts, at) if start < a < end), point(end)]
    return " ".join(f"{'M' if i == 0 else 'L'}{num(x)} {num(y)}" for i, (x, y) in enumerate(run))


def _lerp_unit(a: int, b: int, t: float) -> int:
    """[H15] The completed border's tint: Color.lerp on 0..1 channels."""
    out = 0
    for s in (24, 16, 8, 0):
        x, y = ((a >> s) & 0xFF) / 255, ((b >> s) & 0xFF) / 255
        out |= math.floor((x + (y - x) * t) * 255 + 0.5) << s
    return out


def _paint_border(c, theme, width, height, is_completed, frames, g, bounds) -> None:
    """Settled: a filled ring. Drawing: a stroke along the centreline, grown from start_point."""
    frame = frames(PlatePartId(_K.BORDER))
    if frame.hidden:
        return
    settled = _lerp_unit(theme.plate_border, theme.plate_background, 0.02) if is_completed else theme.plate_border
    shown = _clamp01(frames(PlatePartId(_K.BORDER_COLOR)).shown)
    color = settled if shown >= 1 else _lerp_color(theme.plate_background, settled, shown)
    a, b = frame.span
    whole = a <= 0 and b >= 1
    c.save()
    if whole or frame.motion.effect is not PlatePartEffect.DRAW:
        if whole or _fades(frame):
            c.drrect(g.outer, g.inner, {"color": color if whole or not _fades(frame) else with_alpha(color, frame.shown)})
        else:
            c.save()
            c.clip_rect(plate_reveal_rect(bounds, frame.motion.origin, frame))
            c.drrect(g.outer, g.inner, {"color": color})
            c.restore()
        c.restore()
        return
    line = _centreline(width, height, g)
    length = line[1][-1]
    s = (frame.motion.start_point % 1) * length
    lo_, hi_ = (s + a * length, s + b * length) if frame.motion.clockwise else (s - b * length, s - a * length)
    lo = lo_ % length
    span = hi_ - lo_
    d = (_extract(line, lo, lo + span) if lo + span <= length
         else f"{_extract(line, lo, length)} {_extract(line, 0, lo + span - length)}")
    c.path(f"nonzero:{d}", {"color": color, "stroke": g.border, "cap": "butt", "join": "miter"})
    c.restore()
