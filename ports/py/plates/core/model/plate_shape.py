from __future__ import annotations

from dataclasses import dataclass
from typing import Union

Color = int  # 0xAARRGGBB

PENTAGRAM_RATIO = 0.3819660112501051


@dataclass(frozen=True)
class PlateRectShape:
    left: float
    top: float
    width: float
    height: float
    color: Color


@dataclass(frozen=True)
class PlatePolygonShape:
    points: tuple[tuple[float, float], ...]
    color: Color


@dataclass(frozen=True)
class PlateCircleShape:
    cx: float
    cy: float
    radius: float
    color: Color


@dataclass(frozen=True)
class PlateRingShape:
    """The outline of a circle: a band `width` wide centred on `radius`."""

    cx: float
    cy: float
    radius: float
    width: float
    color: Color


@dataclass(frozen=True)
class PlateCrescentShape:
    """A circle with a second circle (`bite_radius`, `bite_dx` right of centre) taken out."""

    cx: float
    cy: float
    radius: float
    bite_dx: float
    bite_radius: float
    color: Color


@dataclass(frozen=True)
class PlateStarShape:
    """A regular star; `rotation` turns it clockwise, in degrees, from one point straight up."""

    cx: float
    cy: float
    radius: float
    color: Color
    points: int = 5
    inner_ratio: float = PENTAGRAM_RATIO
    rotation: float = 0


@dataclass(frozen=True)
class PlateStarRingShape:
    """`count` equal upright stars on a circle of `ring_radius`, the first straight above the centre."""

    cx: float
    cy: float
    ring_radius: float
    star_radius: float
    count: int
    color: Color
    points: int = 5
    inner_ratio: float = PENTAGRAM_RATIO


PlateShape = Union[
    PlateRectShape,
    PlatePolygonShape,
    PlateCircleShape,
    PlateRingShape,
    PlateCrescentShape,
    PlateStarShape,
    PlateStarRingShape,
]
