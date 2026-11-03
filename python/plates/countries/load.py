"""Builds a country's specs from its generated data (ports/data, D3). Shared runtime: no country here (W6, W7)."""
from __future__ import annotations

import json
import re
from typing import Callable, NamedTuple

from plates.core.model.plate_alphabet import AlphabetInput, PlateAlphabet, TextDirection
from plates.core.model.plate_asset import PlateDrawing, RasterPlateAsset, SvgPlateAsset
from plates.core.model.plate_box import PlateBox
from plates.core.model.plate_country import PlateCountry
from plates.core.model.plate_restriction import PlateRestriction
from plates.core.model.plate_shape import (PlateCircleShape, PlateCrescentShape, PlatePolygonShape, PlateRectShape,
                                           PlateRingShape, PlateStarRingShape, PlateStarShape)
from plates.core.model.plate_spec import (Axis, ColorFill, Insets, Leaf, PlateBand, PlateDecal, PlateFog, PlateLabel,
                                          PlateMirror, PlatePanel, PlatePart, PlateRule, PlateSlot, PlateSpec,
                                          PlateTextGroup, Role, Split, StripesFill)
from plates.core.theme.plate_theme import PlateTheme

from .expand import expand_country
from .tables import label_table, theme_table


class Loaded(NamedTuple):
    countries: dict
    themes: dict
    specs: dict
    code_render: frozenset
    gallery: list


def _snake(k: str) -> str:
    return re.sub(r"[A-Z]", lambda m: "_" + m.group().lower(), k)


_SHAPES = {
    "rect": lambda s, c: PlateRectShape(s["left"], s["top"], s["width"], s["height"], c),
    "polygon": lambda s, c: PlatePolygonShape(tuple(map(tuple, s["points"])), c),
    "circle": lambda s, c: PlateCircleShape(s["cx"], s["cy"], s["radius"], c),
    "ring": lambda s, c: PlateRingShape(s["cx"], s["cy"], s["radius"], s["width"], c),
    "crescent": lambda s, c: PlateCrescentShape(s["cx"], s["cy"], s["radius"], s["biteDx"], s["biteRadius"], c),
    "star": lambda s, c: PlateStarShape(s["cx"], s["cy"], s["radius"], c, s["points"], s["innerRatio"], s["rotation"]),
    "starRing": lambda s, c: PlateStarRingShape(s["cx"], s["cy"], s["ringRadius"], s["starRadius"], s["count"], c,
                                                s["points"], s["innerRatio"]),
}


def _graphic(g):
    if g is None:
        return None
    if g["kind"] == "drawing":
        return PlateDrawing(g["width"], g["height"], tuple(_SHAPES[s["kind"]](s, s["color"]) for s in g["shapes"]))
    return (SvgPlateAsset if g["kind"] == "svg" else RasterPlateAsset)(g["path"], g["package"])


def _fill(f):
    if f["kind"] == "color":
        return ColorFill(f["color"])
    if f["kind"] != "stripes":
        return Role[f["kind"].upper()]
    fog = f["fog"]
    fog = fog and PlateFog(tuple(fog["center"]), tuple(fog["radii"]), fog["opacity"], fog["plateau"])
    return StripesFill(tuple(map(_fill, f["stripes"])), tuple(f["stops"]), f["angle"] or 0, fog)


def _shape(s):
    return s and f"{s['fillRule']}:{s['svg']}"


def _section(s):
    if s["kind"] == "fill":
        return Leaf(_fill(s["fill"]), _shape(s["shape"]))
    axis = Axis.HORIZONTAL if s["kind"] == "columns" else Axis.VERTICAL
    return Split(axis, tuple(PlatePart(_section(p["section"]), p["end"], p["divider"]) for p in s["parts"]))


def _country(c) -> PlateCountry:
    return PlateCountry(c["code"], tuple(c["captionLines"]), c["panelColor"], c["panelTextColor"],
                        tuple(c["headingLines"]), c["flagAspectRatio"], _graphic(c["flag"]), c["flagBorderColor"])


