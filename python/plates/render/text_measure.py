from __future__ import annotations

from typing import Callable

TextMeasurer = Callable[[str, dict], float]
"""[H12] Measures a line in plate units; the UI swaps in QFontMetricsF."""


def _estimate(text: str, s: dict) -> float:
    """A headless estimate: 0.6 em per code point plus letter spacing. Layout only, never compared."""
    return len(text) * (s["fontSize"] * 0.6 + s["letterSpacing"])


_measurer: TextMeasurer = _estimate


def measure_text(text: str, style: dict) -> float:
    return _measurer(text, style)


def set_text_measurer(m: TextMeasurer | None) -> None:
    global _measurer
    _measurer = m or _estimate
