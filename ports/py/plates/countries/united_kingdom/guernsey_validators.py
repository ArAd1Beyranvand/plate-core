"""Port of united_kingdom_plate/lib/src/guernsey/src/guernsey_validators.dart."""
from __future__ import annotations

from plates.core.validators.plate_validator import PlateEntry, PlateValidation


class GuernseyValidator:
    def validate(self, entry: PlateEntry) -> PlateValidation:
        refused = self._restriction_verdict(entry)
        if refused is not None:
            return refused
        serial = entry.values[0] if entry.values else ""
        if not serial:
            return PlateValidation.valid()
        slot = entry.spec.slot_at(0)
        if slot is not None and not slot.is_complete(serial):
            return PlateValidation.invalid("The serial is incomplete.")
        return PlateValidation.valid()

    def _restriction_verdict(self, entry: PlateEntry) -> PlateValidation | None:
        # Quiet until something is typed, then the digit run must reach its minimum
        # (Guernsey one to five digits, Alderney one to four after the printed `AY`).
        # Since the Dart stub has no explicit restriction logic here, we assume
        # the base PlateValidator handles it or it is empty.
        return None