def _alphabet(a) -> PlateAlphabet:
    return PlateAlphabet.of(a["id"], a["characters"], AlphabetInput(a["input"]), a["isNumeric"],
                            glyphs=dict(a["glyphs"]), direction=TextDirection(a["direction"]), placeholder=a["placeholder"])


def load_country(text: str, code: dict[str, Callable] | None = None) -> Loaded:
    """The countries, themes, specs, code-rendered spec ids and gallery of one country's data, a JSON string. `code`
    holds the hand-ported `[D4-code]` resolvers by name."""
    d = expand_country(json.loads(text))
    resolvers, made = d["resolvers"], {}

    def resolver(name):
        if name is None:
            return None
        r = resolvers[name]
        if r["kind"] == "code":
            return code[name]
        if name not in made:  # once per country: specs share tables (Germany's districts)
            table = label_table if r["signature"] == "label" else theme_table
            made[name] = table(r["reads"], r["cut"], r["default"], r["enc"])
        return made[name]

    alphabets = {k: _alphabet(a) for k, a in d["alphabets"].items()}
    countries = {k: _country(c) for k, c in d["countries"].items()}
    box = lambda b: PlateBox(*b)

    def spec(s) -> PlateSpec:
        p = s["panel"]
        return PlateSpec(
            id=s["id"], country=countries[s["country"]], canvas_width=s["canvasWidth"], canvas_height=s["canvasHeight"],
            panel=p and PlatePanel(box(p["box"]), p["flagScale"], p["captionScale"], p["padding"] and Insets(*p["padding"]),
                                   Axis[p["direction"].upper()], _shape(p["shape"])),
            slots=tuple(PlateSlot(alphabets[x["alphabet"]], box(x["box"]), x["color"], x["length"], x["minLength"], x["spacing"])
                        for x in s["slots"]),
            background=_section(s["background"]),
            bands=tuple(PlateBand(box(b["box"]), b["color"], b["topCornerRadius"], b["bottomCornerRadius"]) for b in s["bands"]),
            rules=tuple(PlateRule(box(r["box"])) for r in s["rules"]),
            labels=tuple(PlateLabel(x["text"], box(x["box"]), x["glyphHeight"], x["color"], x["rotated"], x["lineHeight"],
                                    x["fontFamily"], x["fontPackage"], resolver(x["resolve"])) for x in s["labels"]),
            decals=tuple(PlateDecal(box(x["box"]), _graphic(x["image"]), _graphic(x["drawing"])) for x in s["decals"]),
            mirrors=tuple(PlateMirror(m["source"], box(m["box"]), m["glyphHeight"], m["alphabet"] and alphabets[m["alphabet"]],
                                      m["editable"]) for m in s["mirrors"]),
            text_direction=TextDirection(s["textDirection"]),
            border_width_ratio_override=s["borderWidthRatioOverride"], ink_override=s["inkOverride"],
            text_groups=tuple(PlateTextGroup(tuple(g["indices"]), g["prefix"], g["key"]) for g in s["textGroups"]),
            restrictions=tuple(PlateRestriction(r["group"], tuple(r["values"]), r["reason"]) for r in s["restrictions"]),
            resolve_theme=resolver(s["resolveTheme"]), resolve_region=resolver(s["resolveRegion"]),
        )

    def renders_code(s) -> bool:
        names = [s["resolveTheme"], s["resolveRegion"], *(x["resolve"] for x in s["labels"])]
        return any(n and resolvers[n]["kind"] == "code" for n in names)

    return Loaded(
        countries, {k: PlateTheme(t["plateBackground"], t["plateBorder"], t["ink"], t["dividerColor"], t["borderWidthRatio"],
                                  t["plateRadiusRatio"], t["activeColor"], t["inactiveColor"], t["alertColor"])
                     for k, t in d["themes"].items()},
        {s["id"]: spec(s) for s in d["specs"]}, frozenset(s["id"] for s in d["specs"] if renders_code(s)),
        [{k: g[k] for k in ("id", "label", "spec", "theme", "country", "validator", "sampleValues")} for g in d["gallery"]])
