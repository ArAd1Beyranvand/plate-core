from __future__ import annotations

from ..core.model.plate_box import Rect
from ..core.timing.plate_animation import PlatePartEffect, PlatePartPhase
from ..core.timing.plate_part_animator import PlatePartFrame
from .display_list import DisplayList, RRect, ltrb, with_alpha

RAMP_STEPS = 3
_SWEEPS = (PlatePartEffect.WIPE, PlatePartEffect.DRAW)


def divider_spans(r: Rect, frame: PlatePartFrame, origin: str | None = None) -> list[tuple[Rect, float]]:
    """[D1] The rects a divider paints in `r` this frame with their alpha fraction: the shown span along
    its long axis, softened at the moving edge when the motion asks. `origin` is "start" or "end"."""
    if frame.hidden:
        return []
    motion = frame.motion
    if frame.phase is PlatePartPhase.SETTLED or motion.effect not in _SWEEPS:
        return [(r, frame.shown)]
    vertical = r.height > r.width
    from_end = (origin or ("end" if (motion.origin[1] if vertical else motion.origin[0]) > 0 else "start")) == "end"
    a, b = frame.span
    if from_end:
        a, b = 1 - b, 1 - a
    whole = a <= 0 and b >= 1
    lo, n = (r.top, r.height) if vertical else (r.left, r.width)

    def along(f0, f1):
        return (ltrb(r.left, lo + n * f0, r.right, lo + n * f1) if vertical
                else ltrb(lo + n * f0, r.top, lo + n * f1, r.bottom))

    moving = b if (frame.phase is PlatePartPhase.COMING_IN) != from_end else a
    ramp = min(max((r.width if vertical else r.height) * 3 / n, 0), b - a) if motion.soft_edge and not whole else 0
    if ramp <= 0:
        return [(along(a, b), 1)]
    toward_lo = moving == a
    out = [(along(a + ramp, b) if toward_lo else along(a, b - ramp), 1)]
    step = ramp / RAMP_STEPS
    for i in range(RAMP_STEPS):
        f = i * step
        out.append((along(a + ramp - f - step, a + ramp - f) if toward_lo
                    else along(b - ramp + f, b - ramp + f + step), (RAMP_STEPS - i) / (RAMP_STEPS + 1)))
    return out


def paint_divider(c: DisplayList, r: Rect | None, color: int, frame: PlatePartFrame, clip: RRect | None = None,
                  origin: str | None = None) -> None:
    """PlateDividerPainter: one divider line in `r`, clipped to `clip` when given."""
    if frame.hidden or r is None:
        return
    if clip:
        c.save()
        c.clip_rrect(clip)
    for rect, alpha in divider_spans(r, frame, origin):
        c.rect(rect, {"color": with_alpha(color, alpha)})
    if clip:
        c.restore()
