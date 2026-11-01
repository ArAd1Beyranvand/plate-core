"""[D8] The soft keypad: a headless model (`PlateKeypad`) driven by an injected clock and timers, and
`DomKeypad`, which binds it to buttons under the plate (plate_keypad/lib/src/plate_keypad.dart)."""
from __future__ import annotations

from typing import Callable

from ..core.input.observable import Observable
from ..core.model.plate_alphabet import PlateAlphabet
from ..core.timing.plate_animation import CURVES
from ..render.plate_keypad import (
    DIGIT_LABELS, KEY_STAGGER, KEYPAD_SLIDE, NO_LETTERS, ROWS, SWAP_AT, KeyFace, PlateKeypadTheme,
    grid_for, grid_height, height_at, is_highlight, key_enabled, key_face, key_height, key_report,
    key_text, lerp_face, reveal,
)
from .svg import css

Clock = Callable[[], float]
Schedule = Callable[[Callable[[], None]], None]
SetTimeout = Callable[[Callable[[], None], float], object]
ClearTimeout = Callable[[object], None]


class PlateKey:
    """One key: the enabled state it shows trails the real one by the stagger (H14), and its face
    tweens (H15) toward wherever highlight and enabled put it."""

    def __init__(self, pad: PlateKeypad, label: str, index: int, count: int, digits, display):
        self.pad, self.label, self.index, self.count = pad, label, index, count
        self.digits, self.display = digits, display
        self.report, self.text = key_report(label, digits), key_text(label, display)
        self.shown = bool(label) and self.enabled
        self._turn = None
        self._tween: tuple[KeyFace, KeyFace, float] | None = None
        self._target = self._goal()
        self._unsub = pad.highlight.subscribe(self._retarget) if label else None  # D7: per key

    @property
    def enabled(self) -> bool:
        return key_enabled(self.report, self.pad.digit_alphabet if self.digits else self.pad.letter_alphabet,
                           self.pad.active_alphabet)

    @property
    def highlighted(self) -> bool:
        return is_highlight(self.pad.highlight.value, self.label, self.digits)

    def _goal(self) -> KeyFace:
        return key_face(self.pad.theme, self.highlighted, self.shown)

    def _retarget(self) -> None:
        goal = self._goal()
        if goal == self._target:
            return
        self._tween = (self.face(), goal, self.pad.clock())
        self._target = goal

    def face(self) -> KeyFace:
        if self._tween is None:
            return self._target
        a, b, t0 = self._tween
        p = (self.pad.clock() - t0) / b.duration
        return b if p >= 1 else lerp_face(a, b, CURVES["easeOut"].transform(max(0.0, p)))

    def refresh(self) -> None:
        """The enabled set may have changed: turn after the stagger, grey keys last-to-first."""
        if not self.label:
            return
        enabled = self.enabled
        if enabled == self.shown:
            self._cancel()
            return
        if self._turn is not None:
            return
        slot = self.count + self.index if enabled else self.count - 1 - self.index
        self._turn = self.pad.set_timeout(self._turned, KEY_STAGGER * slot)

    def _turned(self) -> None:
        self._turn = None
        self.shown = self.enabled
        self._retarget()
        self.pad._changed()

    def _cancel(self) -> None:
        if self._turn is not None:
            self.pad.clear_timeout(self._turn)
            self._turn = None

    def tap(self) -> None:
        if self.enabled and self.pad.on_key:
            self.pad.on_key(self.report)

    def dispose(self) -> None:
        self._cancel()
        if self._unsub:
            self.pad.highlight.unsubscribe(self._unsub)


