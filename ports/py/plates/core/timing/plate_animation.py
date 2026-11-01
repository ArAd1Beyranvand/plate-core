from __future__ import annotations

import math
from dataclasses import dataclass, field, replace
from enum import Enum
from typing import Callable, Iterable

from ..input.observable import Notifier, Observable
from ..model.plate_box import PlateBox, Rect
from ..model.plate_spec import PlateSection, PlateSpec, layout


class PlatePartPhase(Enum):
    COMING_IN = "comingIn"
    SETTLED = "settled"
    GOING_OUT = "goingOut"


class PlatePartKind(Enum):
    BACKGROUND = "background"
    CORNER = "corner"
    REGION = "region"
    DIVIDER = "divider"
    BORDER_WIDTH = "borderWidth"
    BORDER_COLOR = "borderColor"
    BORDER = "border"
    PANEL = "panel"
    FLAG = "flag"
    CAPTION = "caption"
    BAND = "band"
    BAND_CORNER = "bandCorner"
    RULE = "rule"
    LABEL = "label"
    DECAL = "decal"
    SLOT = "slot"
    MIRROR = "mirror"


_K = PlatePartKind
_SINGLE = {_K.BACKGROUND, _K.CORNER, _K.BORDER_WIDTH, _K.BORDER_COLOR, _K.BORDER, _K.PANEL, _K.FLAG, _K.CAPTION}


@dataclass(frozen=True)
class PlatePartId:
    """A stable address for one part of a plate: its kind and its index in the spec's own list."""

    kind: PlatePartKind
    index: int = 0

    def __str__(self) -> str:
        return self.kind.value if self.kind in _SINGLE else f"{self.kind.value} {self.index}"


def all_of(spec: PlateSpec) -> list[PlatePartId]:
    """Every part `spec` renders, in painting order."""
    def of(kind, n=1):
        return [PlatePartId(kind, i) for i in range(n)]
    return [
        *of(_K.BACKGROUND), *of(_K.CORNER),
        *of(_K.REGION, plate_region_count(spec.background)),
        *of(_K.DIVIDER, plate_divider_count(spec.background)),
        *of(_K.BORDER_WIDTH), *of(_K.BORDER_COLOR), *of(_K.BORDER),
        *(of(_K.PANEL) + of(_K.FLAG) + of(_K.CAPTION) if spec.panel is not None else []),
        *of(_K.BAND, len(spec.bands)), *of(_K.BAND_CORNER, len(spec.bands)),
        *of(_K.RULE, len(spec.rules)), *of(_K.LABEL, len(spec.labels)),
        *of(_K.DECAL, len(spec.decals)), *of(_K.MIRROR, len(spec.mirrors)),
        *of(_K.SLOT, len(spec.slots)),
    ]


def plate_region_count(section: PlateSection) -> int:
    return len(layout(section, Rect(0, 0, 0, 0)).leaves)


def plate_divider_count(section: PlateSection) -> int:
    return len(layout(section, Rect(0, 0, 0, 0)).dividers)


class PlatePartEffect(Enum):
    FADE = "fade"
    WIPE = "wipe"
    FADE_SCALE = "fadeScale"
    FADE_SLIDE = "fadeSlide"
    DRAW = "draw"


@dataclass(frozen=True)
class Curve:
    """A Flutter curve. `bezier` is the (x1, y1, x2, y2) of a cubic, for QEasingCurve.BezierSpline."""

    name: str
    bezier: tuple[float, float, float, float] | None = None

    def transform(self, t: float) -> float:
        if t == 0 or t == 1:
            return t
        if self.bezier is not None:
            a, b, c, d = self.bezier
            lo, hi = 0.0, 1.0
            while True:
                mid = (lo + hi) / 2
                est = _bezier(a, c, mid)
                if abs(t - est) < 0.001:
                    return _bezier(b, d, mid)
                lo, hi = (mid, hi) if est < t else (lo, mid)
        if self.name == "elasticOut":
            return 2 ** (-10 * t) * math.sin((t - 0.1) * (2 * math.pi) / 0.4) + 1
        return t


def _bezier(a: float, b: float, m: float) -> float:
    return 3 * a * (1 - m) ** 2 * m + 3 * b * (1 - m) * m ** 2 + m ** 3


CURVES = {c.name: c for c in (
    Curve("linear"),
    Curve("ease", (0.25, 0.1, 0.25, 1.0)),
    Curve("easeInOut", (0.42, 0.0, 0.58, 1.0)),
    Curve("easeInOutCubic", (0.645, 0.045, 0.355, 1.0)),
    Curve("easeOut", (0.0, 0.0, 0.58, 1.0)),
    Curve("easeInCubic", (0.55, 0.055, 0.675, 0.19)),
    Curve("easeOutBack", (0.175, 0.885, 0.32, 1.275)),
    Curve("easeOutCubic", (0.215, 0.61, 0.355, 1.0)),
    Curve("elasticOut"),
)}

