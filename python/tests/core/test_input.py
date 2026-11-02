import json
from functools import lru_cache
from pathlib import Path

import pytest

from plates.core.input.plate_controller import PlateController, PlateValuePreservation
from plates.core.input.plate_input_machine import PlateInputMachine
from plates.core.model.plate_alphabet import AlphabetInput, PlateAlphabet, TextDirection
from plates.core.model.plate_box import PlateBox
from plates.core.model.plate_country import PlateCountry
from plates.core.model.plate_input_source import PlateInputSource
from plates.core.model.plate_restriction import PlateRestriction
from plates.core.model.plate_spec import PlateMirror, PlateSlot, PlateSpec, PlateTextGroup
from plates.core.validators.plate_validator import PlateEntry, restriction_verdict
from tests.vectors import load_vectors

DATA = Path(__file__).resolve().parents[3] / "data"
SESSIONS = [c for c in load_vectors("core/input.json") if not c["name"].startswith("behavior ")]


@lru_cache(None)
def _package(pkg: str) -> dict:
    return json.loads((DATA / "countries" / f"{pkg}.json").read_text(encoding="utf8"))


@lru_cache(None)
def _alphabets() -> dict:
    return json.loads((DATA / "alphabets.json").read_text(encoding="utf8"))["alphabets"]


def _alphabet(pkg: str, ref: str) -> PlateAlphabet:
    a = _alphabets()[ref]
    return PlateAlphabet.of(
        a["id"], a["characters"], AlphabetInput(a["input"]), a["isNumeric"],
        glyphs=dict(a["glyphs"]), direction=TextDirection(a["direction"]), placeholder=a["placeholder"],
    )


@lru_cache(None)
def spec(pkg: str, id: str) -> PlateSpec:
    """Just the parts the controller reads; geometry is a dummy box."""
    s = next(s for s in _package(pkg)["specs"] if s["id"] == id)
    box = PlateBox(0, 0, 1, 1)
    return PlateSpec(
        id=id, country=PlateCountry("xx", (), 0, None), canvas_width=1, canvas_height=1, panel=None,
        slots=tuple(PlateSlot(_alphabet(pkg, x["alphabet"]), box, length=x["length"], min_length=x["minLength"])
                    for x in s["slots"]),
        mirrors=tuple(PlateMirror(m["source"], box, 1, _alphabet(pkg, m["alphabet"]) if m["alphabet"] else None,
                                  m["editable"]) for m in s["mirrors"]),
        text_groups=tuple(PlateTextGroup(tuple(g["indices"]), g["prefix"], g["key"]) for g in s["textGroups"]),
        restrictions=tuple(PlateRestriction(r["group"], tuple(r["values"]), r["reason"]) for r in s["restrictions"]),
    )


def _has_region(pkg: str, id: str) -> bool:
    return next(s for s in _package(pkg)["specs"] if s["id"] == id)["resolveRegion"] is not None


@pytest.mark.parametrize("case", SESSIONS, ids=lambda c: c["name"])
def test_session(case):
    """Drives the controller through a machine as the canvas wires it (FORMAT.md, input.json).
    Country validators and region resolvers are not ported yet: their verdicts are
    checked only where the restriction verdict decides them."""
    i, e = case["input"], case["expect"]
    pkg, start = i["package"], spec(i["package"], i["spec"])
    source = PlateInputSource(i["source"])
    c = PlateController(start, i["values"])
    sheet = [None]
    m = [None]

    def mount(s: PlateSpec):
        if m[0] is not None:
            c.detach(m[0])
        machine = m[0] = PlateInputMachine(s, lambda: c.values, c.set_at, source,
                                           lambda _: c.notify_active_slot_changed())
        machine.on_sheet_requested = lambda j: sheet.__setitem__(0, j)
        c.attach(machine)
        c.install_validation(lambda: restriction_verdict(PlateEntry(c.spec, c.values, machine.active_index)))

    def check(want: dict):
        state = {
            "values": c.values, "isCompleted": c.is_completed, "isEmpty": c.is_empty,
            "rejection": c.rejection.value.reason if c.rejection.value else None,
            "text": c.text(), "textJoined": c.text(sep=""), "active": c.active_index, "systemKeyboard": False,
        }
        for k, v in state.items():
            assert v == want[k], k
        if not _has_region(pkg, c.spec.id):
            assert c.region_caption == want["regionCaption"]
        v = c.validation
        if want["validation"] and not want["validation"]["valid"] and v and not v.is_valid:
            assert v.reason == want["validation"]["reason"]
        elif i["validator"] is None or c.spec != start:
            assert (None if v is None or v.is_valid and want["validation"] is None else
                    {"valid": v.is_valid, "reason": v.reason}) == (
                       None if want["validation"] is None or want["validation"]["valid"] and v is None
                       else want["validation"])

    mount(start)
    check(e["initial"])
    for step in e["steps"]:
        op = step["op"]
        fired: dict[str, int] = {}

        def on(o, k):
            o.subscribe(lambda: fired.__setitem__(k, fired.get(k, 0) + 1))

        on(c, "whole")
        on(c.completed, "completed")
        on(c.rejection, "rejection")
        for j in range(c.spec.slot_count):
            on(c.slot(j), f"slot {j}")
        sheet[0] = None
        result, threw = None, None
        try:
            match op["op"]:
                case "submit": c.submit(op["char"])
                case "clear": result = c.clear()
                case "focusSlot": c.focus_slot(op["index"])
                case "backspace": c.backspace()
                case "focusFirstEmpty": c.focus_first_empty()
                case "setAt": result = c.set_at(op["index"], op["value"])
                case "setGroup": result = c.set_group(op["key"], op["value"])
                case "setValues": result = c.set_values(op["values"])
                case "adoptSpec":
                    to = spec(pkg, op["spec"])
                    c.adopt_spec(to, PlateValuePreservation(op["preserve"]))
                    mount(to)
        except IndexError:
            threw = "RangeError"
        # Fresh listeners per op, as the vectors count.
        for o in [c, c.completed, c.rejection, *(c.slot(j) for j in range(c.spec.slot_count))]:
            o._listeners.clear()
        assert (result, threw, sheet[0], fired) == (step["result"], step["throws"], step["sheet"], step["notified"]), op
        check(step["state"])


def test_from_text_skips_separators():
    s = spec("albania_plate", "al.private")
    assert PlateController.from_text(s, "vb-226 ab").values == ["VB", "226", "AB"]


def test_slot_out_of_range_stays_none():
    c = PlateController(spec("albania_plate", "al.private"))
    assert c.slot(99).value is None
