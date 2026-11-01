from __future__ import annotations

from dataclasses import dataclass
from typing import Union

from .plate_shape import PlateShape


@dataclass(frozen=True)
class PlateDrawing:
    """Filled `shapes` in a `width` x `height` space; later shapes cover earlier ones."""

    width: float
    height: float
    shapes: tuple[PlateShape, ...]


@dataclass(frozen=True)
class SvgPlateAsset:
    """Rasterised at device-pixel size; prefer it for flags."""

    path: str
    package: str


@dataclass(frozen=True)
class RasterPlateAsset:
    path: str
    package: str


PlateAsset = Union[SvgPlateAsset, RasterPlateAsset]
PlateGraphic = Union[PlateDrawing, SvgPlateAsset, RasterPlateAsset]
