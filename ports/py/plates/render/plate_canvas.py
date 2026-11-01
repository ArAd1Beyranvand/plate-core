from __future__ import annotations

from ..core.model.plate_alphabet import TextDirection
from ..core.model.plate_asset import PlateDrawing
from ..core.model.plate_box import PlateBox, Rect
from ..core.model.plate_country import PlateCountry
from ..core.model.plate_input_source import PlateInputSource
from ..core.model.plate_restriction import PlateRestriction
from ..core.model.plate_spec import PlateSpec
from ..core.model.slot_behavior import PlateMode, SlotBehavior, resolve_slot_behavior
from ..core.theme.plate_theme import PlateTheme, _lerp_color
from ..core.timing.plate_animation import PlateAnimationStyle, PlatePartId, PlatePartKind, PlatePartPhase
from ..core.timing.plate_part_animator import PlatePartFrame
from .country_panel import paint_panel
from .display_list import DisplayList
from .plate_divider import paint_divider
from .plate_drawing_view import paint_drawing
from .plate_flag import asset_op
from .plate_frame import Frames, frame_geometry, paint_frame, rim_clip
from .plate_glyph_run import paint_glyph_run
from .plate_text_row import paint_text_line

_K = PlatePartKind
_COLOURS = ("plate_background", "plate_border", "ink", "divider_color", "active_color", "inactive_color")


def lerp_theme(a: PlateTheme, b: PlateTheme, t: float) -> PlateTheme:
    """[H15] _ThemeTween: the six colours the livery cross-fades; ratios and alert come from `b`."""
    return b.copy_with(**{k: _lerp_color(getattr(a, k), getattr(b, k), t) for k in _COLOURS})


def plate_theme(spec: PlateSpec, theme: PlateTheme | None, values: list[str | None]) -> PlateTheme:
    """[H4] The theme a plate paints with: the spec's overrides on `theme`, then its resolver over `values`."""
    base = theme or PlateTheme.standard()
    if spec.border_width_ratio_override is not None:
        base = base.copy_with(border_width_ratio=spec.border_width_ratio_override)
    ink = spec.ink_override
    if ink is not None:
        base = base.copy_with(ink=ink, plate_border=ink, divider_color=ink, active_color=ink)
    if spec.resolve_theme:
        base = spec.resolve_theme(base, lambda k: spec.value_of_group(k, values))
    return base


def settled_frames(style: PlateAnimationStyle | None = None) -> Frames:
    """Every part settled, as the vectors render."""
    style = style or PlateAnimationStyle()
    return lambda id: PlatePartFrame(PlatePartPhase.SETTLED, 1.0, style.motion_for(id))


def _clip_overflow(c: DisplayList, w: float, h: float, boxes: list[PlateBox]) -> None:
    """Flutter's Stack clips its children to itself only when one of them overflows it."""
    if any(b.left < 0 or b.top < 0 or b.right > w or b.bottom > h for b in boxes):
        c.clip_rect(Rect(0, 0, w, h))


def _style(g, height=1, family="Roboto", weight=700, spacing=0) -> dict:
    return {"fontSize": g.pixel_size, "height": height, "color": g.color, "fontFamily": family,
            "fontWeight": weight, "letterSpacing": spacing}


