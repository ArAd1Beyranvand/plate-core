import json
import re
from pathlib import Path

import pytest

from plates.core.input.plate_controller import PlateController
from plates.core.model.plate_restriction import PlateRestriction
from plates.render.plate_canvas import render_plate
from tests.specs import country_of, package, spec_of, theme_of
from tests.vectors import load_vectors

FILES = sorted(p.name for p in (Path(__file__).resolve().parents[3] / "vectors" / "render").glob("*.json"))
TOL = 0.01
TEXT_KEYS = ("text", "align", "direction", "fontSize", "height", "color", "fontFamily", "fontWeight", "letterSpacing")
IDENTITY = [1, 0, 0, 1, 0, 0]
_NUM = re.compile(r"-?\d+(?:\.\d+)?(?:e-?\d+)?")


def gallery_country(i):
    """The code is shared by a package's variants: the gallery entry names the one shown."""
    d = package(i["package"])
    ref = next((g.get("country") for g in d["gallery"] if g["id"] == i["gallery"]), None)
    if ref:
        return country_of(d["countries"][ref])
    return next(country_of(c) for c in d["countries"].values() if c["code"] == i["country"])


def path_box(path):
    """The bounding box of a `<rule>:<d>` path's points."""
    n = [float(v) for v in _NUM.findall(path.split(":", 1)[1])]
    xs, ys = n[0::2], n[1::2]
    return [min(xs), min(ys), max(xs), max(ys)] if xs else []


def near(a, b, t):
    if isinstance(a, bool) or isinstance(b, bool):
        return a == b
    if isinstance(a, (int, float)) and isinstance(b, (int, float)):
        return abs(a - b) <= t
    if isinstance(a, list) and isinstance(b, list):
        return len(a) == len(b) and all(near(x, y, t) for x, y in zip(a, b))
    if isinstance(a, dict) and isinstance(b, dict):
        return all(near(a.get(k), b.get(k), t) for k in a.keys() | b.keys())
    return a == b


def channels_near(x, y):
    return all(abs(((x >> s) & 255) - ((y >> s) & 255)) <= 1 for s in (24, 16, 8, 0))


def diff(got, want):
    """The first difference between two display lists, save/restore aside; None when they match."""
    g = [o for o in got if o["op"] not in ("save", "restore")]
    w = [o for o in want if o["op"] not in ("save", "restore")]
    for i in range(max(len(g), len(w))):
        a, b = (g[i] if i < len(g) else None), (w[i] if i < len(w) else None)
        at = f"op {i}: got {json.dumps(a)[:300]}\n want {json.dumps(b)[:300]}"
        if not a or not b or a["op"] != b["op"]:
            return at
        if a["op"] == "text":
            if not all(near(a.get(k), b.get(k), TOL) for k in TEXT_KEYS):
                return at
            continue
        if a["op"] in ("path", "clipPath"):
            # The recorder samples a path every 0.25 of its own units, cutting sharp tips: compare there.
            if a["path"].split(":")[0] != b["path"].split(":")[0] \
                    or not near(a.get("m", IDENTITY), b.get("m", IDENTITY), TOL) \
                    or not near(path_box(a["path"]), path_box(b["path"]), 0.15) \
                    or not near(a.get("paint"), b.get("paint"), 0):
                return at
            continue
        ra, rb = dict(a), dict(b)
        am, bm = ra.pop("m", IDENTITY), rb.pop("m", IDENTITY)
        if "shader" in ra.get("paint", {}):
            # The fog's gradient is recorded as a flag only.
            ra["paint"] = {**ra["paint"], "shader": True}
        # The completed border's tint rounds per channel through doubles: allow one step.
        if a["op"] == "drrect" and channels_near(ra["paint"]["color"], rb["paint"]["color"]):
            ra["paint"] = rb["paint"]
        if not near(am, bm, TOL) or not near(ra, rb, TOL):
            return at
    return None


CASES = [pytest.param(f, c, id=f"{f[:-5]}: {c['name']}") for f in FILES for c in load_vectors(f"render/{f}")]


@pytest.mark.parametrize("file,case", CASES)
def test_render(file, case):
    i = case["input"]
    loaded = spec_of(i["package"], i["spec"])
    if loaded.code_render:
        pytest.skip("code resolver")
    spec = loaded.spec
    # Values reach the plate through a controller, which drops what a slot refuses.
    controller = PlateController(spec, i["values"])
    values = controller.values
    r = spec.restriction_violated_by(values)
    ops = render_plate(
        spec, values,
        theme=theme_of(i["theme"]) if i["theme"] else None,
        country=gallery_country(i) if i.get("country") else None,
        is_completed=controller.is_completed,
        # The Flutter test surface is 800x600; a wider plate is laid out squeezed into it.
        size=(min(i["size"][0], 800), min(i["size"][1], 600)),
        rejection=r and PlateRestriction(r.group, (), r.reason),
    )
    d = diff(ops, case["expect"])
    assert d is None, d
