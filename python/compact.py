"""Country data v2: a verbose `ports/data/countries/<package>.json` object as trimmed tuples, so a generated module
carries what differs from the defaults and nothing else. `plates/countries/expand.py` is the exact inverse, and
`typescript/codegen/compact.mjs` writes the same bytes: the three must agree on every country."""
from __future__ import annotations

import json
from copy import deepcopy
from fractions import Fraction

from plates.countries.expand import ALERT, INACTIVE, KINDS


def _round(x):
    """Plate units are millimetres: four decimals is far below anything a plate can show. Halves round up, as in JS."""
    if isinstance(x, float):
        n = int(abs(Fraction(x)) * 10000 + Fraction(1, 2))
        n = n if x >= 0 else -n
        return n // 10000 if n % 10000 == 0 else n / 10000
    if isinstance(x, list):
        return [_round(i) for i in x]
    return {k: _round(v) for k, v in x.items()} if isinstance(x, dict) else x


def _default(kind, i, o):
    d = (KINDS[kind][i] + (None,))[1]
    return o[d[1:]] if isinstance(d, str) and d[:1] == "@" else deepcopy(d)


def _tuple(kind, src):
    """One verbose dict -> its tuple: children encoded, trailing defaults trimmed."""
    o, fields = dict(src), KINDS[kind]
    for i, f in enumerate(fields):
        o.setdefault(f[0], _default(kind, i, o))
    out = []
    for name, *rest in fields:
        child = rest[1] if len(rest) > 1 else None
        v = o[name]
        out.append(v if child is None or v is None else
                   [_tuple(child[:-2], x) for x in v] if child.endswith("[]") else _tuple(child, v))
    while out and o[fields[len(out) - 1][0]] == _default(kind, len(out) - 1, o):
        out.pop()
    return out


def _alphabet_tokens(chars):
    """Runs of consecutive BMP code points become [lo, hi]; anything else stays a literal entry."""
    cp = [ord(c) if len(c) == 1 and ord(c) < 0xD800 else None for c in chars]
    out, i = [], 0
    while i < len(chars):
        j = i
        while j + 1 < len(chars) and cp[j] is not None and cp[j + 1] == cp[j] + 1:
            j += 1
        out += [[chars[i], chars[j]]] if j - i >= 2 else chars[i:j + 1]
        i = j + 1
    return out


def _theme(t):
    t = {k: v for k, v in t.items() if k != "names"}
    if not t["plateBorder"] == t["ink"] == t["dividerColor"] == t["activeColor"]:
        return t
    out = [t["plateBackground"], t["ink"], t["borderWidthRatio"], t["plateRadiusRatio"], t["inactiveColor"], t["alertColor"]]
    if out[5] == ALERT:
        out.pop()
    if len(out) == 5 and out[4] == INACTIVE:
        out.pop()
    return out


def _trie(rows, default):
    """A table keyed by one string, as the prefixes whose every key shares a value plus the exact keys that break the
    pattern; exact over every string of the keys' own characters up to their length. None when that domain is too big."""
    keys = {k[0]: v for k, v in rows}
    chars = sorted({c for k in keys for c in k})
    depth = max(map(len, keys))
    if sum(len(chars) ** n for n in range(depth + 1)) > 200000:
        return None
    f = lambda s: keys.get(s, default)
    prefix, exact = [], []

    def uniform(p):
        """The one value f takes on p and everything beneath it, else the sentinel."""
        v = f(p)
        return v if len(p) == depth or all(uniform(p + c) == v for c in chars) else uniform

    def walk(p):
        v = uniform(p)
        if v is not uniform:
            if v != default:
                prefix.append([p, v])
        else:
            if f(p) != default:
                exact.append([p, f(p)])
            for c in chars:
                walk(p + c)
    walk("")
    return {"trie": {"prefix": prefix, "exact": exact}}


def _size(x):
    return len(json.dumps(x, separators=(",", ":"), ensure_ascii=False))


def _resolver(r):
    if r["kind"] == "code":
        return ["code", r["signature"]]
    single = len(r["reads"]) == 1 and not r["cut"] and all(len(k) == 1 and isinstance(k[0], str) for k, _ in r["table"])
    by_value = {}
    for k, v in r["table"]:
        by_value.setdefault(json.dumps(v), []).append(k)
    grouped = {"groups": [[json.loads(v), ks] for v, ks in by_value.items()]}
    tried = _trie(r["table"], r["default"]) if single else None
    body = tried if tried and _size(tried) <= _size(grouped) else grouped
    return ["table", r["signature"], r["reads"], r["cut"], r["default"], body]


def compact_country(d):
    """`d` is the verbose country with its alphabets inlined (ref -> alphabet), as the generators build it."""
    d = _round(d)
    specs = []
    for s in d["specs"]:
        g = s["textGroups"]
        keyed = bool(g) and len(g) == len(s["slots"]) and all(
            x["indices"] == [i] and x["prefix"] == "" and x["key"] is not None for i, x in enumerate(g))
        specs.append(_tuple("spec", {
            **s, "panel": None if s["noPanel"] else s["panel"],
            "slots": [{**x, "group": g[i]["key"]} for i, x in enumerate(s["slots"])] if keyed else s["slots"],
            "textGroups": None if keyed or not g else g}))
    return {
        "package": d["package"],
        "alphabets": {k: _tuple("alphabet", {**a, "chars": _alphabet_tokens(a["characters"])}) for k, a in d["alphabets"].items()},
        "countries": {k: _tuple("country", c) for k, c in d["countries"].items()},
        "themes": {k: _theme(t) for k, t in d["themes"].items()},
        "specs": specs,
        "resolvers": {k: _resolver(r) for k, r in d["resolvers"].items()},
        "assets": d["assets"],
        "gallery": [_tuple("gallery", g) for g in d["gallery"]],
    }
