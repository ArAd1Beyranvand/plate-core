import json
from functools import lru_cache
from pathlib import Path

import pytest

from plates.core.model.plate_alphabet import AlphabetInput, PlateAlphabet, TextDirection
from plates.core.model.plate_box import PlateBox, Rect
from plates.core.model.plate_input_source import PlateInputSource, default_input_source
from plates.core.model.plate_spec import (
    ColorFill, Leaf, PlatePart, PlateSlot, Role, Split, StripesFill, Axis, PlateFog, layout,
)
from plates.core.model.slot_behavior import PlateMode, resolve_slot_behavior
from tests.vectors import load_vectors

DATA = Path(__file__).resolve().parents[3] / "data"


@lru_cache(None)
def alphabet(ref: str) -> PlateAlphabet:
    a = json.loads((DATA / "alphabets.json").read_text(encoding="utf8"))["alphabets"][ref]
    return PlateAlphabet.of(
        a["id"], a["characters"], AlphabetInput(a["input"]), a["isNumeric"],
        glyphs=dict(a["glyphs"]), direction=TextDirection(a["direction"]), placeholder=a["placeholder"],
    )


@pytest.mark.parametrize("case", load_vectors("core/alphabet.json"), ids=lambda c: c["name"])
def test_alphabet(case):
    i, e = case["input"], case["expect"]
    if "include" in i:
        a = PlateAlphabet.pattern("t", i["include"], AlphabetInput.TYPED, False, exclude=i["exclude"])
        assert list(a.characters) == e["characters"]
        return
    a, v = alphabet(i["alphabet"]), i["value"]
    assert a.accepts(v) == e["accepts"]
    assert a.canonical(v) == e["canonical"]
    assert a.render(v) == e["render"]
    assert a.render_all(v) == e["renderAll"]
    assert a.canonical_all(v) == e["canonicalAll"]


@pytest.mark.parametrize(
    "case", [c for c in load_vectors("core/values.json") if c["name"].startswith("slot ")],
    ids=lambda c: c["name"],
)
def test_slot(case):
    i, e = case["input"], case["expect"]
    s = i["slot"]
    slot = PlateSlot(alphabet(s["alphabet"]), PlateBox(0, 0, 1, 1), length=s["length"], min_length=s["minLength"])
    v = i["value"]
    if v is not None:
        assert slot.accepts(v) == e["accepts"]
        assert slot.canonical(v) == e["canonical"]
        assert slot.render(v) == e["render"]
    assert slot.is_full(v) == e["isFull"]
    assert slot.is_complete(v) == e["isComplete"]



@pytest.mark.parametrize(
    "case", [c for c in load_vectors("core/input.json") if c["name"].startswith("behavior")],
    ids=lambda c: c["name"],
)
def test_behavior(case):
    i = case["input"]
    got = resolve_slot_behavior(PlateMode(i["mode"]), AlphabetInput(i["input"]), PlateInputSource(i["source"]))
    assert got.value == case["expect"]


def test_default_source():
    assert default_input_source() is PlateInputSource.HARDWARE_KEYBOARD


def _fill(f):
    k = f["kind"]
    if k == "color":
        return ColorFill(f["color"])
    if k == "stripes":
        fog = f["fog"]
        return StripesFill(tuple(map(_fill, f["stripes"])), tuple(f["stops"]), f["angle"],
                           PlateFog(tuple(fog["center"]), tuple(fog["radii"]), fog["opacity"], fog["plateau"])
                           if fog else None)
    return Role(k)


def _section(s):
    if s["kind"] == "fill":
        return Leaf(_fill(s["fill"]), s["shape"] and s["shape"]["svg"])
    return Split(Axis.HORIZONTAL if s["kind"] == "columns" else Axis.VERTICAL,
                 tuple(PlatePart(_section(p["section"]), p["end"], p["divider"]) for p in s["parts"]))


@lru_cache(None)
def _backgrounds(package: str) -> dict:
    d = json.loads((DATA / "countries" / f"{package}.json").read_text(encoding="utf8"))
    return {s["id"]: _section(s["background"]) for s in d["specs"]}


@pytest.mark.parametrize(
    "case", [c for c in load_vectors("core/layout.json") if "spec" in c["input"]], ids=lambda c: c["name"],
)
def test_section_layout(case):
    i = case["input"]
    out = layout(_backgrounds(i["package"])[i["spec"]], Rect(*i["bounds"]))
    assert [tuple(r) for _, r in out.leaves] == [pytest.approx(r) for r in case["expect"]["leaves"]]
    assert [tuple(r) for r in out.dividers] == [pytest.approx(r) for r in case["expect"]["dividers"]]
