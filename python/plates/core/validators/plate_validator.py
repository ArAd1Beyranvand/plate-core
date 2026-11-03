from __future__ import annotations

import re
from dataclasses import dataclass
from typing import Protocol

from ..model.plate_spec import PlateSlot, PlateSpec, PlateTextGroup


@dataclass(frozen=True)
class PlateValidation:
    """The verdict on a plate; `reason` explains an invalid one and is None when valid."""

    reason: str | None = None

    @classmethod
    def valid(cls) -> PlateValidation:
        return cls()

    @classmethod
    def invalid(cls, reason: str) -> PlateValidation:
        return cls(reason)

    @property
    def is_valid(self) -> bool:
        return self.reason is None


@dataclass(frozen=True)
class PlateEntry:
    spec: PlateSpec
    values: list[str | None]
    active_index: int | None = None
    """The focused slot, so a validator can stay quiet about groups the user has not reached."""

    def group(self, key: str) -> str:
        return self.spec.value_of_group(key, self.values)

    @property
    def active_group(self) -> PlateTextGroup | None:
        return None if self.active_index is None else self.spec.group_at(self.active_index)


def is_digits(value: str) -> bool:
    """ASCII 0-9 only; str.isdigit() accepts ۵ and ²."""
    return re.fullmatch(r"[0-9]+", value) is not None


def is_digits_of_length(value: str, length: int) -> bool:
    return len(value) == length and is_digits(value)


class PlateValidator(Protocol):
    def validate(self, entry: PlateEntry) -> PlateValidation: ...


def restriction_verdict(entry: PlateEntry) -> PlateValidation | None:
    broken = entry.spec.restriction_violated_by(entry.values)
    return None if broken is None else PlateValidation.invalid(broken.reason)


class GatedPlateValidator:
    """Stays quiet until `gate_group`, the last register the user reaches, has content."""

    gate_group: str

    def judge(self, entry: PlateEntry) -> PlateValidation:
        raise NotImplementedError

    def validate(self, entry: PlateEntry) -> PlateValidation:
        return restriction_verdict(entry) or (
            PlateValidation.valid() if not entry.group(self.gate_group) else self.judge(entry))


@dataclass(frozen=True)
class PlateCheck:
    """One field rule of a `RuledPlateValidator`: the group named `group` must match `pattern` whole, or the plate is
    invalid for `reason`. An `optional` group may also be empty. Keep classes explicit (`[0-9]`, not `\\d`)."""

    group: str
    pattern: str
    reason: str
    optional: bool = False

    def passes(self, value: str) -> bool:
        return (self.optional and not value) or re.fullmatch(self.pattern, value) is not None


class RuledPlateValidator(GatedPlateValidator):
    """A gated validator that is a list of `checks`, judged in order; the first to fail gives the verdict. The gate is
    the last check's group unless a subclass sets `gate_group`."""

    checks: tuple[PlateCheck, ...] = ()

    @property
    def gate_group(self) -> str:
        return self.checks[-1].group

    def judge(self, entry: PlateEntry) -> PlateValidation:
        failed = next((c for c in self.checks if not c.passes(entry.group(c.group))), None)
        return PlateValidation.valid() if failed is None else PlateValidation.invalid(failed.reason)
