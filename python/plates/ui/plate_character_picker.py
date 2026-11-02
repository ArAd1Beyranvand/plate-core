"""[D8] A modal list over an alphabet's characters, answering with the chosen canonical character
(plate_keypad/lib/src/plate_character_picker.dart). Pass `show` to PlateCanvas's on-choose hook."""
from __future__ import annotations

from typing import Callable

from ..core.model.plate_alphabet import PlateAlphabet


def picker_items(alphabet: PlateAlphabet) -> list[tuple[str, str]]:
    """(canonical character, rendered text) per row. U+267F is drawn as an icon by the painter."""
    return [(c, alphabet.render(c)) for c in alphabet.characters]


class PlateCharacterPicker:
    def __init__(self, document, proxy=None):
        self.document, self.proxy, self._handlers = document, proxy, []

    def show(self, host, alphabet: PlateAlphabet, on_choose: Callable[[str], None]) -> object:
        """Opens a <dialog> in `host`; OK reports the selected character (the first by default)."""
        d, doc = self.document.createElement("dialog"), self.document
        chosen = [alphabet.characters[0] if alphabet.characters else None]
        rows = doc.createElement("div")
        rows.style.overflowY, rows.style.maxHeight = "auto", "280px"
        buttons = []
        for c, text in picker_items(alphabet):
            b = doc.createElement("button")
            b.textContent, b.type = "♿︎" if "♿" in text else text, "button"
            b.style.fontSize, b.style.display = "32px", "block"
            def pick(_e=None, c=c, b=b) -> None:
                chosen[0] = c
                for x in buttons:
                    x.style.fontWeight = "700" if x is b else "400"
            self._on(b, "click", pick)
            rows.appendChild(b)
            buttons.append(b)
        ok = doc.createElement("button")
        ok.textContent = "OK"

        def accept(_e=None) -> None:
            d.close()
            if chosen[0] is not None:
                on_choose(chosen[0])
        self._on(ok, "click", accept)
        d.appendChild(rows)
        d.appendChild(ok)
        host.appendChild(d)
        d.showModal()
        return d

    def _on(self, el, kind: str, fn) -> None:
        h = self.proxy(fn) if self.proxy else fn
        self._handlers.append(h)
        el.addEventListener(kind, h)
