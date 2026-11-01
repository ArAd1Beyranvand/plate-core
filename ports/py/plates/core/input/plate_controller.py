from __future__ import annotations

from enum import Enum
from typing import Callable

from ..model.plate_alphabet import AlphabetInput, PlateAlphabet, split_runes
from ..model.plate_restriction import PlateRestriction
from ..model.plate_spec import PlateSlot, PlateSpec
from ..validators.plate_validator import PlateValidation
from .observable import ALWAYS_NONE, Notifier, Observable
from .plate_input_controller import PlateInputTarget


class PlateValuePreservation(Enum):
    """What happens to the characters on a plate when `adopt_spec` swaps its spec."""

    NONE = "none"
    BY_INDEX = "byIndex"
    BY_GROUP_KEY = "byGroupKey"


class PlateController(Notifier):
    """Owns a plate's characters and drives focus and navigation.

    Listen at three grains: `slot(i)` per position, `completed` on a
    full/not-full flip, and the controller itself on every change."""

    def __init__(self, spec: PlateSpec, values: list[str | None] | None = None):
        super().__init__()
        self._spec = spec
        self._values: list[str | None] = [_printed_character(spec, i) for i in range(spec.slot_count)]
        if values is not None:
            for i in range(min(spec.slot_count, len(values))):
                if _printed_character(spec, i) is not None:
                    continue
                self._values[i] = _sanitize(spec, i, values[i])
        refused = _clear_restricted(spec, self._values)
        self._found_slots()
        self._completed = Observable(self._compute_completed())
        self._rejection: Observable[PlateRestriction | None] = Observable(refused)
        self.hints: Observable[list[str | None] | None] = Observable(None)
        """A sample value per slot, drawn faintly in place of the placeholder."""
        self._target: PlateInputTarget | None = None
        self._probe: Callable[[], PlateValidation | None] | None = None
        self._last_verdict: PlateValidation | None = None

    @classmethod
    def from_text(cls, spec: PlateSpec, text: str) -> PlateController:
        """Pours `text` into the slots in order; characters the current slot
        refuses, such as separators, are skipped without consuming it."""
        values: list[str | None] = [None] * spec.slot_count
        index = 0
        for character in text:
            if index >= spec.slot_count:
                break
            slot = spec.slots[index]
            if not slot.accepts(character):
                continue
            values[index] = (values[index] or "") + slot.canonical(character)
            if slot.is_full(values[index]):
                index += 1
        return cls(spec, values)

    @property
    def spec(self) -> PlateSpec:
        return self._spec

    def hint_at(self, index: int, alphabet: PlateAlphabet | None = None) -> str | None:
        hint = self.hints.value
        if hint is None or index >= len(hint) or index >= self._spec.slot_count:
            return None
        v = hint[index]
        if not v:
            return None
        return alphabet.render_all(v) if alphabet else self._spec.slots[index].render(v)

    @property
    def values(self) -> list[str | None]:
        return list(self._values)

    def value_at(self, index: int) -> str | None:
        return self._values[index] if 0 <= index < len(self._values) else None

    def set_at(self, index: int, value: str | None) -> bool:
        """'' or None clears; a refused character or a printed slot is a no-op;
        a restricted value is refused and published on `rejection`."""
        if index < 0 or index >= len(self._values):
            return False
        if _printed_character(self._spec, index) is not None:
            return False
        nxt = _sanitize(self._spec, index, value)
        if nxt is None and value:
            return False
        return self._store({index: nxt})

    def set_values(self, values: list[str | None]) -> bool:
        return self._store({
            i: _printed_character(self._spec, i) or (_sanitize(self._spec, i, values[i]) if i < len(values) else None)
            for i in range(len(self._values))
        })

    def clear(self) -> bool:
        return self.set_values([None] * len(self._values))

    def text(self, sep: str = " ") -> str:
        return sep.join(self._spec.render_group(g, self._values) for g in self._spec.effective_text_groups)

    def group(self, key: str) -> str:
        return self._spec.value_of_group(key, self._values)

    @property
    def region_caption(self) -> str | None:
        r = self._spec.resolve_region
        return r(self.group) if r else None

    def set_group(self, key: str, value: str) -> bool:
        """Pours `value` across the group's slots by length (a chosen symbol is taken whole)."""
        group = self._spec.group_named(key)
        if group is None:
            return False
        characters = split_runes(value)
        writes: dict[int, str | None] = {}
        offset = 0
        for index in group.indices:
            if _printed_character(self._spec, index) is not None:
                continue
            slot = self._spec.slots[index]
            take = len(characters) - offset if slot.alphabet.input is AlphabetInput.CHOSEN else slot.length
            writes[index] = _sanitize(self._spec, index, "".join(characters[offset:offset + take]))
            offset += take
        return self._store(writes)

    @property
    def is_completed(self) -> bool:
        return self._completed.value

    @property
    def is_empty(self) -> bool:
        return not any(self._values)

    def slot(self, index: int) -> Observable[str | None]:
        """Out of range stays None. Recreated by `adopt_spec`: don't cache it."""
        return self._slots[index] if 0 <= index < len(self._slots) else ALWAYS_NONE

    @property
    def completed(self) -> Observable[bool]:
        return self._completed

    @property
    def rejection(self) -> Observable[PlateRestriction | None]:
        """The restriction the last refused write broke; None once a write is stored."""
        return self._rejection

    def adopt_spec(self, next: PlateSpec, preserve: PlateValuePreservation = PlateValuePreservation.BY_GROUP_KEY) -> None:
        migrated = _migrate(self._spec, next, self._values, preserve)
        refused = _clear_restricted(next, migrated)
        self._spec = next
        self._values = migrated
        self._rejection.value = refused
        self._found_slots()
        self._completed.value = self._compute_completed()
        self.notify()

    @property
    def validation(self) -> PlateValidation | None:
        """A refused write outranks the validator."""
        refused = self._rejection.value
        if refused is not None:
            return PlateValidation.invalid(refused.reason)
        return self._probe() if self._probe else None

    def install_validation(self, probe: Callable[[], PlateValidation | None] | None) -> None:
        self._probe = probe
        self._last_verdict = None

    def report_validation(self, value: PlateValidation | None) -> None:
        """Notifies on a change of verdict, not per keystroke."""
        if self._last_verdict == value:
            return
        self._last_verdict = value
        self.notify()

    def attach(self, target: PlateInputTarget) -> None:
        self._target = target
        self.notify()

    def detach(self, target: PlateInputTarget) -> None:
        """Guarded: an old canvas's detach runs after the new one has attached."""
        if self._target is target:
            self._target = None
            self.notify()

    def notify_active_slot_changed(self) -> None:
        self.notify()

    @property
    def active_index(self) -> int | None:
        return self._target.active_index if self._target else None

    @property
    def active_slot(self) -> PlateSlot | None:
        i = self.active_index
        return self._spec.slot_at(-1 if i is None else i)

    @property
    def system_keyboard_active(self) -> bool:
        return self._target.system_keyboard_active if self._target else False

    @property
    def is_attached(self) -> bool:
        return self._target is not None

    def submit(self, character: str) -> None:
        if self._target:
            self._target.submit_character(character)

    def backspace(self) -> None:
        if self._target:
            self._target.backspace_character()

    def focus_first_empty(self) -> None:
        if self._target:
            self._target.focus_first_empty_slot()

    def focus_slot(self, index: int) -> None:
        if self._target:
            self._target.focus_slot(index)

    def dispose(self) -> None:
        self._target = None
        self._probe = None

    def _found_slots(self) -> None:
        self._slots = [Observable(v) for v in self._values]

    def _store(self, changes: dict[int, str | None]) -> bool:
        candidate = list(self._values)
        for i, v in changes.items():
            candidate[i] = v
        if self._refuse(candidate):
            return False
        for i, v in changes.items():
            self._values[i] = v
            self._slots[i].value = v
        self._completed.value = self._compute_completed()
        self._rejection.value = None
        self.notify()
        return True

    def _refuse(self, candidate: list[str | None]) -> bool:
        broken = self._spec.restriction_violated_by(candidate)
        if broken is None:
            return False
        self._rejection.value = broken
        self.notify()
        return True

    def _compute_completed(self) -> bool:
        return bool(self._values) and all(s.is_complete(self._values[i]) for i, s in enumerate(self._spec.slots))


