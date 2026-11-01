"""Port of senegal_plate/lib/src/senegal_validators.dart."""
from __future__ import annotations

import re
from typing import Literal

from plates.core.validators.plate_validator import PlateEntry, PlateValidation


class SenegalValidator:
    regions: set[str] = {
        "DK",
        "DB",
        "FK",
        "KA",
        "KL",
        "KE",
        "KD",
        "LG",
        "MT",
        "SL",
        "SE",
        "TC",
        "TH",
        "ZG",
    }

    _letters2: re.Pattern = re.compile(r"^[A-Z]{2}$")
    _letters1or2: re.Pattern = re.compile(r"^[A-Z]{1,2}$")
    _digits2: re.Pattern = re.compile(r"^[0-9]{2}$")
    _digits3: re.Pattern = re.compile(r"^[0-9]{3}$")
    _digits4: re.Pattern = re.compile(r"^[0-9]{4}$")

    def validate(self, entry: PlateEntry) -> PlateValidation:
        # Check restriction verdict if it exists on the spec
        if hasattr(entry.spec, 'restriction_verdict'):
            refused = entry.spec.restriction_verdict(entry)
            if refused is not None:
                return refused

        groups = entry.spec.text_groups
        if not groups or entry.group(groups[-1].key) == "":
            return PlateValidation.valid()

        old = entry.spec.id == "sn.old"
        for g in groups:
            value = entry.group(g.key)
            rule: tuple[re.Pattern, str] | None = None
            if g.key == "number":
                if old:
                    rule = (self._digits4, "The number is 4 digits.")
                else:
                    rule = (self._digits3, "The number is 3 digits.")
            elif g.key == "letters":
                if old:
                    rule = (self._letters1or2, "The closing series is 1 or 2 letters.")
                else:
                    rule = (self._letters2, "The closing series is 2 letters.")
            elif g.key == "series":
                rule = (self._letters2, "The series is 2 letters.")
            elif g.key == "department":
                rule = (self._digits2, "The department is 2 digits.")
            else:
                rule = None

            if rule is not None and not rule[0].match(value):
                return PlateValidation.invalid(rule[1])

        if entry.group("region") not in self.regions:
            return PlateValidation.invalid("Unknown regional code.")

        return PlateValidation.valid()
