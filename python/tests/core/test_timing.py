import json
from functools import lru_cache
from pathlib import Path

import pytest

from plates.core.model.plate_box import PlateBox, Rect
from plates.core.model.plate_country import PlateCountry
from plates.core.model.plate_spec import (
    Axis, Insets, PlateBand, PlateDecal, PlateLabel, PlatePanel, PlateRule, PlateMirror, PlateSlot, PlateSpec,
)
from plates.core.model.plate_asset import PlateDrawing
from plates.core.timing.plate_animation import (
    CURVES, DEFAULT_MOTIONS, PlateAnimationController, PlateAnimationStyle, PlateMotion, PlatePartCue, PlatePartId,
    PlatePartKind as K, PlatePartPhase, PlateSpecTransition, all_of, plate_cue_length, plate_divider_count,
    plate_region_count, same_part, stagger_sequence,
)
from plates.core.timing.plate_part_animator import PlatePartFrame, part_timeline, plate_chain, plate_reveal_rect
from tests.core.test_model import _section, alphabet
from tests.vectors import load_vectors

DATA = Path(__file__).resolve().parents[3] / "data"
CASES = load_vectors("core/timing.json")


def _by(prefix):
    return [c for c in CASES if c["name"].startswith(prefix)]


def _box(b):
    return PlateBox(*b)


@lru_cache(None)
def _specs(package: str) -> dict:
    d = json.loads((DATA / "countries" / f"{package}.json").read_text(encoding="utf8"))
    countries = {
        ref: PlateCountry(c["code"], tuple(c["captionLines"]), c["panelColor"], c["panelTextColor"])
        for ref, c in d["countries"].items()
    }
    out = {}
    for s in d["specs"]:
        p = s["panel"]
        out[s["id"]] = PlateSpec(
            s["id"], countries[s["country"]], s["canvasWidth"], s["canvasHeight"],
            None if s["noPanel"] else PlatePanel(
                _box(p["box"]), p["flagScale"], p["captionScale"], p["padding"] and Insets(*p["padding"]),
                Axis(p["direction"]), p["shape"] and p["shape"]["svg"]),
            tuple(PlateSlot(alphabet(x["alphabet"]), _box(x["box"]), x["color"], x["length"], x["minLength"],
                            x["spacing"]) for x in s["slots"]),
            _section(s["background"]),
            tuple(PlateBand(_box(x["box"]), x["color"], x["topCornerRadius"], x["bottomCornerRadius"])
                  for x in s["bands"]),
            tuple(PlateRule(_box(x["box"])) for x in s["rules"]),
            tuple(PlateLabel(x["text"], _box(x["box"]), x["glyphHeight"], x["color"], x["rotated"], x["lineHeight"],
                             x["fontFamily"], x["fontPackage"]) for x in s["labels"]),
            tuple(PlateDecal(_box(x["box"]), drawing=PlateDrawing(0, 0, ())) for x in s["decals"]),
            tuple(PlateMirror(x["source"], _box(x["box"]), x["glyphHeight"]) for x in s["mirrors"]),
            ink_override=s["inkOverride"],
        )
    return out


@pytest.mark.parametrize("case", _by("curve"), ids=lambda c: c["name"])
def test_curve(case):
    curve = CURVES[case["input"]["curve"]]
    assert curve.bezier == (tuple(case["expect"]["cubic"]) if case["expect"]["cubic"] else None)
    assert [curve.transform(t) for t in case["input"]["t"]] == pytest.approx(case["expect"]["value"], abs=1e-9)


def _motion_json(m):
    return {"effect": m.effect.value, "durationMs": m.duration, "curve": m.curve.name, "delayMs": m.delay,
            "origin": list(m.origin), "startPoint": m.start_point, "clockwise": m.clockwise, "softEdge": m.soft_edge}


def test_motions():
    style = PlateAnimationStyle()
    for c in _by("motion"):
        assert _motion_json(PlateMotion()) == c["expect"]
    for c in _by("style"):
        assert _motion_json(style.motion_for(PlatePartId(K(c["input"]["kind"]), 3))) == c["expect"]
    assert set(DEFAULT_MOTIONS) == set(K)