def _clear_restricted(spec: PlateSpec, values: list[str | None]) -> PlateRestriction | None:
    """Empties, in place, every register breaking a restriction; returns the last broken."""
    broken = None
    for r in spec.restrictions:
        if not r.matches(spec.value_of_group(r.group, values)):
            continue
        for i in spec.indices_of_group(r.group):
            if i < len(values):
                values[i] = None
        broken = r
    return broken


def _sanitize(spec: PlateSpec, index: int, value: str | None) -> str | None:
    if not value:
        return None
    slot = spec.slot_at(index)
    if slot is None or not slot.accepts(value):
        return None
    return slot.canonical(value)


def _printed_character(spec: PlateSpec, index: int) -> str | None:
    """The fixed character of a slot whose alphabet holds exactly one."""
    slot = spec.slots[index]
    characters = slot.alphabet.characters
    return characters[0] if slot.length == 1 and len(characters) == 1 else None


def _has_keyed_groups(spec: PlateSpec) -> bool:
    return any(g.key is not None for g in spec.effective_text_groups)


def _migrate(from_: PlateSpec, to: PlateSpec, values: list[str | None], preserve: PlateValuePreservation) -> list[str | None]:
    if preserve is PlateValuePreservation.NONE:
        return [None] * to.slot_count

    by_key = preserve is PlateValuePreservation.BY_GROUP_KEY and (_has_keyed_groups(from_) or _has_keyed_groups(to))
    if not by_key:
        return [_sanitize(to, i, values[i]) if i < len(values) else None for i in range(to.slot_count)]

    # Printed slots first, so a matched group still wins.
    result = [_printed_character(to, i) for i in range(to.slot_count)]

    for target in to.effective_text_groups:
        if target.key is None:
            continue
        source = from_.group_named(target.key)
        if source is None:
            continue
        # Gaps are skipped, so a half-typed register carries as far as it got.
        characters = [c for i in source.indices if i < len(values) for c in split_runes(values[i] or "")]
        nxt = 0
        for index in target.indices:
            length = to.slots[index].length
            take = "".join(characters[nxt:nxt + length])
            nxt += length
            result[index] = _sanitize(to, index, take)
    return result
