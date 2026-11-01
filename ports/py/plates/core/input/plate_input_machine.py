from __future__ import annotations

from typing import Callable

from ..model.plate_alphabet import AlphabetInput, split_runes
from ..model.plate_input_source import PlateInputSource
from ..model.plate_spec import PlateSpec
from ..model.slot_behavior import PlateMode, SlotBehavior, resolve_slot_behavior


class PlateInputMachine:
    """The pure focus and navigation machine for one plate (D8); implements
    `PlateInputTarget`. Reads values through `read_values` and writes through
    `commit`. Bound to its spec: a spec change builds a new machine.

    The Qt adapter owns a QLineEdit per slot: it sets `request_focus` to focus
    one, and reports focus changes through `handle_focus_change`. Without an
    adapter a request is granted at once."""

    def __init__(
        self,
        spec: PlateSpec,
        read_values: Callable[[], list[str | None]],
        commit: Callable[[int, str], bool],
        input_source: PlateInputSource,
        on_active_index_changed: Callable[[int | None], None] | None = None,
    ):
        self.spec = spec
        self.read_values = read_values
        self.commit = commit
        """Writes one slot back to the host; '' clears it. Focus must not advance past a refusal."""
        self.input_source = input_source
        self.on_active_index_changed = on_active_index_changed
        self.on_sheet_requested: Callable[[int], None] | None = None
        self.request_focus: Callable[[int], None] = lambda i: self.handle_focus_change(i)
        # Seeded, unannounced, so a keypad driven by active_index starts on the first slot.
        self._active_index: int | None = 0 if spec.slots else None

    @property
    def active_index(self) -> int | None:
        return self._active_index

    @property
    def system_keyboard_active(self) -> bool:
        return False

    def handle_focus_change(self, slot: int | None, mirror: int | None = None) -> None:
        """An editable mirror's focus reports as its source's."""
        active = slot if slot is not None else None if mirror is None else self.spec.mirrors[mirror].source
        if active != self._active_index:
            self._active_index = active
            if self.on_active_index_changed:
                self.on_active_index_changed(active)

    def advance_from(self, index: int) -> None:
        """To the next slot, or its sheet if chosen. At the end focus stays."""
        nxt = self.spec.next_index(index)
        if nxt is None:
            return
        behavior = resolve_slot_behavior(PlateMode.INPUT, self.spec.slots[nxt].alphabet.input, self.input_source)
        if behavior is SlotBehavior.SHEET:
            if self.on_sheet_requested:
                self.on_sheet_requested(nxt)
        else:
            self.request_focus(nxt)

    def field_text(self, index: int, value: str | None) -> str | None:
        """What slot `index`'s field shows for `value`, in the alphabet's display
        form; None for a chosen slot, which has no field. The adapter applies it
        with setText + end(False) under blockSignals, only when it differs."""
        slot = self.spec.slots[index]
        if slot.alphabet.input is not AlphabetInput.TYPED:
            return None
        return slot.render(value) if value else ""

    def submit_character(self, c: str) -> None:
        index = self._active_index
        if index is None:
            return
        slot = self.spec.slots[index]
        nxt = (self.read_values()[index] or "") + slot.alphabet.canonical(c)
        if not slot.accepts(nxt):
            return
        if not self.commit(index, nxt):
            return
        if slot.is_full(nxt):
            self.advance_from(index)

    def backspace_character(self) -> None:
        values = self.read_values()
        # Focus can drop once the plate is complete; the keypad still deletes from the end.
        index = self._active_index
        if index is None:
            index = next((i for i in reversed(range(len(values))) if values[i]), -1)
        if index < 0:
            return
        current = values[index]
        target = index if current else self.spec.previous_index(index)
        if target is None:
            return
        held = split_runes(current or values[target] or "")
        if not held:
            # As Dart's runes.take(-1): two empty slots in a row is a RangeError.
            raise IndexError("backspace over two empty slots")
        self.commit(target, "".join(held[:-1]))
        self.request_focus(target)

    def focus_first_empty_slot(self) -> None:
        values = self.read_values()
        i = next((i for i, s in enumerate(self.spec.slots) if not s.is_full(values[i])), 0)
        self.request_focus(i)

    def focus_slot(self, index: int) -> None:
        if 0 <= index < len(self.spec.slots):
            self.request_focus(index)
