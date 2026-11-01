from __future__ import annotations

from dataclasses import dataclass, fields, replace
from typing import NamedTuple

ALERT = 0xFFF87171


class GlyphStyle(NamedTuple):
    """Toolkit-neutral font request: a QFont with this pixel size, bold."""

    pixel_size: float
    color: int
    letter_spacing: float = 0
    bold: bool = True


def _lerp_color(a: int, b: int, t: float) -> int:
    return sum(round(((a >> s) & 0xFF) + (((b >> s) & 0xFF) - ((a >> s) & 0xFF)) * t) << s
               for s in (24, 16, 8, 0))


@dataclass(frozen=True)
class PlateTheme:
    """Chrome colours (0xAARRGGBB) and ratios, sampled from real plates; never tint with a host accent.

    The `*_ratio` fields are fractions of the plate height.
    """

    plate_background: int
    plate_border: int
    ink: int
    divider_color: int
    border_width_ratio: float
    plate_radius_ratio: float
    active_color: int
    inactive_color: int
    alert_color: int = ALERT

    @classmethod
    def standard(cls) -> PlateTheme:
        return cls(0xFFFFFFFF, 0xFF000000, 0xFF0A0A0A, 0xFF000000, 0.04, 0.12, 0xFF0A0A0A, 0x66666666)

    @classmethod
    def monochrome(cls, field: int, ink: int, inactive: int, border_width_ratio: float,
                   plate_radius_ratio: float, alert_color: int = ALERT) -> PlateTheme:
        """One ink on one field."""
        return cls(field, ink, ink, ink, border_width_ratio, plate_radius_ratio, ink, inactive, alert_color)

    def copy_with(self, **changes) -> PlateTheme:
        return replace(self, **changes)

    def glyph_style(self, slot_height: float, color: int, letter_spacing: float = 0) -> GlyphStyle:
        return GlyphStyle(slot_height * 0.72, color, letter_spacing)

    @staticmethod
    def lerp(a: PlateTheme, b: PlateTheme, t: float) -> PlateTheme:
        out = {}
        for f in fields(PlateTheme):
            x, y = getattr(a, f.name), getattr(b, f.name)
            out[f.name] = x + (y - x) * t if isinstance(x, float) else _lerp_color(x, y, t)
        return PlateTheme(**out)
