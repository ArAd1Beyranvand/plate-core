from __future__ import annotations

from dataclasses import dataclass
from typing import NamedTuple


class Rect(NamedTuple):
    left: float
    top: float
    width: float
    height: float

    @property
    def right(self) -> float:
        return self.left + self.width

    @property
    def bottom(self) -> float:
        return self.top + self.height


@dataclass(frozen=True)
class PlateBox:
    """A rectangle in plate coordinates: origin at the plate's top-left."""

    left: float
    top: float
    width: float
    height: float

    @property
    def right(self) -> float:
        return self.left + self.width

    @property
    def bottom(self) -> float:
        return self.top + self.height

    @property
    def rect(self) -> Rect:
        return Rect(self.left, self.top, self.width, self.height)
