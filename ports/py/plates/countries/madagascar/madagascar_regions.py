"""Port of madagascar_plate/lib/src/madagascar_regions.dart (the `[D4-code]` resolver)."""
from __future__ import annotations

_PROVINCES = {
    "A": "Toamasina", "D": "Antsiranana", "F": "Fianarantsoa",
    "M": "Mahajanga", "T": "Antananarivo", "U": "Toliara",
}


class MadagascarRegions:
    @staticmethod
    def temporary_caption_of(group):
        """For the temporary plate: the province letter after `WW`."""
        series = group("series")
        return _PROVINCES.get(series[2]) if len(series) == 3 and series.startswith("WW") else None
