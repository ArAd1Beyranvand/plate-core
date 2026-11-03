"""Runtime for `[D4-table]` resolvers: the generated country modules hold only the rows, listed by value or as a trie."""
from __future__ import annotations

import re

_MISS = object()


def _rows(enc):
    """key (a tuple of the strings of the groups read) -> its row, else _MISS. A trie lists the prefixes whose every key
    shares a value, then the exact keys that differ; the longest prefix wins."""
    if "trie" in enc:
        exact, prefix = dict(enc["trie"]["exact"]), dict(enc["trie"]["prefix"])

        def get(key):
            s = key[0]
            if s in exact:
                return exact[s]
            return next((prefix[s[:n]] for n in range(len(s), -1, -1) if s[:n] in prefix), _MISS)
        return get
    rows = {tuple(k): v for v, keys in enc["groups"] for k in keys}
    return lambda key: rows.get(key, _MISS)


def _lookup(reads, cut, default, enc):
    row = _rows(enc)

    def get(group):
        value = row(tuple(group(g)[:cut[g]] if g in cut else group(g) for g in reads))
        return default if value is _MISS else value
    return get


def label_table(reads, cut, default, enc):
    """A label resolver: `group(key) -> str | None`."""
    return _lookup(reads, cut, default, enc)


def theme_table(reads, cut, default, enc):
    """A theme resolver: `(base, group) -> PlateTheme`; each row value is a patch of theme fields (camelCase)."""
    get = _lookup(reads, cut, default, enc)
    snake = lambda k: re.sub(r"[A-Z]", lambda m: "_" + m.group().lower(), k)
    return lambda base, group: base.copy_with(**{snake(k): v for k, v in (get(group) or {}).items()})
