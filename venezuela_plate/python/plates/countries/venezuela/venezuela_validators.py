"""Port of venezuela_plate/lib/src/venezuela_validators.dart."""
from __future__ import annotations

from dataclasses import dataclass

from plates.core.validators.plate_validator import GatedPlateValidator, PlateEntry, PlateValidation

STATE_CODES = frozenset('ABCDEFGHIJKLMNOPRSTUVWXY')


@dataclass(frozen=True)
class VenezuelaCategory:
    name: str
    pattern: str

    def matches(self, serial: str) -> bool:
        if len(serial) != len(self.pattern):
            return False
        for c, p in zip(serial, self.pattern):
            if p == 'L':
                ok = 'A' <= c <= 'Z'
            elif p == 'D':
                ok = '0' <= c <= '9'
            else:
                ok = c == p
            if not ok:
                return False
        return True


class VenezuelaValidator(GatedPlateValidator):
    gate_group = 'state'

    categories = (
        VenezuelaCategory('Private car', 'LLDDDL'),
        VenezuelaCategory('Motorcycle', 'LLDLDD'),
        VenezuelaCategory('Freight', 'LDDLLD'),
        VenezuelaCategory('Crane', 'LDDLDD'),
        VenezuelaCategory('School transport', 'LDDDLD'),
        VenezuelaCategory('Private transport', 'LDDDDL'),
        VenezuelaCategory('Tourist transport, rustic', 'LDLLDD'),
        VenezuelaCategory('Tourist transport, minibus', 'LDDLDL'),
        VenezuelaCategory('Tourist transport, bus', 'LDLDLD'),
        VenezuelaCategory('Urban public transport', '0DLLDL'),
        VenezuelaCategory('Suburban public transport, car', '1DLDLD'),
        VenezuelaCategory('Suburban public transport, minibus', '2DLDDL'),
        VenezuelaCategory('Suburban public transport, bus', '3DLLDD'),
        VenezuelaCategory('Intercity public transport, car', '4DDLDL'),
        VenezuelaCategory('Intercity public transport, minibus', '5DDLLD'),
        VenezuelaCategory('Intercity public transport, bus', '6DDDLD'),
        VenezuelaCategory('Taxi', '7LDLDL'),
        VenezuelaCategory('Peripheral public transport, rustic', '8LDLDD'),
        VenezuelaCategory('Peripheral public transport, minibus', '9LDDDL'),
    )

    REASON_SERIAL_LENGTH = 'The serial fills every cell.'
    REASON_NO_CATEGORY = "The letters and digits are in no category's order."
    REASON_STATE = 'The last letter names no state.'

    @classmethod
    def category_of(cls, serial: str) -> VenezuelaCategory | None:
        return next((c for c in cls.categories if c.matches(serial)), None)

    def judge(self, entry: PlateEntry) -> PlateValidation:
        serial = entry.group('serial')
        if len(serial) != 6:
            return PlateValidation.invalid(self.REASON_SERIAL_LENGTH)
        if entry.group('state') not in STATE_CODES:
            return PlateValidation.invalid(self.REASON_STATE)
        if self.category_of(serial) is None:
            return PlateValidation.invalid(self.REASON_NO_CATEGORY)
        return PlateValidation.valid()
