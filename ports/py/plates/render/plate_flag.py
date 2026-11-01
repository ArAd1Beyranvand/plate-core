from __future__ import annotations

from ..core.model.plate_asset import PlateDrawing, PlateGraphic, SvgPlateAsset
from ..core.model.plate_box import Rect
from .display_list import DisplayList, box_of, deflate
from .plate_drawing_view import paint_drawing


def asset_op(c: DisplayList, asset, r: Rect) -> None:
    c.asset(kind="svg" if isinstance(asset, SvgPlateAsset) else "raster", package=asset.package, path=asset.path,
            box=box_of(r))


def paint_flag(c: DisplayList, flag: PlateGraphic | None, r: Rect, border_color: int | None = None) -> None:
    """[D6] PlateFlag: a drawing stretched to `r`, or an asset the host resolves; an optional hairline frame."""
    if isinstance(flag, PlateDrawing):
        c.save()
        c.translate(r.left, r.top)
        paint_drawing(c, flag, r.width, r.height, "fill")
        c.restore()
    elif flag is not None:
        asset_op(c, flag, r)
    if border_color is not None:
        c.rect(deflate(r, 0.5), {"color": border_color, "stroke": 1, "cap": "butt", "join": "miter"})
