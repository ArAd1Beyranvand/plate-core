from __future__ import annotations

from dataclasses import dataclass

from .plate_asset import PlateGraphic


@dataclass(frozen=True, eq=False)
class PlateCountry:
    """The country chrome of a plate; equal iff codes match. Colours are ARGB ints."""

    code: str
    caption_lines: tuple[str, ...]
    panel_color: int
    panel_text_color: int | None
    heading_lines: tuple[str, ...] = ()
    flag_aspect_ratio: float = 7 / 4
    flag: PlateGraphic | None = None
    flag_border_color: int | None = None

    def __eq__(self, other: object) -> bool:
        return isinstance(other, PlateCountry) and other.code == self.code

    def __hash__(self) -> int:
        return hash(self.code)
