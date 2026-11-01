"""Port of iran_plate/lib/src/iran_themes.dart (the `[D4-code]` resolver). Hand-ported; codegen never overwrites this file."""
from __future__ import annotations

from plates.core.theme.plate_theme import PlateTheme

_BLACK = 0xFF1D1D1B
_WHITE = 0xFFFFFFFF
_INACTIVE_ON_LIGHT = 0x66666666
_INACTIVE_ON_DARK = 0x88FFFFFF

_BORDER_WIDTH_RATIO = 0.04
_PLATE_RADIUS_RATIO = 0.12


def _monochrome(field, ink, inactive):
    return PlateTheme.monochrome(field, ink, inactive, _BORDER_WIDTH_RATIO, _PLATE_RADIUS_RATIO)


_BLACK_ON_WHITE = _monochrome(_WHITE, _BLACK, _INACTIVE_ON_LIGHT)
_BLACK_ON_YELLOW = _monochrome(0xFFFFC913, _BLACK, _INACTIVE_ON_LIGHT)
_WHITE_ON_RED = _monochrome(0xFFED1C24, _WHITE, _INACTIVE_ON_DARK)
_WHITE_ON_GREEN = _monochrome(0xFF005329, _WHITE, _INACTIVE_ON_DARK)
_BLACK_ON_TAN = _monochrome(0xFFCEA160, _BLACK, _INACTIVE_ON_LIGHT)
_WHITE_ON_FORCES_BLUE = _monochrome(0xFF0079C1, _WHITE, _INACTIVE_ON_DARK)
_BLACK_ON_CYAN = _monochrome(0xFF00A2E8, _BLACK, _INACTIVE_ON_LIGHT)


class IranThemes:
    @staticmethod
    def civil(base, group):
        """The colours of the class the series letter belongs to, on `base`'s rim and corner."""
        letter = group("letter")
        if letter in ("ت", "ع", "ک"):
            t = _BLACK_ON_YELLOW
        elif letter == "الف":
            t = _WHITE_ON_RED
        elif letter in ("پ", "ث"):
            t = _WHITE_ON_GREEN
        elif letter == "ش":
            t = _BLACK_ON_TAN
        elif letter in ("ز", "ف"):
            t = _WHITE_ON_FORCES_BLUE
        elif letter in ("D", "S"):
            t = _BLACK_ON_CYAN
        else:
            t = _BLACK_ON_WHITE
        return base.copy_with(
            plate_background=t.plate_background,
            plate_border=t.plate_border,
            ink=t.ink,
            divider_color=t.divider_color,
            active_color=t.active_color,
            inactive_color=t.inactive_color,
        )
