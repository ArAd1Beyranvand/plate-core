from __future__ import annotations

from .plate_alphabet import PlateAlphabet
from .plate_box import PlateBox
from .plate_spec import PlateMirror, PlateRule, PlateSlot


def _check_count(count: int, caller: str) -> None:
    if count < 0:
        raise ValueError(f"{caller} needs count >= 0 (got {count})")


def plate_register(alphabet: PlateAlphabet, count: int, left: float, top: float, width: float,
                   height: float, pitch: float | None = None, color: int | None = None) -> tuple[PlateSlot, ...]:
    """`count` equal cells from `left`, stepping by `pitch` (default `width`: flush cells)."""
    _check_count(count, "plate_register")
    step = width if pitch is None else pitch
    return tuple(PlateSlot(alphabet, PlateBox(left + i * step, top, width, height), color=color)
                 for i in range(count))


def plate_register_across(alphabet: PlateAlphabet, count: int, left: float, right: float, top: float,
                          height: float, color: int | None = None) -> tuple[PlateSlot, ...]:
    """`count` flush cells filling `[left, right)` exactly."""
    _check_count(count, "plate_register_across")
    width = 0 if count == 0 else (right - left) / count
    return plate_register(alphabet, count, left, top, width, height, color=color)


def plate_echo(sources, left: float, top: float, width: float, height: float, pitch: float | None = None,
               glyph_height: float | None = None, alphabet: PlateAlphabet | None = None,
               editable: bool = False) -> tuple[PlateMirror, ...]:
    step = width if pitch is None else pitch
    return tuple(
        PlateMirror(source, PlateBox(left + i * step, top, width, height),
                    height if glyph_height is None else glyph_height, alphabet, editable)
        for i, source in enumerate(sources))


def plate_stipple(count: int, left: float, top: float, width: float, height: float,
                  step_x: float = 0, step_y: float = 0) -> tuple[PlateRule, ...]:
    _check_count(count, "plate_stipple")
    return tuple(PlateRule(PlateBox(left + i * step_x, top + i * step_y, width, height))
                 for i in range(count))
