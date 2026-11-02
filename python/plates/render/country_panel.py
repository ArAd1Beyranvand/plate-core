from __future__ import annotations

from typing import NamedTuple

from ..core.model.plate_box import Rect
from ..core.model.plate_country import PlateCountry
from ..core.model.plate_spec import Axis, PlatePanel
from .display_list import DisplayList
from .plate_flag import paint_flag
from .plate_frame import shift_path
from .text_measure import measure_text

CAPTION_FONT_SIZE = 24


def flag_size(panel: PlatePanel, country: PlateCountry, inner_w: float, inner_h: float) -> tuple[float, float]:
    """The flag fills the cross axis by flag_scale, then shrinks to fit the main axis."""
    aspect = country.flag_aspect_ratio
    if panel.direction is Axis.HORIZONTAL:
        h = inner_h * panel.flag_scale
        w = h * aspect
        return (inner_w, inner_w / aspect) if w > inner_w else (w, h)
    w = inner_w * panel.flag_scale
    h = w / aspect
    return (inner_h * aspect, inner_h) if h > inner_h else (w, h)


class PanelWording(NamedTuple):
    """One band of wording: its lines, the box they scale down into, and which edge they hug."""

    lines: tuple[str, ...]
    box: Rect
    align_x: int


class PanelLayout(NamedTuple):
    """[D1] CountryPanel as plain rects in plate units."""

    block: Rect
    flag: Rect
    heading: PanelWording | None
    caption: PanelWording


def panel_layout(panel: PlatePanel, country: PlateCountry) -> PanelLayout:
    b = panel.box
    p = panel.padding or (b.height * 0.1,) * 4
    pl, pt, pr, pb = p
    inner_w, inner_h = b.width - pl - pr, b.height - pt - pb
    x0, y0 = b.left + pl, b.top + pt
    fw, fh = flag_size(panel, country, inner_w, inner_h)
    share = 0.5 if country.heading_lines else 1

    def heading(box):
        return PanelWording(country.heading_lines, box, -1) if share < 1 else None

    if panel.direction is Axis.HORIZONTAL:
        # Row(spaceBetween), children centred on the cross axis.
        slack = min(max(inner_w - fw, 0), inner_w) * share
        fx = x0 + (inner_w - fw) / 2 if share < 1 else x0
        return PanelLayout(b.rect, Rect(fx, y0 + (inner_h - fh) / 2, fw, fh), heading(Rect(x0, y0, slack, inner_h)),
                           PanelWording(country.caption_lines, Rect(x0 + inner_w - slack, y0, slack, inner_h), 1))
    # Column(stretch, spaceBetween), the flag centred across.
    slack = min(max(inner_h - fh, 0), inner_h) * share
    fy = y0 + slack if share < 1 else y0
    return PanelLayout(b.rect, Rect(x0 + (inner_w - fw) / 2, fy, fw, fh), heading(Rect(x0, y0, inner_w, slack)),
                       PanelWording(country.caption_lines, Rect(x0, y0 + inner_h - slack, inner_w, slack), -1))


def _paint_wording(c: DisplayList, w: PanelWording, color: int, caption_scale: float) -> None:
    """[H12] _PanelWording: lines at 24·caption_scale, scaled down (never up) to fit the box."""
    if not w.lines:
        return
    fs = CAPTION_FONT_SIZE * caption_scale
    style = {"fontSize": fs, "height": 1, "color": color, "fontFamily": "Roboto", "fontWeight": 800,
             "letterSpacing": 0.25}
    width = max(measure_text(l, style) for l in w.lines)
    height = fs * len(w.lines)
    k = min(1, w.box.width / width, w.box.height / height) if width > 0 and height > 0 else 0
    # A FittedBox with no room paints nothing.
    if not k > 0:
        return
    c.save()
    c.translate(w.box.left if w.align_x < 0 else w.box.right - width * k, w.box.top + (w.box.height - height * k) / 2)
    c.scale(k)
    for i, text in enumerate(w.lines):
        c.text(text=text, box=[0, i * fs, measure_text(text, style), fs], align="start", direction="ltr", **style)
    c.restore()


def paint_panel(c: DisplayList, panel: PlatePanel, country: PlateCountry, ink: int, paint_block: bool,
                flag: bool = True, caption: bool = True) -> None:
    """[D1] CountryPanel: the block (unless the background paints it), heading, flag, caption; cut by the shape."""
    l = panel_layout(panel, country)
    color = ink if country.panel_text_color is None else country.panel_text_color
    c.save()
    if panel.shape is not None:
        c.clip_path(shift_path(panel.shape, panel.box.left, panel.box.top))
    if paint_block and country.panel_color >> 24:
        c.save()
        c.translate(l.block.left, l.block.top)
        c.rect(Rect(0, 0, l.block.width, l.block.height), {"color": country.panel_color})
        c.restore()
    if l.heading and caption:
        _paint_wording(c, l.heading, color, panel.caption_scale)
    if flag:
        paint_flag(c, country.flag, l.flag, country.flag_border_color)
    if caption:
        _paint_wording(c, l.caption, color, panel.caption_scale)
    c.restore()
