"""[W6] The embed shell for one country: plate, keypad and verdict line, speaking the
plate-embed protocol (ports/py/web/boot.js starts it; ports/ts/web/shell.ts is the TS twin).

Only `plates.countries.<country>.data` is imported, by name. `env` is the page seam (browser.py)."""
from __future__ import annotations

from importlib import import_module

from ..core.input.plate_controller import PlateController
from ..core.model.plate_alphabet import LATIN_DIGITS
from ..core.model.plate_input_source import PlateInputSource
from ..core.validators.plate_validator import PlateEntry, restriction_verdict
from ..core.input.plate_input_machine import PlateInputMachine
from ..core.timing.plate_animation import PlateAnimationController, stagger_sequence
from ..render.plate_keypad import BACKSPACE_KEY, NO_LETTERS
from ..ui.dom import DomPlate
from ..ui.plate_canvas import PlateCanvas
from ..ui.plate_character_picker import PlateCharacterPicker
from ..ui.plate_keypad import DomKeypad, PlateKeypad
from ..ui.spec_swap import introduce, outgoing, swap_spec
from .protocol import Client

VERSION = "1.0.0"


def start(country: str, env) -> "Shell":
    """Boots the shell for [country]."""
    return Shell(country, import_module(f"plates.countries.{country}.data"), env)


