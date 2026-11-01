"""Specs, countries and themes from ports/data, as the render vectors need them."""
from __future__ import annotations

import json
import re
from dataclasses import dataclass
from functools import lru_cache
from pathlib import Path

from plates.core.model.plate_asset import PlateDrawing, RasterPlateAsset, SvgPlateAsset
from plates.core.model.plate_country import PlateCountry
from plates.core.model.plate_shape import (
    PlateCircleShape, PlateCrescentShape, PlatePolygonShape, PlateRectShape, PlateRingShape,
    PlateStarRingShape, PlateStarShape,
)
from plates.core.model.plate_spec import PlateSpec
from plates.core.theme.plate_theme import PlateTheme
from plates.countries import load

DATA = Path(__file__).resolve().parents[2] / "data"


def snake(k: str) -> str:
    return re.sub(r"[A-Z]", lambda m: "_" + m.group().lower(), k)


def theme_of(t: dict) -> PlateTheme:
    return PlateTheme(**{snake(k): v for k, v in t.items()})


_SHAPES = {
    "rect": lambda s: PlateRectShape(s["left"], s["top"], s["width"], s["height"], s["color"]),
    "polygon": lambda s: PlatePolygonShape(tuple(map(tuple, s["points"])), s["color"]),
    "circle": lambda s: PlateCircleShape(s["cx"], s["cy"], s["radius"], s["color"]),
    "ring": lambda s: PlateRingShape(s["cx"], s["cy"], s["radius"], s["width"], s["color"]),
    "crescent": lambda s: PlateCrescentShape(s["cx"], s["cy"], s["radius"], s["biteDx"], s["biteRadius"], s["color"]),
    "star": lambda s: PlateStarShape(s["cx"], s["cy"], s["radius"], s["color"], s["points"], s["innerRatio"],
                                     s["rotation"]),
    "starRing": lambda s: PlateStarRingShape(s["cx"], s["cy"], s["ringRadius"], s["starRadius"], s["count"],
                                             s["color"], s["points"], s["innerRatio"]),
}


def graphic_of(g):
    if g is None:
        return None
    if g["kind"] == "drawing":
        return PlateDrawing(g["width"], g["height"], tuple(_SHAPES[s["kind"]](s) for s in g["shapes"]))
    return (SvgPlateAsset if g["kind"] == "svg" else RasterPlateAsset)(g["path"], g["package"])


def country_of(c) -> PlateCountry:
    return PlateCountry(c["code"], tuple(c["captionLines"]), c["panelColor"], c["panelTextColor"],
                        tuple(c["headingLines"]), c["flagAspectRatio"], graphic_of(c["flag"]), c["flagBorderColor"])


@dataclass(frozen=True)
class LoadedSpec:
    spec: PlateSpec
    code_render: bool
    """A label or theme resolver is code: the port cannot paint the spec as Dart does."""


@lru_cache(None)
def package(pkg: str) -> dict:
    return json.loads((DATA / "countries" / f"{pkg}.json").read_text(encoding="utf8"))


def spec_of(pkg: str, id: str) -> LoadedSpec:
    """The generated spec: plates.countries.<country>.data."""
    data = load(pkg.removesuffix("_plate"))
    return LoadedSpec(data.SPECS[id], id in data.CODE_RENDER)
