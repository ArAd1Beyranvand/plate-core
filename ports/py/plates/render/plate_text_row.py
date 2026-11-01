from __future__ import annotations

import math

from ..core.model.plate_alphabet import TextDirection
from ..core.model.plate_box import Rect
from .display_list import DisplayList
from .text_measure import measure_text

STAGGER_CHAR_MS = 220
STAGGER_STEP_MS = 55


def stagger_alphas(text: str, ms: float) -> list[float]:
    """[H24] The alpha of each UTF-16 unit of incoming wording `ms` into its stagger, indexed like
    Dart's String so a surrogate pair takes two steps."""
    n = len(text.encode("utf-16-le")) // 2
    return [min(1, max(0, (ms - i * STAGGER_STEP_MS) / STAGGER_CHAR_MS)) for i in range(n)]


def paint_text_line(c: DisplayList, text: str, box: Rect, style: dict, direction: TextDirection,
                    rotated: bool = False, align: str = "center") -> None:
    """[D1] A label or other centred line of fixed text in `box`: scaled down to fit, never up;
    `rotated` reads bottom to top."""
    if not text:
        return
    w, h = measure_text(text, style), style["fontSize"] * style["height"]
    fw, fh = (h, w) if rotated else (w, h)
    k = min(1, box.width / fw, box.height / fh)
    c.save()
    c.translate(box.left + box.width / 2, box.top + box.height / 2)
    c.scale(k)
    if rotated:
        c.rotate(-math.pi / 2)
    c.text(text=text, box=[-w / 2, -h / 2, w, h], align=align, direction=direction.value, **style)
    c.restore()
