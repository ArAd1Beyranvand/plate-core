from __future__ import annotations

import math

from ..core.model.plate_asset import PlateDrawing
from ..core.model.plate_shape import (
    PlateCircleShape, PlateCrescentShape, PlatePolygonShape, PlateRectShape, PlateRingShape, PlateShape,
    PlateStarRingShape, PlateStarShape,
)
from .display_list import DisplayList, num

Point = tuple[float, float]


def contour(pts: list[Point]) -> str:
    return " ".join(f"{'M' if i == 0 else 'L'}{num(x)} {num(y)}" for i, (x, y) in enumerate(pts)) + " Z"


def arc(cx: float, cy: float, r: float, start: float = 0, sweep: float = 2 * math.pi) -> list[Point]:
    """[H13] A circle as a polyline from `start` radians (clockwise on screen) over `sweep`, every 0.25 units."""
    steps = min(4000, max(16, math.ceil(r * abs(sweep) / 0.25)))
    full = abs(sweep) >= 2 * math.pi
    return [(cx + r * math.cos(start + sweep * i / steps), cy + r * math.sin(start + sweep * i / steps))
            for i in range(steps if full else steps + 1)]


def star_points(cx, cy, radius, points, inner_ratio, rotation) -> list[Point]:
    turn = math.radians(rotation)
    out = []
    for i in range(points * 2):
        r = radius if i % 2 == 0 else radius * inner_ratio
        a = turn + math.pi * i / points
        out.append((cx + r * math.sin(a), cy - r * math.cos(a)))
    return out


def crescent(cx, cy, r, dx, br) -> str:
    """[H13] Disc minus bite as one outline: the disc's arc outside the bite, the bite's inside the disc."""
    d = abs(dx)
    if d >= r + br:
        return contour(arc(cx, cy, r))
    if br >= d + r:
        return ""
    if r >= d + br:
        return f"{contour(arc(cx, cy, r))} {contour(arc(cx + dx, cy, br))}"
    toward = 0 if dx >= 0 else math.pi
    a = math.acos((d * d + r * r - br * br) / (2 * d * r))
    b = math.acos((d * d + br * br - r * r) / (2 * d * br))
    return contour(arc(cx, cy, r, toward + a, 2 * math.pi - 2 * a)
                   + arc(cx + dx, cy, br, toward + math.pi + b, -2 * b)[1:-1])


def shape_path(s: PlateShape) -> str:
    """[D1][H13] The shape as `<fillRule>:<SVG d>` in drawing units."""
    match s:
        case PlateRectShape():
            r, b = s.left + s.width, s.top + s.height
            return f"nonzero:{contour([(s.left, s.top), (r, s.top), (r, b), (s.left, b)])}"
        case PlatePolygonShape():
            return f"nonzero:{contour(list(s.points))}"
        case PlateCircleShape():
            return f"nonzero:{contour(arc(s.cx, s.cy, s.radius))}"
        case PlateRingShape():
            return (f"evenodd:{contour(arc(s.cx, s.cy, s.radius + s.width / 2))} "
                    f"{contour(arc(s.cx, s.cy, max(0, s.radius - s.width / 2)))}")
        case PlateCrescentShape():
            return f"evenodd:{crescent(s.cx, s.cy, s.radius, s.bite_dx, s.bite_radius)}"
        case PlateStarShape():
            return f"nonzero:{contour(star_points(s.cx, s.cy, s.radius, s.points, s.inner_ratio, s.rotation))}"
        case PlateStarRingShape():
            stars = []
            for i in range(s.count):
                a = 2 * math.pi * i / s.count
                stars.append(contour(star_points(s.cx + s.ring_radius * math.sin(a), s.cy - s.ring_radius * math.cos(a),
                                                 s.star_radius, s.points, s.inner_ratio, 0)))
            return f"nonzero:{' '.join(stars)}"


def paint_drawing(c: DisplayList, drawing: PlateDrawing, width: float, height: float, fit: str = "fill") -> None:
    """[D6][H13] PlateDrawingView: `fill` stretches (a flag), `contain` keeps proportions, centred (a decal)."""
    sx, sy = width / drawing.width, height / drawing.height
    if fit == "contain":
        sx = sy = min(sx, sy)
    c.save()
    c.translate((width - drawing.width * sx) / 2, (height - drawing.height * sy) / 2)
    c.scale(sx, sy)
    for shape in drawing.shapes:
        c.path(shape_path(shape), {"color": shape.color})
    c.restore()
