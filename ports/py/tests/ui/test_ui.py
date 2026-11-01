from plates.core.input.plate_controller import PlateController
from plates.core.model.slot_behavior import PlateMode
from plates.ui.dom import DomPlate
from plates.ui.plate_canvas import PlateCanvas, PlateView
from tests.specs import spec_of


class _El:
    """Just enough of a DOM element for plates.ui.dom."""

    def __init__(self, tag):
        self.tag, self.children, self.listeners, self.value, self.innerHTML = tag, [], {}, "", ""
        self.style = type("Style", (), {})()

    def appendChild(self, c):
        self.children.append(c)

    def addEventListener(self, kind, fn):
        self.listeners[kind] = fn


class _Doc:
    def createElement(self, tag):
        return _El(tag)


def test_canvas_edits_through_the_controller():
    spec = spec_of("albania_plate", "al.private").spec
    controller = PlateController(spec)
    canvas = PlateCanvas(controller)
    assert [s.index for s in canvas.slot_inputs()] == [0, 1, 2]

    host = _El("div")
    plate = DomPlate(host, canvas, document=_Doc())
    controller.set_values(["AB", "123", "FG"])
    assert [plate.inputs[i].value for i in range(3)] == ["AB", "123", "FG"]
    plate.inputs[1].value = "45"
    plate.inputs[1].listeners["input"]()
    assert controller.values == ["AB", "45", "FG"]

    # The inputs stand in for the slot glyphs; the frame, panel and decals are painted.
    ops = canvas.display_list()
    assert [o["text"] for o in ops if o["op"] == "text"] == ["AL"]
    assert any(o["op"] == "drrect" for o in ops)
    assert plate.art.innerHTML.startswith("<svg") and "</svg>" in plate.art.innerHTML

    view = PlateView(controller)
    assert view.mode is PlateMode.DISPLAY and not view.slot_inputs()
    texts = [o["text"] for o in view.display_list() if o["op"] == "text"]
    assert texts == ["AL", "A", "B", "4", "5", "F", "G"]
    assert ">A</text>" in view.svg()
    plate.dispose()
    assert host.innerHTML == ""


def test_animator_runs_cues_on_the_clock():
    from plates.core.timing.plate_animation import PlateAnimationController, PlatePartPhase, all_of
    from plates.ui.plate_canvas import PlateSelector, PlateTextView

    spec = spec_of("albania_plate", "al.private").spec
    controller, animation = PlateController(spec), PlateAnimationController()
    now, ticks, painted = [0.0], [], []
    canvas = PlateCanvas(controller, mode=PlateMode.DISPLAY, on_render=painted.append,
                         animation=animation, clock=lambda: now[0], schedule=ticks.append)
    settled = canvas.display_list()
    animation.come_in_all()
    assert ticks, "a cue schedules a frame"
    ticks.pop()()
    part = all_of(spec)[0]
    assert canvas.frames(part).phase is PlatePartPhase.COMING_IN and canvas.frames(part).progress == 0
    now[0] = 10_000
    assert canvas.frames(part).progress == 1
    assert painted

    animation.settle_all()
    assert canvas.display_list() == settled

    text = PlateTextView(controller, empty_plate="—")
    seen = PlateSelector(controller, lambda c: c.is_completed)
    hits = []
    seen.value.subscribe(lambda: hits.append(seen.value.value))
    assert text.text() == "—"
    controller.set_values(["AB", "123", None])
    controller.set_values(["AB", "123", "FG"])
    assert text.text() != "—" and hits == [True]
    canvas.dispose(); seen.dispose()