class Shell:
    def __init__(self, country: str, data, env):
        self.data, self.env, self.doc = data, env, env.document
        self.entries = data.GALLERY
        self._pending: dict | None = None
        self._booted = self._quiet = False
        self.show_keypad = True
        self._last = None
        self._off = self._plate = self._keypad = self._pad = self.controller = self.machine = self.canvas = None
        self._handlers: list = []
        self.anim = PlateAnimationController()
        self._end_swap = lambda: None
        self._tmp: list = []
        self.client = Client({"lang": "python", "country": country, "version": VERSION}, self._init, self.action, env)
        if not env.greeted:
            self.client.hello()
        self._build_page()
        self._booted = True
        self._init(self._pending or {"keypad": True, "theme": "light"})
        self.client.ready([{"id": e["id"], "label": e["label"]} for e in self.entries], self.entry["id"])
        env.remove_splash()

    def _el(self, tag: str, css: str = ""):
        e = self.doc.createElement(tag)
        e.style.cssText = css
        return e

    def _on(self, el, kind: str, fn, into: list | None = None) -> None:
        h = self.env.proxy(fn) if self.env.proxy else fn
        (self._handlers if into is None else into).append(h)
        el.addEventListener(kind, h)

    def _build_page(self) -> None:
        self.stage, self.keypad_box = self._el("div", "position:relative;width:100%"), self._el("div", "margin-top:8px")
        self.verdict = self._el("p", "font:14px system-ui;margin:8px 0 0")
        self.verdict.setAttribute("role", "status")
        for e in (self.stage, self.keypad_box, self.verdict):
            self.env.root.appendChild(e)
        self.picker = PlateCharacterPicker(self.doc, self.env.proxy)

    def _entry_of(self, id: str | None) -> dict:
        """A gallery id, else the first entry showing that spec id, else the first entry."""
        return next((e for e in self.entries if e["id"] == id), None) or next(
            (e for e in self.entries if e["spec"] == id), self.entries[0])

    def build(self, id: str | None, values=None, animate: str | None = None) -> None:
        """[animate] 'swap' plays the old plate out and the new in; 'intro' only comes in; None snaps."""
        old, silent = self.controller, self._quiet
        self._end_swap()
        self._end_swap = lambda: None
        prev = outgoing(self.canvas) if self.canvas else None
        entry = self._entry_of(id)
        spec = self.data.SPECS[entry["spec"]]
        self._teardown()
        if values is None and old is not None:
            c = PlateController(old.spec, old.values)
            c.adopt_spec(spec)
            old.dispose()
        else:
            c = PlateController(spec, values)
        self.entry, self.controller = entry, c
        c.hints.value = entry.get("sampleValues")
        validator = self.data.VALIDATORS[entry["validator"]]() if entry["validator"] else None
        probe = validator.validate if validator else restriction_verdict
        c.install_validation(lambda: probe(PlateEntry(c.spec, c.values, self.machine.active_index)))

        source = PlateInputSource.PACKAGE_KEYPAD if self.show_keypad else PlateInputSource.SYSTEM
        self.machine = m = PlateInputMachine(spec, lambda: c.values, lambda i, t: c.set_at(i, t or None), source,
                                             self._focused)
        m.request_focus = self._focus
        m.on_sheet_requested = self._sheet
        c.attach(m)
        t = self.data.THEMES.get(entry["theme"]) if entry["theme"] else None
        country = self.data.COUNTRIES.get(entry["country"]) if entry["country"] else None
        self.canvas = PlateCanvas(c, t, country, input_source=source, animation=self.anim, clock=self.env.now,
                                  schedule=self.env.schedule)
        self._plate = DomPlate(self.stage, self.canvas, self.doc, self.env.proxy)
        if prev and animate == "swap":
            self._end_swap = swap_spec(self.env, self.stage, prev, self.canvas, self.anim)
        elif animate:
            introduce(self.canvas, self.anim)
        else:
            self.anim.settle_all()
        for i, e in self._plate.inputs.items():
            self._on(e, "focus", lambda _e=None, i=i: m.handle_focus_change(i), self._tmp)
            self._on(e, "input", lambda _e=None, i=i: self._typed(i), self._tmp)
            self._on(e, "keydown", lambda ev, e=e: self._key(ev, e), self._tmp)
        self._keypad = self._pad = None
        if self.show_keypad:
            self._keypad = PlateKeypad(self._alphabet(True) or LATIN_DIGITS, self._alphabet(False) or NO_LETTERS,
                                       active_alphabet=self._current(), show_letters=self._letters(),
                                       on_key=self._pressed, clock=self.env.now, schedule=self.env.schedule,
                                       set_timeout=self.env.set_timeout, clear_timeout=self.env.clear_timeout)
            self._pad = DomKeypad(self.keypad_box, self._keypad, self.doc, self.env.proxy)
        self._off = c.subscribe(self._changed)
        self._quiet = True
        self._changed()
        self._quiet = silent

    def _teardown(self) -> None:
        if self.controller is not None:
            self.controller.unsubscribe(self._off)
        if self._plate:
            self._plate.dispose()
        if self._pad:
            self._pad.dispose()
        for h in self._tmp:
            if hasattr(h, "destroy"):
                h.destroy()
        self._tmp = []

    def _focus(self, i: int) -> None:
        e = self._plate.inputs.get(i)
        if e is not None:
            e.focus()
        if self.machine.active_index != i:  # the page may lack the focus that would have said so
            self.machine.handle_focus_change(i)

    def _sheet(self, i: int) -> None:
        def chosen(ch: str) -> None:
            self.machine.handle_focus_change(i)
            if self.controller.set_at(i, ch):
                self.machine.advance_from(i)
        self.picker.show(self.stage, self.controller.spec.slots[i].alphabet, chosen)

    def _typed(self, i: int) -> None:
        if self.controller.spec.slots[i].is_full(self.controller.value_at(i)):
            self.machine.advance_from(i)

    def _key(self, ev, e) -> None:
        if ev.key == "Backspace" and not e.value:
            ev.preventDefault()
            self.machine.backspace_character()

    def _pressed(self, key: str) -> None:
        if key == BACKSPACE_KEY:
            self.machine.backspace_character()
        else:
            self.machine.submit_character(key)

    def _alphabet(self, numeric: bool):
        return next((s.alphabet for s in self.controller.spec.slots if s.alphabet.is_numeric == numeric), None)

    def _current(self):
        """The alphabet of the focused slot, else of the first one not yet complete."""
        c, m = self.controller, self.machine
        slots = c.spec.slots
        at = m.active_index if m and m.active_index is not None else next(
            (i for i, s in enumerate(slots) if not s.is_complete(c.value_at(i))), None)
        return slots[at].alphabet if at is not None and at < len(slots) else None

    def _letters(self) -> bool:
        """Letters are up while the slot that takes the next character takes letters."""
        a = self._current()
        return a is not None and not a.is_numeric

    def _focused(self, i) -> None:
        self.controller.notify_active_slot_changed()
        self.canvas.active_index = i
        self.canvas._changed()
        self._sync_keypad()

    def _sync_keypad(self) -> None:
        if self._keypad:
            self._keypad.set_active_alphabet(self._current())
            if self._letters():
                self._keypad.letter_alphabet = self._current()
            self._keypad.set_show_letters(self._letters())

    def _state(self) -> dict:
        c, v = self.controller, self.controller.validation
        return {"spec": self.entry["id"], "values": list(c.values), "text": c.text(), "complete": c.is_completed,
                "valid": None if v is None else v.is_valid}

    def _changed(self) -> None:
        c, v = self.controller, self.controller.validation
        self.verdict.textContent = (v.reason if v and v.reason else "Complete" if c.is_completed else "Incomplete")
        self._emit()

    def _emit(self) -> None:
        s = self._state()
        if self._quiet:
            self._last = None
        elif s != self._last:
            self._last = s
            self.client.change(s)

    def _init(self, p: dict) -> None:
        if not self._booted:
            self._pending = p
            return
        self.show_keypad = p["keypad"]
        self.env.set_theme(p["theme"])
        self._quiet = True
        self.build(p.get("spec"), p.get("values"), "intro")
        self._quiet = False

    def action(self, name: str, args: dict) -> None:
        try:
            if name == "setSpec":
                self.build(args["spec"], None, "swap")
                self._emit()
            elif name == "setValues":
                if not isinstance(args.get("values"), list):
                    raise ValueError("setValues needs values")
                self.controller.set_values(args["values"])
            elif name == "clear":
                self.controller.clear()
            elif name == "focus":
                self.machine.focus_first_empty_slot()
            elif name == "leave":
                self._end_swap()
                self.anim.go_out_all(stagger_sequence(self.canvas.spec, reverse=True))
            elif name == "setTheme":
                self.env.set_theme(args["theme"])
        except (KeyError, ValueError, TypeError) as e:
            self.client.error("bad_action", str(e))
