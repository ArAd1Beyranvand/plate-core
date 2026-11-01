"""Port of dominican_republic_plate/lib/src/dominican_republic_validators.dart."""
from __future__ import annotations

import re
from plates.core.validators.plate_validator import GatedPlateValidator, PlateEntry, PlateValidation, is_digits_of_length


class DominicanRepublicValidator(GatedPlateValidator):
    gate_group = "last"
    reason = "A plate is two fields of three digits."

    def judge(self, entry: PlateEntry) -> PlateValidation:
        first, last = entry.group("first"), entry.group("last")
        return (
            PlateValidation.valid()
            if is_digits_of_length(first, 3) and is_digits_of_length(last, 3)
            else PlateValidation.invalid(self.reason)
        )


class DominicanRepublicLetteredValidator(GatedPlateValidator):
    gate_group = "tail"
    reason = "A plate is a letter, two digits and four digits."
    _letter = re.compile(r"^[A-Z]$")

    def judge(self, entry: PlateEntry) -> PlateValidation:
        letter, head, tail = entry.group("letter"), entry.group("head"), entry.group("tail")
        return (
            PlateValidation.valid()
            if self._letter.fullmatch(letter) and is_digits_of_length(head, 2) and is_digits_of_length(tail, 4)
            else PlateValidation.invalid(self.reason)
        )


class DominicanRepublicExemptValidator(GatedPlateValidator):
    gate_group = "digits"
    reason = "A plate is two letters and five digits."
    _letter_pair = re.compile(r"^[A-Z]{2}$")

    def judge(self, entry: PlateEntry) -> PlateValidation:
        letters, digits = entry.group("letters"), entry.group("digits")
        return (
            PlateValidation.valid()
            if self._letter_pair.fullmatch(letters) and is_digits_of_length(digits, 5)
            else PlateValidation.invalid(self.reason)
        )
