from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True)
class PlateRestriction:
    """A value a named register may never hold, and the error shown when something stores it."""

    group: str
    values: tuple[str, ...]
    reason: str

    def matches(self, group_value: str) -> bool:
        return group_value in self.values


class PlateRestrictionError(ValueError):
    """Raised by `PlateSpec.check_restrictions`; str() is the restriction's reason."""

    def __init__(self, restriction: PlateRestriction):
        super().__init__(restriction.reason)
        self.restriction = restriction
