"""Country data v2 (codegen.py, codegen/compact.mjs) -> the verbose dicts `load` reads. Every object is a tuple of its
kind's fields with the trailing defaults left off; KINDS is the one table, and must match the one in compact.mjs."""
from __future__ import annotations

from copy import deepcopy

# kind -> [(field, default, child)]. A child is a kind, or `kind[]` for a list; a default of "@f" copies the earlier f.
KINDS = {
    "spec": [("id",), ("country",), ("canvasWidth",), ("canvasHeight",), ("slots", [], "slot[]"), ("labels", [], "label[]"),
             ("panel", None, "panel"), ("background", {"kind": "fill", "fill": {"kind": "field"}, "shape": None}),
             ("bands", [], "band[]"), ("rules", [], "rule[]"), ("decals", [], "decal[]"), ("mirrors", [], "mirror[]"),
             ("textGroups", None, "group[]"), ("restrictions", [], "restriction[]"), ("textDirection", "ltr"),
             ("borderWidthRatioOverride", None), ("inkOverride", None), ("resolveTheme", None), ("resolveRegion", None)],
    "slot": [("alphabet",), ("box",), ("length", 1), ("minLength", "@length"), ("spacing", 0), ("color", None), ("group", None)],
    "label": [("text",), ("box",), ("glyphHeight",), ("color", None), ("rotated", False), ("lineHeight", None),
              ("fontFamily", None), ("fontPackage", None), ("resolve", None)],
    "panel": [("box",), ("flagScale", 1), ("captionScale", 1), ("padding", None), ("direction", "vertical"), ("shape", None)],
    "band": [("box",), ("color",), ("topCornerRadius", 0), ("bottomCornerRadius", 0)],
    "rule": [("box",)],
    "decal": [("box",), ("image", None), ("drawing", None)],
    "mirror": [("source",), ("box",), ("glyphHeight",), ("alphabet", None), ("editable", False)],
    "group": [("indices",), ("prefix", ""), ("key", None)],
    "restriction": [("group",), ("values",), ("reason",)],
    "country": [("code",), ("panelColor",), ("panelTextColor",), ("flagAspectRatio",), ("captionLines", []),
                ("headingLines", []), ("flag", None), ("flagBorderColor", None)],
    "gallery": [("id",), ("label",), ("spec",), ("sampleValues",), ("source",), ("section",), ("note", None),
                ("theme", None), ("country", None), ("validator", None), ("themeForValues", False), ("bands", [])],
    "alphabet": [("id",), ("chars",), ("input", "typed"), ("isNumeric", False), ("glyphs", []), ("direction", "ltr"),
                 ("placeholder", "?")],
}

INACTIVE, ALERT = 0xFFB0B0B0, 0xFFF87171


def build(kind: str, t: list) -> dict:
    """A tuple -> the dict of its kind, defaults filled in and children built."""
    out = {}
    for i, (name, *rest) in enumerate(KINDS[kind]):
        default, child = (rest + [None, None])[:2]
        if i >= len(t):
            out[name] = out[default[1:]] if isinstance(default, str) and default[:1] == "@" else deepcopy(default)
        elif child is None or t[i] is None:
            out[name] = t[i]
        else:
            out[name] = [build(child[:-2], x) for x in t[i]] if child.endswith("[]") else build(child, t[i])
    return out


def _alphabet(t: list) -> dict:
    a = build("alphabet", t)
    chars = [c for x in a.pop("chars") for c in (map(chr, range(ord(x[0]), ord(x[1]) + 1)) if isinstance(x, list) else [x])]
    return {**a, "characters": chars}


def _theme(t) -> dict:
    """A theme is a plain dict, or [field, ink, border, radius, inactive?, alert?] for one ink on one field."""
    if isinstance(t, dict):
        return t
    v = t + [INACTIVE, ALERT][len(t) - 4:]
    return {"plateBackground": v[0], "plateBorder": v[1], "ink": v[1], "dividerColor": v[1], "borderWidthRatio": v[2],
            "plateRadiusRatio": v[3], "activeColor": v[1], "inactiveColor": v[4], "alertColor": v[5]}


def _spec(t: list) -> dict:
    s = build("spec", t)
    slots = s["slots"]
    if s["textGroups"] is None:
        keyed = bool(slots) and all(x["group"] is not None for x in slots)
        s["textGroups"] = [{"indices": [i], "prefix": "", "key": x["group"]} for i, x in enumerate(slots)] if keyed else []
    for x in slots:
        del x["group"]
    s["noPanel"] = s["panel"] is None
    return s


def _resolver(r: list) -> dict:
    if r[0] == "code":
        return {"kind": "code", "signature": r[1]}
    return {"kind": "table", "signature": r[1], "reads": r[2], "cut": r[3], "default": r[4], "enc": r[5]}


def expand_country(c: dict) -> dict:
    return {
        "package": c["package"],
        "alphabets": {k: _alphabet(t) for k, t in c["alphabets"].items()},
        "countries": {k: build("country", t) for k, t in c["countries"].items()},
        "themes": {k: _theme(t) for k, t in c["themes"].items()},
        "specs": [_spec(t) for t in c["specs"]],
        "resolvers": {k: _resolver(r) for k, r in c["resolvers"].items()},
        "assets": c["assets"],
        "gallery": [build("gallery", t) for t in c["gallery"]],
    }
