from __future__ import annotations

from ..model.plate_asset import PlateDrawing
from ..model.plate_shape import PlateRectShape, PlateStarRingShape

_GOLD = 0xFFFFCC00

# Just the ring, for a panel that is already blue (46 x 70.4).
BAND = PlateDrawing(46, 70.4, (PlateStarRingShape(23, 35.2, 14.36, 2.9, 12, _GOLD),))

# The EU flag: 3:2, blue, ring of twelve stars at its centre.
FLAG = PlateDrawing(
    900,
    600,
    (
        PlateRectShape(0, 0, 900, 600, 0xFF003399),
        PlateStarRingShape(450, 300, 200, 37.5, 12, _GOLD),
    ),
)