class PlateKeypad:
    def __init__(self, digit_alphabet: PlateAlphabet, letter_alphabet: PlateAlphabet = NO_LETTERS, *,
                 active_alphabet: PlateAlphabet | None = None, theme: PlateKeypadTheme | None = None,
                 compact: bool = False, show_letters: bool = False, on_key: Callable[[str], None] | None = None,
                 highlight: Observable | None = None, clock: Clock = lambda: 0.0,
                 schedule: Schedule = lambda fn: None, set_timeout: SetTimeout | None = None,
                 clear_timeout: ClearTimeout = lambda h: None, on_change: Callable[[], None] | None = None):
        self.digit_alphabet, self.letter_alphabet, self.active_alphabet = digit_alphabet, letter_alphabet, active_alphabet
        self.theme, self.compact, self.on_key = theme or PlateKeypadTheme(), compact, on_key
        self.highlight = highlight or Observable(None)
        self.clock, self.schedule, self.on_change = clock, schedule, on_change
        self.set_timeout = set_timeout or (lambda fn, ms: fn())
        self.clear_timeout = clear_timeout
        self._from = self._to = show_letters
        self._from_height: float | None = None
        self._start: float | None = None
        self.keys: list[PlateKey] = []
        self._build(show_letters)

    @classmethod
    def numeric(cls, digits: PlateAlphabet, **kw) -> PlateKeypad:
        return cls(digits, NO_LETTERS, active_alphabet=digits, **kw)

    @property
    def t(self) -> float:
        if self._start is None:
            return 1.0
        return min(1.0, max(0.0, (self.clock() - self._start) / KEYPAD_SLIDE))

    @property
    def animating(self) -> bool:
        return self._start is not None and self.t < 1.0

    def _grid_height(self, letters: bool) -> float:
        return grid_height(grid_for(self.letter_alphabet).rows if letters else len(ROWS), self.compact)

    @property
    def height(self) -> float:
        t = self.t
        return height_at(t, self._from_height if self._from_height is not None else self._grid_height(self._from),
                         self._grid_height(self._to)) if self.animating else self._grid_height(self._to)

    @property
    def letters(self) -> bool:
        return self._from if self.t < SWAP_AT else self._to

    def reveal(self, key: PlateKey) -> float:
        return reveal(self.t, key.index, key.count)

    def _build(self, letters: bool) -> None:
        for k in self.keys:
            k.dispose()
        if letters:
            labels, digits, display = grid_for(self.letter_alphabet).cells, None, self.letter_alphabet
        else:
            labels, digits, display = DIGIT_LABELS, self.digit_alphabet, self.digit_alphabet
        self.keys = [PlateKey(self, label, i, len(labels), digits, display) for i, label in enumerate(labels)]
        self.columns = grid_for(self.letter_alphabet).columns if letters else len(ROWS[0])
        self.built_letters = letters

    def set_show_letters(self, letters: bool) -> None:
        if letters == self._to:
            return
        t = self.t
        if self.animating and t < SWAP_AT:  # the old grid is still leaving: bring it back
            self._from, self._to = self._to, self._from
            self._from_height = None
            self._start = self.clock() - (1.0 - t) * KEYPAD_SLIDE
        else:
            self._from_height = self.height if self.animating else None
            self._from, self._to = self._to, letters
            self._start = self.clock()
        self._tick()

    def set_active_alphabet(self, alphabet: PlateAlphabet | None) -> None:
        self.active_alphabet = alphabet
        for k in self.keys:
            k.refresh()

    def _tick(self) -> None:
        if self.letters != self.built_letters:
            self._build(self.letters)
        self._changed()
        if self.animating:
            self.schedule(self._tick)
        else:
            self._start = None

    def _changed(self) -> None:
        if self.on_change:
            self.on_change()

    def dispose(self) -> None:
        for k in self.keys:
            k.dispose()


class DomKeypad:
    """Buttons in a grid under the plate. pointerdown is cancelled so the slot input keeps focus."""

    def __init__(self, host, pad: PlateKeypad, document=None, proxy=None):
        if document is None:
            from .dom import browser
            document, proxy = browser()
        self.host, self.pad, self.document, self.proxy = host, pad, document, proxy
        self._handlers: list = []
        self.buttons: list = []
        pad.on_change = self.paint
        self.paint()

    def _on(self, el, kind: str, fn) -> None:
        h = self.proxy(fn) if self.proxy else fn
        self._handlers.append(h)
        el.addEventListener(kind, h)

    def _rebuild(self) -> None:
        pad = self.pad
        self.host.innerHTML = ""
        st = self.host.style
        st.display, st.gridTemplateColumns, st.gap, st.padding = "grid", f"repeat({pad.columns}, 1fr)", "6px", "8px"
        st.background, st.borderRadius, st.direction = css(pad.theme.surface), "12px", (
            pad.letter_alphabet.direction.value if pad.built_letters else "ltr")
        self.buttons = []
        for key in pad.keys:
            b = self.document.createElement("button")
            b.textContent, b.type = key.text, "button"
            b.style.height, b.style.fontSize, b.style.fontWeight = f"{key_height(pad.compact)}px", "18px", "500"
            b.style.visibility = "visible" if key.label else "hidden"
            self._on(b, "pointerdown", lambda e: e.preventDefault())
            self._on(b, "click", lambda e=None, k=key: k.tap())
            self.host.appendChild(b)
            self.buttons.append(b)
        self._built = (pad.built_letters, id(pad.keys))

    def paint(self) -> None:
        pad = self.pad
        if getattr(self, "_built", None) != (pad.built_letters, id(pad.keys)):
            self._rebuild()
        for key, b in zip(pad.keys, self.buttons):
            f, v = key.face(), pad.reveal(key)
            b.style.background, b.style.color, b.style.border = css(f.fill), css(f.ink), f"1px solid {css(f.border)}"
            b.style.opacity = str(v)
            b.style.transform = f"scale({f.scale * (0.6 + 0.4 * v)})"
            b.disabled = not key.shown
            if key.label and key.text.find("♿") >= 0:
                b.textContent = "♿︎"  # [D6-font] text presentation: plain ink, not the colour emoji
        if any(k._tween and k.face() != k._target for k in pad.keys) and not pad.animating:
            pad.schedule(self.paint)

    def dispose(self) -> None:
        self.pad.dispose()
        for h in self._handlers:
            if hasattr(h, "destroy"):
                h.destroy()
        self.host.innerHTML = ""
