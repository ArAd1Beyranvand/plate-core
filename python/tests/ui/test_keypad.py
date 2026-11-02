from plates.core.input.observable import Observable
from plates.core.model.plate_alphabet import LATIN_DIGITS, LATIN_UPPERCASE, AlphabetInput, PlateAlphabet
from plates.render.plate_keypad import (
    BACKSPACE_KEY, KEYPAD_SLIDE, grid_for, height_at, is_highlight, lerp_argb, reveal,
)
from plates.ui.plate_character_picker import PlateCharacterPicker, picker_items
from plates.ui.plate_keypad import DomKeypad, PlateKeypad
from tests.ui.test_ui import _Doc, _El

PERSIAN = PlateAlphabet.of("fa.digits", "0123456789", AlphabetInput.CHOSEN, True,
                           glyphs={str(i): "۰۱۲۳۴۵۶۷۸۹"[i] for i in range(10)})


class Clock:
    now = 0.0

    def __call__(self):
        return self.now


def test_phases_and_grid():
    assert reveal(1.0, 0, 5) == 1 and reveal(0.0, 0, 5) == 1 and reveal(0.5, 4, 5) == 0
    assert height_at(0.0, 10, 20) == 10 and height_at(1.0, 10, 20) == 20
    g = grid_for(LATIN_UPPERCASE)
    assert (g.columns, g.rows, g.cells[-1], len(g.cells)) == (6, 5, "⌫", 30)
    assert lerp_argb(0xFF000000, 0xFFFFFFFF, 0.5) == 0xFF808080


def test_persian_key_lights_for_ascii_and_reports_in_script():
    assert is_highlight("5", "5", PERSIAN) and not is_highlight("6", "5", PERSIAN)
    got = []
    pad = PlateKeypad.numeric(PERSIAN, on_key=got.append)
    [k for k in pad.keys if k.label == "5"][0].tap()
    [k for k in pad.keys if k.label == "⌫"][0].tap()
    assert got == ["۵", BACKSPACE_KEY]


def test_switch_animates_and_swaps_grid():
    clock, later, held = Clock(), [], Observable(None)
    pad = PlateKeypad(LATIN_DIGITS, LATIN_UPPERCASE, clock=clock, schedule=later.append, highlight=held)
    h0 = pad.height
    pad.set_show_letters(True)
    assert pad.animating and not pad.built_letters
    clock.now = KEYPAD_SLIDE * 0.6
    later.pop()()
    assert pad.built_letters and len(pad.keys) == 30
    clock.now = KEYPAD_SLIDE
    later.pop()()
    assert not pad.animating and pad.height > h0
    held.value = "A"
    key = pad.keys[0]
    assert key.highlighted
    clock.now += 1000
    assert key.face().fill == 0xFFE8A33D and key.face().scale == 0.94


def test_dom_keypad_and_disabled_stagger():
    timers = []
    pad = PlateKeypad(LATIN_DIGITS, set_timeout=lambda fn, ms: timers.append(fn) or fn)
    host = _El("div")
    dom = DomKeypad(host, pad, document=_Doc())
    assert len(dom.buttons) == 12
    pad.set_active_alphabet(PlateAlphabet.of("only.1", "1", AlphabetInput.CHOSEN, True))
    assert pad.keys[1].shown and timers
    for fn in timers:
        fn()
    assert not pad.keys[1].shown and pad.keys[0].shown


def test_picker():
    alphabet = PlateAlphabet.of("x", ("A", "B"), AlphabetInput.CHOSEN, False)
    assert picker_items(alphabet) == [("A", "A"), ("B", "B")]
    host, doc, chosen = _El("div"), _Doc(), []
    _El.close = lambda self: None
    _El.showModal = lambda self: None
    PlateCharacterPicker(doc).show(host, alphabet, chosen.append)
    dialog = host.children[0]
    rows, ok = dialog.children
    rows.children[1].listeners["click"]()
    ok.listeners["click"]()
    assert chosen == ["B"]
