from __future__ import annotations

from dataclasses import dataclass
from typing import NamedTuple

from ..model.plate_box import Rect
from .plate_animation import (
    Alignment, PlateMotion, PlatePartCue, PlatePartEffect, PlatePartPhase,
)

_P = PlatePartPhase


@dataclass(frozen=True)
class PlatePartFrame:
    """Where one part is right now; `progress` runs 0 to 1 across the transition, curve applied (D1)."""

    phase: PlatePartPhase
    progress: float
    motion: PlateMotion

    @property
    def shown(self) -> float:
        """How much of the part shows, 0 (gone) to 1 (as settled)."""
        match self.phase:
            case _P.SETTLED:
                return 1
            case _P.COMING_IN:
                return self.progress
            case _P.GOING_OUT:
                return 1 - self.progress

    @property
    def hidden(self) -> bool:
        return self.shown <= 0

    @property
    def span(self) -> tuple[float, float]:
        """The span of a directional effect along the run from its origin end."""
        t = self.progress
        match self.phase:
            case _P.SETTLED:
                return (0, 1)
            case _P.COMING_IN:
                return (0, t)
            case _P.GOING_OUT:
                return (t, 1)


PlatePartFrame.SETTLED = PlatePartFrame(_P.SETTLED, 1.0, PlateMotion())


def plate_reveal_rect(bounds: Rect, origin: Alignment, frame: PlatePartFrame) -> Rect:
    """The part of `bounds` a wipe from `origin` leaves visible; a centred axis grows from the middle."""
    a, b = frame.span
    if a <= 0 and b >= 1:
        return bounds
    centred = origin == (0, 0)

    def axis(o: float, lo: float, hi: float, start: bool) -> float:
        n = hi - lo
        if o == 0:
            if not centred:
                return lo if start else hi
            return lo + n * ((1 - (b - a)) / 2 if start else (1 + (b - a)) / 2)
        f0, f1 = (a, b) if o < 0 else (1 - b, 1 - a)
        return lo + n * (f0 if start else f1)

    left, right = axis(origin[0], bounds.left, bounds.right, True), axis(origin[0], bounds.left, bounds.right, False)
    top, bottom = axis(origin[1], bounds.top, bounds.bottom, True), axis(origin[1], bounds.top, bounds.bottom, False)
    return Rect(left, top, right - left, bottom - top)


class PartTimeline(NamedTuple):
    """One cue under one motion: a linear clock of `total` ms whose curve starts after the delay [H11]."""

    total: int
    start: float

    def progress(self, motion: PlateMotion, at: float) -> float:
        """Flutter's `Interval(start, 1, curve)` at `at` ms; `at` is clamped to the run."""
        t = min(max(at / self.total, 0.0), 1.0) if self.total else 1.0
        t = min(max((t - self.start) / (1 - self.start), 0.0), 1.0) if self.start < 1 else float(t >= 1)
        return t if t in (0.0, 1.0) else motion.curve.transform(t)


def part_timeline(motion: PlateMotion, cue: PlatePartCue) -> PartTimeline:
    wait = motion.delay + cue.delay
    total = wait + motion.duration
    return PartTimeline(total, wait / total if total else 0.0)


class PlateChain(NamedTuple):
    """What one phase asks of the painter, per frame: opacity, translate and scale, clip origin."""

    opacity: float
    slide: tuple[float, float] = (0.0, 0.0)
    scale: float = 1.0
    scale_origin: Alignment = (0.0, 0.0)
    clip_origin: Alignment | None = None


def plate_chain(frame: PlatePartFrame) -> PlateChain:
    """The transition table: fade=opacity, wipe/draw=clip+gate, fadeScale=scale 0.4 to 1, fadeSlide=0.6 of the size."""
    if frame.phase is _P.SETTLED:
        return PlateChain(1.0)
    shown, (ox, oy) = frame.shown, frame.motion.origin
    match frame.motion.effect:
        case PlatePartEffect.FADE:
            return PlateChain(shown)
        case PlatePartEffect.WIPE | PlatePartEffect.DRAW:
            return PlateChain(0.0 if shown <= 0 else 1.0, clip_origin=(ox, oy))
        case PlatePartEffect.FADE_SCALE:
            return PlateChain(shown, scale=0.4 + 0.6 * shown, scale_origin=(ox, oy))
        case PlatePartEffect.FADE_SLIDE:
            return PlateChain(shown, slide=(ox * 0.6 * (1 - shown), oy * 0.6 * (1 - shown)))
