"""Runtime for `[D4-table]` resolvers: the generated country modules hold only the rows."""
from __future__ import annotations


def _lookup(reads, cut, default, rows):
    def get(group):
        key = tuple(group(g)[:cut[g]] if g in cut else group(g) for g in reads)
        return rows.get(key, default)
    return get


def label_table(reads, cut, default, rows):
    """A label resolver: `group(key) -> str | None`."""
    return _lookup(reads, cut, default, rows)


def theme_table(reads, cut, default, rows):
    """A theme resolver: `(base, group) -> PlateTheme`; each row value is a patch of theme fields."""
    get = _lookup(reads, cut, default, rows)
    return lambda base, group: base.copy_with(**(get(group) or {}))