Alignment = tuple[float, float]
CENTER_LEFT, CENTER, TOP_CENTER, BOTTOM_CENTER = (-1.0, 0.0), (0.0, 0.0), (0.0, -1.0), (0.0, 1.0)


@dataclass(frozen=True)
class PlateMotion:
    """The timing and look of one part's transitions; times are int ms."""

    effect: PlatePartEffect = PlatePartEffect.FADE
    duration: int = 420
    curve: Curve = CURVES["easeInOutCubic"]
    delay: int = 0
    origin: Alignment = CENTER_LEFT
    start_point: float = 0
    clockwise: bool = True
    soft_edge: bool = False

    def copy_with(self, **changes) -> PlateMotion:
        return replace(self, **changes)


_E = PlatePartEffect
DEFAULT_MOTIONS: dict[PlatePartKind, PlateMotion] = {
    _K.BACKGROUND: PlateMotion(_E.WIPE, origin=CENTER),
    _K.REGION: PlateMotion(_E.WIPE),
    _K.DIVIDER: PlateMotion(_E.DRAW, origin=TOP_CENTER, soft_edge=True),
    _K.CORNER: PlateMotion(_E.FADE, duration=600),
    _K.BORDER_WIDTH: PlateMotion(_E.FADE, duration=600),
    _K.BORDER_COLOR: PlateMotion(_E.FADE, duration=600),
    _K.BORDER: PlateMotion(_E.DRAW, duration=900),
    _K.PANEL: PlateMotion(_E.WIPE),
    _K.FLAG: PlateMotion(_E.WIPE),
    _K.CAPTION: PlateMotion(_E.WIPE, origin=TOP_CENTER),
    _K.BAND: PlateMotion(_E.WIPE),
    _K.BAND_CORNER: PlateMotion(_E.FADE),
    _K.RULE: PlateMotion(_E.DRAW, origin=TOP_CENTER, soft_edge=True),
    _K.LABEL: PlateMotion(_E.WIPE),
    _K.DECAL: PlateMotion(_E.FADE_SCALE, origin=CENTER),
    _K.SLOT: PlateMotion(_E.FADE_SLIDE, origin=BOTTOM_CENTER),
    _K.MIRROR: PlateMotion(_E.FADE_SLIDE, origin=BOTTOM_CENTER),
}


@dataclass(frozen=True)
class PlateAnimationStyle:
    by_kind: dict[PlatePartKind, PlateMotion] = field(default_factory=lambda: DEFAULT_MOTIONS)
    overrides: dict[PlatePartId, PlateMotion] = field(default_factory=dict)

    def motion_for(self, id: PlatePartId) -> PlateMotion:
        return self.overrides.get(id) or self.by_kind.get(id.kind) or PlateMotion()


@dataclass(frozen=True)
class PlatePartCue:
    """Go to `phase` after `delay` ms; `serial` tells a repeated cue from a stale one."""

    phase: PlatePartPhase
    delay: int = 0
    serial: int = 0
    instant: bool = False


SETTLED_CUE = PlatePartCue(PlatePartPhase.SETTLED)


class PlateAnimationController(Notifier):
    """Drives the phases of a plate's parts; each part subscribes to its own cue only (D7)."""

    def __init__(self, style: PlateAnimationStyle | None = None):
        super().__init__()
        self._style = style or PlateAnimationStyle()
        self._cues: dict[PlatePartId, Observable[PlatePartCue]] = {}
        self._fallback = SETTLED_CUE
        self._serial = 0

    @property
    def style(self) -> PlateAnimationStyle:
        return self._style

    @style.setter
    def style(self, value: PlateAnimationStyle) -> None:
        if value is not self._style:
            self._style = value
            self.notify()

    def cue_of(self, id: PlatePartId) -> Observable[PlatePartCue]:
        return self._cues.setdefault(id, Observable(self._fallback))

    def phase_of(self, id: PlatePartId) -> PlatePartPhase:
        return (self._cues[id].value if id in self._cues else self._fallback).phase

    def _next(self) -> int:
        self._serial += 1
        return self._serial

    def cue(self, id: PlatePartId, phase: PlatePartPhase, delay: int = 0) -> None:
        self.cue_of(id).value = PlatePartCue(phase, delay, self._next())

    def come_in(self, id: PlatePartId, delay: int = 0) -> None:
        self.cue(id, PlatePartPhase.COMING_IN, delay)

    def go_out(self, id: PlatePartId, delay: int = 0) -> None:
        self.cue(id, PlatePartPhase.GOING_OUT, delay)

    def settle(self, id: PlatePartId) -> None:
        self.cue(id, PlatePartPhase.SETTLED)

    def hide(self, id: PlatePartId) -> None:
        self.cue_of(id).value = PlatePartCue(PlatePartPhase.GOING_OUT, 0, self._next(), True)

    def cue_all(self, phase: PlatePartPhase, delays: dict[PlatePartId, int] | None = None) -> None:
        """Cues every part, mounted or not yet, to `phase`; see `stagger_sequence`."""
        delays = delays or {}
        serial = self._next()
        self._fallback = PlatePartCue(phase, 0, serial)
        for id in {*self._cues, *delays}:
            self.cue_of(id).value = PlatePartCue(phase, delays.get(id, 0), serial)

    def come_in_all(self, delays: dict[PlatePartId, int] | None = None) -> None:
        self.cue_all(PlatePartPhase.COMING_IN, delays)

    def go_out_all(self, delays: dict[PlatePartId, int] | None = None) -> None:
        self.cue_all(PlatePartPhase.GOING_OUT, delays)

    def settle_all(self) -> None:
        self.cue_all(PlatePartPhase.SETTLED)


