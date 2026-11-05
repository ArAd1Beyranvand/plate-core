"""[D1] Keypad maths without a widget: slide phases, grid shape, key reports, face colours
(plate_keypad/lib/src/plate_keypad.dart)."""
from __future__ import annotations

import math
from dataclasses import dataclass
from functools import lru_cache
from typing import NamedTuple

from ..core.model.plate_alphabet import AlphabetInput, PlateAlphabet
from ..core.timing.plate_animation import CURVES

BACKSPACE_KEY = "BACKSPACE"
KEYPAD_SLIDE = 560
"""[H11] Duration of a digits/letters switch in ms; the phases below are fractions of it."""

OUT_END, RESIZE_START, RESIZE_END, IN_START, SWAP_AT = 0.4, 0.3, 0.7, 0.6, 0.5
KEY_GAP = 6
KEY_STAGGER = 18
FLASH_IN, FLASH_OUT, GREY_OUT = 90, 160, 180

ROWS = (("1", "2", "3"), ("4", "5", "6"), ("7", "8", "9"), ("", "0", "⌫"))
DIGIT_LABELS = tuple(k for row in ROWS for k in row)


@dataclass(frozen=True)
class PlateKeypadTheme:
    """[H10] ARGB ints."""

    surface: int = 0xFF1C1F26
    key_border: int = 0x3DFFFFFF
    ink: int = 0xFFFFFFFF
    disabled_ink: int = 0x4DFFFFFF
    highlight: int = 0xFFE8A33D
    highlight_ink: int = 0xFF05080B


NO_LETTERS = PlateAlphabet.of("keypad.noLetters", (), AlphabetInput.CHOSEN, False)


class Grid(NamedTuple):
    cells: tuple[str, ...]
    columns: int
    rows: int


@lru_cache(maxsize=None)
def grid_for(alphabet: PlateAlphabet) -> Grid:
    """A roughly square grid from the letter count, ending in backspace (blank spacers pad the row)."""
    letters = alphabet.characters
    columns = max(1, math.ceil(math.sqrt(len(letters))))
    rows = math.ceil((len(letters) + 1) / columns)
    cells = (*letters, *[""] * max(0, rows * columns - len(letters) - 1), "⌫")
    return Grid(cells, columns, rows)


def key_height(compact: bool) -> int:
    return 44 if compact else 56


def grid_height(rows: int, compact: bool) -> float:
    return rows * key_height(compact) + (rows - 1) * KEY_GAP


def height_at(t: float, from_h: float, to_h: float) -> float:
    p = CURVES["easeInOutCubic"].transform(min(1.0, max(0.0, (t - RESIZE_START) / (RESIZE_END - RESIZE_START))))
    return from_h + (to_h - from_h) * p


def reveal(t: float, index: int, count: int) -> float:
    """How present key `index` of `count` is at `t`: 1 at rest, 0 in order as the old grid leaves."""
    if t >= 1.0:
        return 1.0
    leaving = t < SWAP_AT
    a, b = (0.0, OUT_END) if leaving else (IN_START, 1.0)
    start = 0.0 if count <= 1 else index / (count - 1) * 0.5
    p = min(1.0, max(0.0, (((t - a) / (b - a) - start) / 0.5)))
    return 1.0 - CURVES["easeInCubic"].transform(p) if leaving else CURVES["easeOutCubic"].transform(p)


def entrance(elapsed: float, index: int, count: int, coming: bool) -> float:
    """How present key `index` of `count` is `elapsed` ms into the pad coming in or going out: keys stagger
    over the first half of KEYPAD_SLIDE, in reading order coming in and reversed going out."""
    at = 0.0 if count <= 1 else (index if coming else count - 1 - index) / (count - 1) * 0.5
    p = min(1.0, max(0.0, (elapsed / KEYPAD_SLIDE - at) / 0.5))
    return CURVES["easeOutCubic"].transform(p) if coming else 1.0 - CURVES["easeInCubic"].transform(p)


def key_report(label: str, digits: PlateAlphabet | None) -> str:
    """What a key reports: its label as the alphabet displays it; backspace is its own key."""
    if label == "⌫":
        return BACKSPACE_KEY
    return label if digits is None else digits.render(label)


def key_text(label: str, display: PlateAlphabet | None) -> str:
    return label if label == "⌫" or display is None else display.render(label)


def key_enabled(key: str, own: PlateAlphabet, active: PlateAlphabet | None) -> bool:
    if not key:
        return False
    return key == BACKSPACE_KEY or (active or own).accepts(key)


def is_highlight(candidate: str | None, label: str, digits: PlateAlphabet | None) -> bool:
    """[H3] Both sides fold to canonical, so '5' lights the '۵' key."""
    if candidate is None:
        return False
    key = key_report(label, digits)
    return candidate == key or (digits is not None and digits.canonical(candidate) == digits.canonical(key))


def lerp_argb(a: int, b: int, t: float) -> int:
    """[H15] Each channel lerped and rounded."""
    return sum(round(((a >> s) & 255) + (((b >> s) & 255) - ((a >> s) & 255)) * t) << s for s in (24, 16, 8, 0))


def dim_border(theme: PlateKeypadTheme) -> int:
    alpha = round(((theme.key_border >> 24) & 255) * 0.5)
    return (alpha << 24) | (theme.key_border & 0xFFFFFF)


class KeyFace(NamedTuple):
    fill: int
    border: int
    ink: int
    scale: float
    duration: int


def key_face(theme: PlateKeypadTheme, highlighted: bool, enabled: bool) -> KeyFace:
    """Where a key's colours settle; the UI tweens to it over `duration` ms with easeOut (H15)."""
    if highlighted:
        return KeyFace(theme.highlight, theme.highlight, theme.highlight_ink, 0.94, FLASH_IN)
    if enabled:
        return KeyFace(0, theme.key_border, theme.ink, 1.0, FLASH_OUT)
    return KeyFace(0, dim_border(theme), theme.disabled_ink, 1.0, GREY_OUT)


def lerp_face(a: KeyFace, b: KeyFace, t: float) -> KeyFace:
    """Transparent is 0x00000000; Flutter's Colors.transparent fill lerps the same way."""
    return KeyFace(lerp_argb(a.fill, b.fill, t), lerp_argb(a.border, b.border, t),
                   b.ink, a.scale + (b.scale - a.scale) * t, b.duration)
