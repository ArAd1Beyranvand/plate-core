from __future__ import annotations

import math
from typing import NamedTuple

from ..core.model.plate_box import Rect

Matrix = tuple[float, float, float, float, float, float]
"""[D1] `(a, b, c, d, tx, ty)`: x' = a·x + c·y + tx, y' = b·x + d·y + ty."""
IDENTITY: Matrix = (1, 0, 0, 1, 0, 0)


class RRect(NamedTuple):
    """A rounded rect with one radius at every corner."""

    rect: Rect
    radius: float


def ltrb(l: float, t: float, r: float, b: float) -> Rect:
    return Rect(l, t, r - l, b - t)


def box_of(r: Rect) -> list[float]:
    return [r.left, r.top, r.width, r.height]


def rrect_list(r: RRect) -> list[float]:
    k = max(0, r.radius)
    return [*box_of(r.rect), *[k] * 8]


def deflate(r: Rect, d: float) -> Rect:
    return Rect(r.left + d, r.top + d, r.width - 2 * d, r.height - 2 * d)


def deflate_rrect(r: RRect, d: float) -> RRect:
    return RRect(deflate(r.rect, d), r.radius - d)


def multiply(p: Matrix, q: Matrix) -> Matrix:
    return (
        p[0] * q[0] + p[2] * q[1],
        p[1] * q[0] + p[3] * q[1],
        p[0] * q[2] + p[2] * q[3],
        p[1] * q[2] + p[3] * q[3],
        p[0] * q[4] + p[2] * q[5] + p[4],
        p[1] * q[4] + p[3] * q[5] + p[5],
    )


def num(v: float) -> str:
    """A path coordinate rounded to 4 decimals, as the vectors print it."""
    r = round(v * 1e4) / 1e4
    return str(int(r)) if r == int(r) else repr(r)


def with_alpha(c: int, f: float) -> int:
    """[H15] Flutter's `withValues(alpha: a * f)`: the alpha channel scaled, rounded."""
    if f >= 1:
        return c
    return (math.floor(((c >> 24) & 0xFF) * max(0, f) + 0.5) << 24) | (c & 0xFFFFFF)


class DisplayList:
    """[D1] A canvas that keeps every call with the transform it ran under, as the Dart Recorder does.

    Each op is a dict in the shape of ports/vectors/render; `m` maps local geometry to plate units."""

    def __init__(self):
        self.ops: list[dict] = []
        self._stack: list[Matrix] = [IDENTITY]

    @property
    def matrix(self) -> Matrix:
        return self._stack[-1]

    def _add(self, op: str, **body) -> None:
        m = self.matrix
        self.ops.append({"op": op, **({} if m == IDENTITY else {"m": list(m)}), **body})

    def save(self) -> None:
        self._add("save")
        self._stack.append(self.matrix)

    def layer(self, bounds: Rect | None, opacity: float) -> None:
        self._add("layer", bounds=bounds and box_of(bounds), paint={"color": round(opacity * 255) << 24})
        self._stack.append(self.matrix)

    def restore(self) -> None:
        self._stack.pop()
        self._add("restore")

    def transform(self, t: Matrix) -> None:
        self._stack[-1] = multiply(self.matrix, t)

    def translate(self, dx: float, dy: float) -> None:
        if dx or dy:
            self.transform((1, 0, 0, 1, dx, dy))

    def scale(self, sx: float, sy: float | None = None) -> None:
        sy = sx if sy is None else sy
        if sx != 1 or sy != 1:
            self.transform((sx, 0, 0, sy, 0, 0))

    def rotate(self, radians: float) -> None:
        c, s = math.cos(radians), math.sin(radians)
        self.transform((c, s, -s, c, 0, 0))

    def clip_rect(self, r: Rect) -> None:
        self._add("clipRect", rect=box_of(r))

    def clip_rrect(self, r: RRect) -> None:
        self._add("clipRRect", rrect=rrect_list(r))

    def clip_path(self, path: str) -> None:
        self._add("clipPath", path=path)

    def rect(self, r: Rect, paint: dict) -> None:
        self._add("rect", rect=box_of(r), paint=paint)

    def rrect(self, r: RRect | list[float], paint: dict) -> None:
        """`r` may already be in list form, with per-corner radii."""
        self._add("rrect", rrect=r if isinstance(r, list) else rrect_list(r), paint=paint)

    def drrect(self, outer: RRect, inner: RRect, paint: dict) -> None:
        self._add("drrect", outer=rrect_list(outer), inner=rrect_list(inner), paint=paint)

    def path(self, path: str, paint: dict) -> None:
        self._add("path", path=path, paint=paint)

    def circle(self, cx: float, cy: float, radius: float, paint: dict) -> None:
        self._add("circle", center=[cx, cy], radius=radius, paint=paint)

    def text(self, **body) -> None:
        self._add("text", **body)

    def asset(self, **body) -> None:
        self._add("asset", **body)