def stagger_sequence(spec: PlateSpec, step: int = 60, reverse: bool = False) -> dict[PlatePartId, int]:
    """Each part `step` ms after the one before, in painting order; `reverse` for taking a plate apart."""
    ids = all_of(spec)
    return {id: step * i for i, id in enumerate(reversed(ids) if reverse else ids)}


def plate_cue_length(style: PlateAnimationStyle, ids: Iterable[PlatePartId], delays: dict[PlatePartId, int]) -> int:
    """How long a `cue_all` with `delays` runs under `style`, in ms."""
    longest = 0
    for id in ids:
        m = style.motion_for(id)
        longest = max(longest, delays.get(id, 0) + m.delay + m.duration)
    return longest


KeepFn = Callable[[PlatePartId, PlateSpec, PlateSpec], "bool | None"]


@dataclass(frozen=True)
class PlateSpecTransition:
    """What a canvas does when its spec changes: parts it keeps swap in place, the rest go out and in."""

    keep_kinds: frozenset[PlatePartKind] = frozenset()
    keep: KeepFn | None = None
    keep_identical: bool = False
    morph_background: bool = False
    step: int = 60

    def keeps(self, id: PlatePartId, frm: PlateSpec, to: PlateSpec,
              from_values: list[str | None] | None = None, to_values: list[str | None] | None = None) -> bool:
        if id.kind is _K.BAND_CORNER:
            return self.keeps(PlatePartId(_K.BAND, id.index), frm, to, from_values, to_values)
        decided = self.keep(id, frm, to) if self.keep else None
        if decided is not None:
            return decided
        if self.keep_identical and same_part(id, frm, to, from_values, to_values):
            return True
        return id.kind in self.keep_kinds and id in all_of(frm) and id in all_of(to)


def _layout(spec: PlateSpec) -> tuple[list, list]:
    out = layout(spec.background, Rect(0, 0, spec.canvas_width, spec.canvas_height))
    return out.leaves, out.dividers


def _same_box(a: PlateBox, b: PlateBox) -> bool:
    return a == b


def _at(items, i):
    return items[i] if i < len(items) else None


def same_part(id: PlatePartId, frm: PlateSpec, to: PlateSpec,
              from_values: list[str | None] | None = None, to_values: list[str | None] | None = None) -> bool:
    """True when `frm` and `to` would paint `id` identically, as far as the specs say [H1]."""
    if (frm.canvas_width, frm.canvas_height) != (to.canvas_width, to.canvas_height):
        return False
    i = id.index
    match id.kind:
        case _K.PANEL | _K.FLAG | _K.CAPTION:
            a, b = frm.panel, to.panel
            return (a is not None and b is not None and frm.country == to.country
                    and frm.country.panel_color == to.country.panel_color
                    and a == b)
        case _K.REGION:
            a, b = _at(_layout(frm)[0], i), _at(_layout(to)[0], i)
            if a is None or b is None:
                return False
            (la, ra), (lb, rb) = a, b
            return (ra == rb and la.shape == lb.shape and la.fill == lb.fill
                    and (not la.paints_panel() or frm.country.panel_color == to.country.panel_color))
        case _K.DIVIDER:
            a, b = _at(_layout(frm)[1], i), _at(_layout(to)[1], i)
            return a is not None and a == b and frm.ink_override == to.ink_override
        case _K.SLOT:
            if from_values is None or to_values is None:
                return False
            a, b = _at(frm.slots, i), _at(to.slots, i)
            if a is None or b is None or i >= len(from_values) or i >= len(to_values):
                return False
            return ((from_values[i] or "") == (to_values[i] or "") and a.box == b.box and a.color == b.color
                    and frm.ink_override == to.ink_override)
        case _K.BAND:
            a, b = _at(frm.bands, i), _at(to.bands, i)
            return a is not None and a == b
        case _K.RULE:
            a, b = _at(frm.rules, i), _at(to.rules, i)
            return a is not None and b is not None and a.box == b.box and frm.ink_override == to.ink_override
        case _K.LABEL:
            a, b = _at(frm.labels, i), _at(to.labels, i)
            return a is not None and b is not None and (
                (a.box, a.text, a.glyph_height, a.color, a.rotated, a.line_height, a.font_family, a.font_package)
                == (b.box, b.text, b.glyph_height, b.color, b.rotated, b.line_height, b.font_family, b.font_package))
    return False
