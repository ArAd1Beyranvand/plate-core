from __future__ import annotations

import unicodedata

from ..core.model.plate_alphabet import TextDirection
from ..core.model.plate_box import Rect
from .display_list import DisplayList
from .text_measure import measure_text

GLYPH_ENTER_MS = 260
GLYPH_LEAVE_MS = 180


def glyph_units(text: str, direction: TextDirection) -> list[str]:
    """[H7] The units a run animates: graphemes left to right;
    a right-to-left run stays whole so it keeps its shaping."""
    if not text:
        return []
    if direction is TextDirection.RTL:
        return [text]
    out: list[str] = []
    for ch in text:
        # Marks, joiners and variation selectors extend the grapheme before them; so does whatever
        # follows ZWJ, and a consonant after a virama (an Indic conjunct, GB9c).
        if out and (unicodedata.category(ch).startswith("M") or ch in "\u200c\u200d"
                    or "\ufe00" <= ch <= "\ufe0f" or out[-1][-1] == "\u200d"
                    or unicodedata.combining(out[-1][-1]) == 9 and unicodedata.category(ch) == "Lo"):
            out[-1] += ch
        else:
            out.append(ch)
    return out


def paint_glyph_run(c: DisplayList, text: str, box: Rect, style: dict, direction: TextDirection) -> None:
    """[H12] PlateGlyphRun settled: one text op per unit along `box` from its start edge,
    scaled down to fit and centred vertically at line height 1."""
    units = glyph_units(text, direction)
    if not units:
        return
    widths = [measure_text(u, style) for u in units]
    total = sum(widths)
    k = min(1, box.width / total, box.height / style["fontSize"])
    ltr = direction is TextDirection.LTR
    c.save()
    c.translate(box.left + (box.width - total * k) / 2, box.top + (box.height - style["fontSize"] * k) / 2)
    c.scale(k)
    x = 0 if ltr else total
    for unit, w in zip(units, widths):
        if not ltr:
            x -= w
        c.text(text=unit, box=[x, 0, w, style["fontSize"]], align="start", direction=direction.value, **style)
        if ltr:
            x += w
    c.restore()