def render_plate(spec: PlateSpec, values: list[str | None], theme: PlateTheme | None = None,
                 country: PlateCountry | None = None, frames: Frames | None = None, mode: PlateMode | None = None,
                 input_source: PlateInputSource | None = None, is_completed: bool | None = None,
                 rejection: PlateRestriction | None = None, size: tuple[float, float] | None = None) -> list[dict]:
    """[D1] PlateCanvas as a display list in view units: the frame stretched to `size`, then the content
    (panel, bands, rules, labels, decals) and the inputs (mirrors, slots, the restriction banner),
    contain-fitted, each under the rim clip. `size` defaults to the canvas."""
    frames = frames or settled_frames()
    theme = plate_theme(spec, theme, values)
    country = country or spec.country
    w, h = spec.canvas_width, spec.canvas_height

    def shown(kind, i=0):
        return not frames(PlatePartId(kind, i)).hidden

    def group(k):
        return spec.value_of_group(k, values)

    if is_completed is None:
        is_completed = all(s.is_complete(values[i]) for i, s in enumerate(spec.slots))
    c = DisplayList()
    vw, vh = size or (w, h)
    k = min(vw / w, vh / h)

    def fit():
        c.translate((vw - w * k) / 2, (vh - h * k) / 2)
        c.scale(k)

    c.save()
    c.scale(vw / w, vh / h)
    paint_frame(c, theme, w, h, spec.background, country.panel_color, is_completed, frames)
    c.restore()
    rim = rim_clip(frame_geometry(theme, w, h, frames))

    c.save()
    fit()
    c.clip_rrect(rim)
    _clip_overflow(c, w, h, [*([spec.panel.box] if spec.panel else []), *(b.box for b in spec.bands),
                             *(r.box for r in spec.rules), *(l.box for l in spec.labels), *(d.box for d in spec.decals)])
    if spec.panel and shown(_K.PANEL):
        paint_panel(c, spec.panel, country, theme.ink, not spec.background.paints_panel(),
                    shown(_K.FLAG), shown(_K.CAPTION))
    for i, b in enumerate(spec.bands):
        if not shown(_K.BAND, i):
            continue
        t, bt = b.top_corner_radius or 0, b.bottom_corner_radius or 0
        if t == 0 and bt == 0:
            c.rect(b.box.rect, {"color": b.color})
        else:
            c.rrect([b.box.left, b.box.top, b.box.width, b.box.height, t, t, t, t, bt, bt, bt, bt], {"color": b.color})
    for i, r in enumerate(spec.rules):
        c.save()
        c.translate(r.box.left, r.box.top)
        paint_divider(c, Rect(0, 0, r.box.width, r.box.height), theme.divider_color, frames(PlatePartId(_K.RULE, i)))
        c.restore()
    for i, l in enumerate(spec.labels):
        if not shown(_K.LABEL, i):
            continue
        text = l.text
        if l.resolve:
            resolved = l.resolve(group)
            text = l.text if resolved is None else resolved
        family = f"packages/{l.font_package}/{l.font_family}" if l.font_package else (l.font_family or "Roboto")
        g = theme.glyph_style(l.glyph_height, theme.ink if l.color is None else l.color)
        style = _style(g, 1 if l.line_height is None else l.line_height, family)
        paint_text_line(c, text, l.box.rect, style, spec.text_direction, l.rotated)
    for i, d in enumerate(spec.decals):
        if not shown(_K.DECAL, i):
            continue
        if isinstance(d.drawing, PlateDrawing):
            c.save()
            c.translate(d.box.left, d.box.top)
            paint_drawing(c, d.drawing, d.box.width, d.box.height, "contain")
            c.restore()
        else:
            asset_op(c, d.image, d.box.rect)
    c.restore()

    c.save()
    fit()
    c.clip_rrect(rim)
    _clip_overflow(c, w, h, [*(m.box for m in spec.mirrors), *(s.box for s in spec.slots)])
    for i, m in enumerate(spec.mirrors):
        v = values[m.source]
        if not shown(_K.MIRROR, i) or not v:
            continue
        alphabet = m.alphabet or spec.slots[m.source].alphabet
        paint_glyph_run(c, alphabet.render_all(v), m.box.rect, _style(theme.glyph_style(m.glyph_height, theme.ink)),
                        alphabet.direction)
    for i, s in enumerate(spec.slots):
        if not shown(_K.SLOT, i):
            continue
        # [D2] Anything but a glyph is a native input the UI layer places at the slot box.
        if mode is PlateMode.INPUT and input_source is not None and \
                resolve_slot_behavior(mode, s.alphabet.input, input_source) is not SlotBehavior.GLYPH:
            continue
        v = values[i]
        g = theme.glyph_style(s.box.height, theme.ink if s.color is None else s.color, s.spacing)
        paint_glyph_run(c, s.render(v) if v else "", s.box.rect, _style(g, spacing=g.letter_spacing),
                        s.alphabet.direction)
    if rejection:
        bh = h * 0.42
        top = (h - bh) / 2
        c.rect(Rect(0, top, w, bh), {"color": theme.alert_color})
        style = {"fontSize": h * 0.26, "height": 1, "color": 0xFFFFFFFF, "fontFamily": "Roboto", "fontWeight": 800,
                 "letterSpacing": 0.25}
        paint_text_line(c, rejection.reason, Rect(h * 0.1, top, w - h * 0.2, bh), style, TextDirection.LTR,
                        False, "start")
    c.restore()
    return c.ops
