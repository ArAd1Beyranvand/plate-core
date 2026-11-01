import dataclasses

import pytest

from plates.core.drawings.european_stars import BAND, FLAG
from plates.core.model.plate_asset import PlateDrawing, SvgPlateAsset
from plates.core.model.plate_box import PlateBox, Rect
from plates.core.model.plate_shape import PlateStarRingShape, PlateStarShape


def test_box_rect():
    b = PlateBox(1, 2, 3, 4)
    assert (b.right, b.bottom) == (4, 6)
    assert b.rect == Rect(1, 2, 3, 4)
    assert b.rect.right == 4


def test_star_defaults():
    assert PlateStarShape(0, 0, 1, 0xFF000000).points == 5


def test_european_stars():
    assert isinstance(BAND, PlateDrawing) and (BAND.width, BAND.height) == (46, 70.4)
    assert (FLAG.width, FLAG.height) == (900, 600)
    ring = FLAG.shapes[1]
    assert isinstance(ring, PlateStarRingShape) and ring.count == 12 and ring.color == 0xFFFFCC00


def test_frozen():
    with pytest.raises(dataclasses.FrozenInstanceError):
        SvgPlateAsset("a.svg", "x").path = "b"
