"""[D1][D7] The headless half of the browser plate (ts/src/ui/plate_canvas.ts): core state in, display
list out. Painting is ops_to_svg; native inputs go at slot_inputs(); plates.ui.dom binds both to a page."""
from __future__ import annotations

from typing import Callable, Generic, NamedTuple, TypeVar

from ..core.input.plate_controller import PlateController
from ..core.model.plate_box import Rect
from ..core.model.plate_country import PlateCountry
from ..core.model.plate_input_source import PlateInputSource
from ..core.model.slot_behavior import PlateMode, SlotBehavior, resolve_slot_behavior
from ..core.theme.plate_theme import PlateTheme
from ..core.input.observable import Observable
from ..core.timing.plate_animation import PlateAnimationController, PlatePartCue, PlatePartId, PlatePartPhase
from ..core.timing.plate_part_animator import PlatePartFrame, part_timeline
from ..render.plate_canvas import render_plate
from ..render.plate_frame import Frames
from ..render.text_measure import measure_text
from .svg import AssetResolver, ops_to_svg


T = TypeVar("T")
Clock = Callable[[], float]
Schedule = Callable[[Callable[[], None]], None]


class PlateAnimator:
    """[H11] Turns cues into frames at a clock (ms); the UI ticks it through `schedule`
    (requestAnimationFrame in the browser) until every part has run its timeline."""

    def __init__(self, animation: PlateAnimationController, clock: Clock, schedule: Schedule,
                 on_frame: Callable[[], None]):
        self.animation, self.clock, self.schedule, self.on_frame = animation, clock, schedule, on_frame
        self._started: dict[PlatePartId, tuple[PlatePartCue, float]] = {}
        self._ticking = False
        self._watched: dict[PlatePartId, Callable[[], None]] = {}

    def frame(self, id: PlatePartId) -> PlatePartFrame:
        motion = self.animation.style.motion_for(id)
        cues = self.animation.cue_of(id)
        if id not in self._watched:
            self._watched[id] = cues.subscribe(self._kick)
        cue = cues.value
        if cue.phase is PlatePartPhase.SETTLED or cue.instant:
            return PlatePartFrame(cue.phase, 1.0, motion)
        seen = self._started.get(id)
        if seen is None or seen[0] is not cue:
            seen = self._started[id] = (cue, self.clock())
            self._kick()
        line = part_timeline(motion, cue)
        at = self.clock() - seen[1]
        if at < line.total:
            self._kick()
        return PlatePartFrame(cue.phase, line.progress(motion, at), motion)

    def _kick(self) -> None:
        if not self._ticking:
            self._ticking = True
            self.schedule(self._tick)

    def _tick(self) -> None:
        self._ticking = False
        self.on_frame()

    def dispose(self) -> None:
        for id, fn in self._watched.items():
            self.animation.cue_of(id).unsubscribe(fn)
        self._watched.clear()


class SlotInput(NamedTuple):
    """Where the UI places a native input over the painted plate [D2]. `box` is in spec units."""

    index: int
    behavior: SlotBehavior
    box: Rect
    font_size: float = 0
    letter_spacing: float = 0


def fitted_style(slot, theme: PlateTheme) -> tuple[float, float]:
    """[H12] (font size, letter spacing) shrunk so the widest full-length run fits the slot."""
    base = theme.glyph_style(slot.box.rect.height, slot.color or theme.ink, slot.spacing)
    a = slot.alphabet
    style = {"fontSize": base.pixel_size, "letterSpacing": slot.spacing}
    widest = max((measure_text(a.render(c) * slot.length, style) for c in a.characters), default=0)
    available = slot.box.rect.width - slot.spacing - 4
    if widest <= available or widest == 0:
        return base.pixel_size, slot.spacing
    k = available / widest
    return base.pixel_size * k, slot.spacing * k


class PlateCanvas:
    """A host controller is adopted and never disposed here. `on_render` gets each new display list."""

    def __init__(self, controller: PlateController, theme: PlateTheme | None = None,
                 country: PlateCountry | None = None, mode: PlateMode = PlateMode.INPUT,
                 input_source: PlateInputSource = PlateInputSource.HARDWARE_KEYBOARD,
                 frames: Frames | None = None, on_render: Callable[[list[dict]], None] | None = None,
                 animation: PlateAnimationController | None = None, clock: Clock | None = None,
                 schedule: Schedule | None = None):
        self.controller, self.theme, self.country = controller, theme, country
        self.mode, self.input_source, self.frames, self.on_render = mode, input_source, frames, on_render
        self.animator = None
        if animation is not None and clock and schedule:
            self.animator = PlateAnimator(animation, clock, schedule, self._changed)
            self.frames = self.animator.frame
            animation.subscribe(self._changed)
        controller.subscribe(self._changed)
        controller.rejection.subscribe(self._changed)

    @property
    def spec(self):
        return self.controller.spec

    def display_list(self) -> list[dict]:
        c = self.controller
        return render_plate(c.spec, c.values, self.theme, self.country, self.frames, self.mode,
                            self.input_source, c.is_completed, c.rejection.value)

    def slot_inputs(self) -> list[SlotInput]:
        """In input mode, the slots the display list leaves for native inputs."""
        if self.mode is not PlateMode.INPUT:
            return []
        out = []
        for i, s in enumerate(self.spec.slots):
            b = resolve_slot_behavior(self.mode, s.alphabet.input, self.input_source)
            if b is not SlotBehavior.GLYPH:
                out.append(SlotInput(i, b, s.box.rect, *fitted_style(s, self.theme or PlateTheme.standard())))
        return out

    def svg(self, resolve_asset: AssetResolver | None = None) -> str:
        w, h = self.spec.canvas_width, self.spec.canvas_height
        body = ops_to_svg(self.display_list(), resolve_asset) if resolve_asset else ops_to_svg(self.display_list())
        return f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w:g} {h:g}">{body}</svg>'

    def _changed(self, *_) -> None:
        if self.on_render:
            self.on_render(self.display_list())

    def dispose(self) -> None:
        self.controller.unsubscribe(self._changed)
        self.controller.rejection.unsubscribe(self._changed)
        if self.animator:
            self.animator.animation.unsubscribe(self._changed)
            self.animator.dispose()


class PlateView(PlateCanvas):
    """[D1] The same canvas, editing off."""

    def __init__(self, controller: PlateController, theme: PlateTheme | None = None,
                 country: PlateCountry | None = None, frames: Frames | None = None, on_render=None):
        super().__init__(controller, theme, country, PlateMode.DISPLAY, frames=frames, on_render=on_render)


class PlateTextView:
    """The plate as text, or `empty_plate` while nothing is typed."""

    def __init__(self, controller: PlateController, empty_plate: str = ""):
        self.controller, self.empty_plate = controller, empty_plate

    def text(self) -> str:
        return self.empty_plate if self.controller.is_empty else self.controller.text()


class PlateSelector(Generic[T]):
    """[D7] `selector(controller)` as an observable that notifies only when the result changes."""

    def __init__(self, controller: PlateController, selector: Callable[[PlateController], T]):
        self.controller, self.selector = controller, selector
        self.value = Observable(selector(controller))
        controller.subscribe(self._changed)

    def _changed(self, *_) -> None:
        self.value.value = self.selector(self.controller)

    def dispose(self) -> None:
        self.controller.unsubscribe(self._changed)
