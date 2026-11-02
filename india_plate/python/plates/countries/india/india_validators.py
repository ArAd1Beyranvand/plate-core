"""Port of india_plate/lib/src/india_validators.dart."""
from __future__ import annotations

import re

from plates.core.validators.plate_validator import PlateEntry, PlateValidation

STATE_NAMES = {
    'AN': 'Andaman and Nicobar Islands',
    'AP': 'Andhra Pradesh',
    'AR': 'Arunachal Pradesh',
    'AS': 'Assam',
    'BR': 'Bihar',
    'CG': 'Chhattisgarh',
    'CH': 'Chandigarh',
    'DD': 'Dadra and Nagar Haveli and Daman and Diu',
    'DL': 'Delhi',
    'GA': 'Goa',
    'GJ': 'Gujarat',
    'HP': 'Himachal Pradesh',
    'HR': 'Haryana',
    'JH': 'Jharkhand',
    'JK': 'Jammu and Kashmir',
    'KA': 'Karnataka',
    'KL': 'Kerala',
    'LA': 'Ladakh',
    'LD': 'Lakshadweep',
    'MH': 'Maharashtra',
    'ML': 'Meghalaya',
    'MN': 'Manipur',
    'MP': 'Madhya Pradesh',
    'MZ': 'Mizoram',
    'NL': 'Nagaland',
    'OD': 'Odisha',
    'PB': 'Punjab',
    'PY': 'Puducherry',
    'RJ': 'Rajasthan',
    'SK': 'Sikkim',
    'TG': 'Telangana',
    'TN': 'Tamil Nadu',
    'TR': 'Tripura',
    'UK': 'Uttarakhand',
    'UP': 'Uttar Pradesh',
    'WB': 'West Bengal',
    'UA': 'Uttaranchal (former)',
    'OR': 'Orissa (former)',
    'DN': 'Dadra and Nagar Haveli (former)',
    'TS': 'Telangana (former)',
}

MILITARY_CLASSES = {
    'A': 'Motorised two-wheeler',
    'B': 'Light motor vehicle',
    'C': 'Truck under 3 t or pick-up',
    'D': 'Truck over 3 t',
    'E': 'High-mobility vehicle',
    'F': 'Light specialist vehicle',
    'G': 'Trailer',
    'H': 'Truck with material handling',
    'J': 'Snow removal vehicle',
    'K': 'Ambulance',
    'P': 'Generic support vehicle',
    'Q': 'Construction vehicle',
    'R': 'Customised vehicle',
    'X': 'Active combat vehicle',
}

TRADE_CATEGORIES = {
    'A': 'Two-wheeler',
    'B': 'Invalid carriage',
    'C': 'Light motor vehicle',
    'D': 'Medium passenger vehicle',
    'E': 'Medium goods vehicle',
    'F': 'Heavy passenger vehicle',
    'G': 'Heavy goods vehicle',
    'H': 'E-rickshaw',
    'I': 'E-cart',
    'J': 'Other',
}

MISSIONS = {
    'CD': 'Embassy',
    'CC': 'Consulate',
    'UN': 'United Nations',
}


def _int(s: str) -> int | None:
    """Dart int.tryParse for ASCII input."""
    return int(s) if re.fullmatch(r'[+-]?[0-9]+', s) else None


class IndiaValidator:
    REASON_STATE = 'Not a state or union-territory code.'
    REASON_RTO = 'RTO number 00 is not issued.'
    REASON_NUMBER = 'Number 0000 is not issued.'
    REASON_MONTH = 'The month is not 01–12.'
    REASON_CLASS = 'Not an armed-forces vehicle class.'
    REASON_MISSION = 'Mission type is CD, CC or UN.'
    REASON_CATEGORY = 'Trade category is A to J.'

    def validate(self, entry: PlateEntry) -> PlateValidation:
        slots = entry.spec.slots
        if len(entry.values) < len(slots) or not all(s.is_complete(entry.values[i]) for i, s in enumerate(slots)):
            return PlateValidation.valid()
        keys = {g.key for g in entry.spec.effective_text_groups}
        g = entry.group
        if 'state' in keys and g('state') not in STATE_NAMES:
            return PlateValidation.invalid(self.REASON_STATE)
        if 'rto' in keys and g('rto') == '00':
            return PlateValidation.invalid(self.REASON_RTO)
        if 'number' in keys and _int(g('number')) == 0:
            return PlateValidation.invalid(self.REASON_NUMBER)
        if 'date' in keys:
            month = _int(g('date')[:2]) or 0
            if month < 1 or month > 12:
                return PlateValidation.invalid(self.REASON_MONTH)
        if 'class' in keys and g('class') not in MILITARY_CLASSES:
            return PlateValidation.invalid(self.REASON_CLASS)
        if 'type' in keys and g('type') not in MISSIONS:
            return PlateValidation.invalid(self.REASON_MISSION)
        if 'category' in keys and g('category') not in TRADE_CATEGORIES:
            return PlateValidation.invalid(self.REASON_CATEGORY)
        return PlateValidation.valid()
