"""Port of cuba_plate/lib/src/cuba_validators.dart. Hand-ported; codegen never overwrites this file."""
from __future__ import annotations

from plates.core.validators.plate_validator import GatedPlateValidator, PlateEntry, PlateValidation, is_digits

_LETTERS = "ABCDEFGHJKLMNPRTUVXY"


class CubaValidator(GatedPlateValidator):
    gate_group = 'serial'

    REASON_LETTER_MISSING = "A plate starts with a letter."
    REASON_LETTER_UNISSUED = "I, O, Q, S, W and Z are not issued."
    REASON_SERIAL_NOT_NUMERIC = "The number is digits only."
    REASON_SERIAL_LENGTH = "The number fills every cell."

    def judge(self, entry: PlateEntry) -> PlateValidation:
        letter = entry.group("letter")
        if not letter:
            return PlateValidation.invalid(self.REASON_LETTER_MISSING)
        if letter.upper() not in _LETTERS or len(letter) != 1:
            return PlateValidation.invalid(self.REASON_LETTER_UNISSUED)
        serial = entry.group("serial") + entry.group("serial2")
        if len(serial) != len(entry.spec.slots) - 1:
            return PlateValidation.invalid(self.REASON_SERIAL_LENGTH)
        if not is_digits(serial):
            return PlateValidation.invalid(self.REASON_SERIAL_NOT_NUMERIC)
        return PlateValidation.valid()