@pytest.mark.parametrize("case", _by("progress"), ids=lambda c: c["name"])
def test_progress(case):
    i = case["input"]
    motion = PlateAnimationStyle().motion_for(PlatePartId(K(i["kind"])))
    tl = part_timeline(motion, PlatePartCue(PlatePartPhase.COMING_IN, i["cueDelayMs"]))
    assert tl.total == case["expect"]["totalMs"]
    assert [tl.progress(motion, at) for at in i["atMs"]] == pytest.approx(case["expect"]["progress"], abs=1e-9)


@pytest.mark.parametrize("case", [c for c in CASES if "spec" in c["input"]], ids=lambda c: c["name"])
def test_parts(case):
    spec, e = _specs(case["input"]["package"])[case["input"]["spec"]], case["expect"]
    ids = all_of(spec)
    assert [str(i) for i in ids] == e["allOf"]
    assert plate_region_count(spec.background) == e["regionCount"]
    assert plate_divider_count(spec.background) == e["dividerCount"]
    fwd, back = stagger_sequence(spec), stagger_sequence(spec, 25, True)
    assert [fwd[i] for i in ids] == e["stagger60"]
    assert [back[i] for i in ids] == e["stagger25Reverse"]
    style = PlateAnimationStyle()
    assert plate_cue_length(style, ids, {}) == e["cueLength"]
    assert plate_cue_length(style, ids, fwd) == e["cueLength60"]
    assert plate_cue_length(style, ids, back) == e["cueLength25Reverse"]


@pytest.mark.parametrize("case", _by("reveal"), ids=lambda c: c["name"])
def test_reveal(case):
    i, e = case["input"], case["expect"]
    frame = PlatePartFrame(PlatePartPhase(i["phase"]), i["progress"], PlateMotion())
    assert (frame.shown, frame.hidden, list(frame.span)) == (e["shown"], e["hidden"], e["span"])
    assert list(plate_reveal_rect(Rect(*i["bounds"]), tuple(i["origin"]), frame)) == pytest.approx(e["rect"])


@pytest.mark.parametrize("case", [c for c in CASES if "from" in c["input"]], ids=lambda c: c["name"])
def test_spec_transition(case):
    i, e = case["input"], case["expect"]
    specs = _specs(i["package"])
    frm, to = specs[i["from"]], specs[i["to"]]
    ids = {*all_of(frm), *all_of(to)}
    fv, tv = [None] * len(frm.slots), [None] * len(to.slots)
    kinds = PlateSpecTransition(keep_kinds=frozenset({K.PANEL, K.SLOT, K.BAND}))
    identical = PlateSpecTransition(keep_identical=True)
    assert {str(x) for x in ids if same_part(x, frm, to, fv, tv)} == set(e["samePart"])
    assert {str(x) for x in ids if identical.keeps(x, frm, to, fv, tv)} == set(e["keepIdentical"])
    assert {str(x) for x in ids if kinds.keeps(x, frm, to)} == set(e["keepPanelSlotBand"])


def test_controller():
    c = PlateAnimationController()
    seen = []
    c.cue_of(PlatePartId(K.SLOT, 0)).subscribe(lambda: seen.append("0"))
    c.cue_of(PlatePartId(K.SLOT, 1)).subscribe(lambda: seen.append("1"))
    c.come_in(PlatePartId(K.SLOT, 1), 30)
    assert seen == ["1"] and c.phase_of(PlatePartId(K.SLOT, 1)) is PlatePartPhase.COMING_IN
    c.go_out_all({PlatePartId(K.SLOT, 0): 60})
    assert sorted(seen) == ["0", "1", "1"]
    assert c.cue_of(PlatePartId(K.BORDER)).value.phase is PlatePartPhase.GOING_OUT
    c.hide(PlatePartId(K.SLOT, 0))
    assert c.cue_of(PlatePartId(K.SLOT, 0)).value.instant


def test_chain():
    f = PlatePartFrame(PlatePartPhase.COMING_IN, 0.5, PlateMotion(effect=DEFAULT_MOTIONS[K.DECAL].effect))
    assert plate_chain(f).opacity == 0.5
