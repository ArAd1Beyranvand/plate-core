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
from ..core.timing.plate_animation import CURVES, PlateAnimationController, PlatePartCue, PlatePartId, PlatePartPhase
from ..core.timing.plate_part_animator import PlatePartFrame, part_timeline
from ..render.plate_canvas import lerp_theme, plate_theme, render_plate
from ..render.plate_frame import Frames
from ..render.plate_text_row import StaggeredText
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


_LIVERY = ("plate_background", "plate_border", "ink", "divider_color", "active_color", "inactive_color")
LIVERY_MS = 350  # [H15] a livery change cross-fades this long when the spec resolves its theme from the values


class _Tween(NamedTuple):
    start: PlateTheme
    end: PlateTheme
    at: float
    ms: float


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
                 schedule: Schedule | None = None, active_index: int | None = None,
                 size_of: Callable[[], tuple[float, float]] | None = None):
        self.controller, self.theme, self.country = controller, theme, country
        self.active_index, self.clock, self.schedule = active_index, clock, schedule
        self._tween: _Tween | None = None
        self._morph: tuple[PlateTheme, float] | None = None
        # The size to draw at, when another canvas owns it (a spec swap's ghost).
        self._size_of = size_of
        self._resize: tuple[tuple[float, float], float, float] | None = None
        self._fading = False
        self._labels: dict[int, StaggeredText] = {}
        self._label_wake = False
        self.mode, self.input_source, self.frames, self.on_render = mode, input_source, frames, on_render
        self.animator = None
        if animation is not None and clock and schedule:
            self.animator = PlateAnimator(animation, clock, schedule, self._changed)
            self.frames = self.animator.frame
            animation.subscribe(self._changed)
        controller.subscribe(self._changed)
        controller.rejection.subscribe(self._changed)
        controller.hints.subscribe(self._changed)

    @property
    def spec(self):
        return self.controller.spec

    def morph_from(self, start: PlateTheme, size: tuple[float, float], ms: float) -> None:
        """The face starts as `start` at `size` and tweens to its own colours and size over `ms`: the frame
        stretches to the size between, the content contain-fits in it. Restarts the face's tween if it rendered already."""
        self._morph = (start, ms)
        self._tween = None
        self._resize = (size, self.clock() if self.clock else 0, ms)

    def size(self) -> tuple[float, float]:
        """The size the plate is drawn at now, in spec units."""
        w, h = self.spec.canvas_width, self.spec.canvas_height
        r = self._resize
        if r is None or not self.clock or r[2] <= 0 or self.clock() - r[1] >= r[2]:
            return w, h
        k = CURVES["easeInOut"].transform((self.clock() - r[1]) / r[2])
        return r[0][0] + (w - r[0][0]) * k, r[0][1] + (h - r[0][1]) * k

    def _view_size(self) -> tuple[float, float]:
        return self._size_of() if self._size_of else self.size()

    def _theme(self) -> PlateTheme:
        """[H15] The resolved theme now: a change of livery fades from where the last one had got to."""
        c = self.controller
        target = plate_theme(c.spec, self.theme, c.values)
        if not (self.clock and self.schedule):
            return target
        now = self.clock()
        tw = self._tween
        if tw is None:
            self._tween = _Tween(*(self._morph[0], target, now, self._morph[1]) if self._morph else (target, target, now, 0))
        elif any(getattr(tw.end, k) != getattr(target, k) for k in _LIVERY):
            self._tween = _Tween(self._theme_at(now), target, now, LIVERY_MS if c.spec.resolve_theme else 0)
        resizing = self._resize is not None and now - self._resize[1] < self._resize[2]
        if (now - self._tween.at < self._tween.ms or resizing) and not self._fading:
            self._fading = True
            self.schedule(self._fade)
        return self._theme_at(now)

    def _theme_at(self, now: float) -> PlateTheme:
        tw = self._tween
        if tw.ms <= 0 or now - tw.at >= tw.ms:
            return tw.end
        return lerp_theme(tw.start, tw.end, CURVES["easeInOut"].transform((now - tw.at) / tw.ms))

    def _fade(self) -> None:
        self._fading = False
        self._changed()

    def _label_text(self, i: int, value: str) -> tuple[str, list[float] | None]:
        t = self._labels.setdefault(i, StaggeredText(value))
        if not (self.clock and self.schedule):
            return value, None
        out = t.frame(value, self.clock())
        if t.running and not self._label_wake:
            self._label_wake = True
            self.schedule(self._wake_labels)
        return out

    def _wake_labels(self) -> None:
        self._label_wake = False
        self._changed()

    def display_list(self) -> list[dict]:
        c = self.controller
        return render_plate(c.spec, c.values, self.theme, self.country, self.frames, self.mode,
                            self.input_source, c.is_completed, c.rejection.value, hint_at=c.hint_at,
                            active_index=self.active_index, resolved_theme=self._theme(), label_text=self._label_text,
                            size=self._view_size())

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
        ops = self.display_list()
        w, h = self._view_size()
        body = ops_to_svg(ops, resolve_asset) if resolve_asset else ops_to_svg(ops)
        return f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w:g} {h:g}">{body}</svg>'

    def _changed(self, *_) -> None:
        if self.on_render:
            self.on_render(self.display_list())

    def dispose(self) -> None:
        self.controller.unsubscribe(self._changed)
        self.controller.rejection.unsubscribe(self._changed)
        self.controller.hints.unsubscribe(self._changed)
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
