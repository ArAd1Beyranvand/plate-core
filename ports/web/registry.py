#!/usr/bin/env python3
"""Scan a deploy tree for built components and write components/index.json (WEB_ARCH "Registry").

  registry.py [--deploy deploy] [--check] [--self-test]

Layout scanned: <deploy>/components/<country>/<lang>/index.html. Missing country x language
pairs are simply absent. --check validates the existing index.json against components.schema.json.
"""
import argparse, hashlib, json, re, sys, tempfile
from datetime import datetime, timezone
from pathlib import Path

HERE = Path(__file__).parent
LANGS = ("flutter", "typescript", "kotlin", "python")
SLUG = re.compile(r"^[a-z0-9]+(-[a-z0-9]+)*$")


def scan(deploy: Path) -> dict:
    out = {}
    root = deploy / "components"
    for cdir in sorted(p for p in root.glob("*") if p.is_dir() and SLUG.match(p.name)):
        for lang in LANGS:
            d = cdir / lang
            if not (d / "index.html").is_file():
                continue
            files = sorted(f for f in d.rglob("*") if f.is_file())
            h = hashlib.sha256()
            for f in files:
                h.update(f.relative_to(d).as_posix().encode() + b"\0" + f.read_bytes() + b"\0")
            out.setdefault(cdir.name, {})[lang] = {
                "url": f"/components/{cdir.name}/{lang}/", "hash": h.hexdigest()[:8],
                "size": sum(f.stat().st_size for f in files)}
    return out


def generate(deploy: Path) -> dict:
    return {"version": 1, "generated": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
            "components": scan(deploy)}


def validate(data, schema, path="$") -> list:
    """Minimal JSON-schema subset: type, const, enum, pattern, minLength, required, properties,
    additionalProperties (bool or schema), propertyNames. Returns error strings."""
    errs = []
    t = schema.get("type")
    kinds = {"object": dict, "string": str, "integer": int}
    if t and (not isinstance(data, kinds[t]) or isinstance(data, bool)):
        return [f"{path}: expected {t}"]
    if "const" in schema and data != schema["const"]:
        errs.append(f"{path}: expected {schema['const']!r}")
    if "enum" in schema and data not in schema["enum"]:
        errs.append(f"{path}: {data!r} not in {schema['enum']}")
    if isinstance(data, str):
        if "pattern" in schema and not re.search(schema["pattern"], data):
            errs.append(f"{path}: {data!r} does not match {schema['pattern']}")
        if len(data) < schema.get("minLength", 0):
            errs.append(f"{path}: too short")
    if isinstance(data, dict):
        errs += [f"{path}: missing {k}" for k in schema.get("required", []) if k not in data]
        props, extra = schema.get("properties", {}), schema.get("additionalProperties", True)
        for k, v in data.items():
            if "propertyNames" in schema:
                errs += validate(k, schema["propertyNames"], f"{path}.<key {k}>")
            if k in props:
                errs += validate(v, props[k], f"{path}.{k}")
            elif extra is False:
                errs.append(f"{path}: unexpected {k}")
            elif isinstance(extra, dict):
                errs += validate(v, extra, f"{path}.{k}")
    return errs


def check(index: Path) -> list:
    schema = json.loads((HERE / "components.schema.json").read_text())
    return validate(json.loads(index.read_text()), schema)


# Reference receiver for protocol_vectors.json (rules in protocol.md).
_C2H = {"hello", "ready", "resize", "change", "progress", "error"}
_H2C = {"init", "action"}


def _num(x):
    return isinstance(x, (int, float)) and not isinstance(x, bool)


def _vals(x):
    return isinstance(x, list) and all(e is None or isinstance(e, str) for e in x)


def _specs(x):
    return isinstance(x, list) and all(isinstance(s, dict) and isinstance(s.get("id"), str)
                                       and isinstance(s.get("label"), str) for s in x)


_PAYLOAD = {
    "hello": lambda p: p.get("lang") in LANGS and isinstance(p.get("country"), str) and isinstance(p.get("version"), str),
    "ready": lambda p: _specs(p.get("specs")) and isinstance(p.get("spec"), str) and _num(p.get("height")) and p["height"] >= 0,
    "resize": lambda p: _num(p.get("height")) and p["height"] >= 0,
    "change": lambda p: isinstance(p.get("spec"), str) and _vals(p.get("values")) and isinstance(p.get("text"), str)
        and isinstance(p.get("complete"), bool) and "valid" in p and (p["valid"] is None or isinstance(p["valid"], bool)),
    "progress": lambda p: isinstance(p.get("stage"), str) and "fraction" in p
        and (p["fraction"] is None or (_num(p["fraction"]) and 0 <= p["fraction"] <= 1)),
    "error": lambda p: all(isinstance(p.get(k), t) for k, t in (("code", str), ("message", str), ("fatal", bool))),
    "init": lambda p: (p.get("spec") is None or isinstance(p["spec"], str)) and (p.get("values") is None or _vals(p["values"]))
        and p.get("theme") in ("light", "dark") and isinstance(p.get("locale"), str) and isinstance(p.get("keypad"), bool),
    "action": lambda p: p.get("name") in ("setSpec", "setValues", "clear", "focus", "setTheme", "leave") and isinstance(p.get("args"), dict),
}


def valid_message(direction: str, m) -> bool:
    if not (isinstance(m, dict) and m.get("ns") == "plate-embed" and m.get("v") == 1
            and isinstance(m.get("type"), str) and isinstance(m.get("payload"), dict)):
        return False
    return m["type"] in (_C2H if direction == "C2H" else _H2C) and bool(_PAYLOAD[m["type"]](m["payload"]))


def self_test() -> None:
    cases = json.loads((HERE / "protocol_vectors.json").read_text())["cases"]
    bad = [c["name"] for c in cases if valid_message(c["dir"], c["message"]) != c["valid"]]
    assert not bad, f"vector mismatches: {bad}"
    assert any(c["valid"] for c in cases) and any(not c["valid"] for c in cases)

    with tempfile.TemporaryDirectory() as tmp:
        deploy = Path(tmp)
        for country, lang, stray in [("germany", "typescript", False), ("germany", "python", False),
                                     ("india", "flutter", False), ("france", "kotlin", True)]:
            d = deploy / "components" / country / lang
            d.mkdir(parents=True)
            (d / ("junk.txt" if stray else "index.html")).write_text(country + lang)
        (deploy / "components" / "Bad_Slug" / "python").mkdir(parents=True)
        (deploy / "components" / "Bad_Slug" / "python" / "index.html").write_text("x")
        data = generate(deploy)
        comps = data["components"]
        assert set(comps) == {"germany", "india"}, comps
        assert set(comps["germany"]) == {"typescript", "python"} and set(comps["india"]) == {"flutter"}
        assert comps["india"]["flutter"]["url"] == "/components/india/flutter/"
        index = deploy / "components" / "index.json"
        index.write_text(json.dumps(data))
        assert check(index) == [], check(index)
        before = comps["germany"]["python"]["hash"]
        (deploy / "components/germany/python/index.html").write_text("changed")
        assert scan(deploy)["germany"]["python"]["hash"] != before
        assert scan(deploy / "nowhere") == {}
        ok = {"url": "/components/germany/python/", "hash": "abcdef"}
        for broken in (dict(data, version=2),
                       dict(data, components={"Germany": {}}),
                       dict(data, components={"germany": {"cobol": ok}}),
                       dict(data, components={"germany": {"python": dict(ok, url="/x")}}),
                       dict(data, components={"germany": {"python": dict(ok, hash="ab")}}),
                       {"components": {}}):
            index.write_text(json.dumps(broken))
            assert check(index), broken
    print("registry self-test ok")


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--deploy", type=Path, default=Path("deploy"))
    ap.add_argument("--check", action="store_true", help="validate index.json against the schema")
    ap.add_argument("--self-test", action="store_true")
    a = ap.parse_args()
    if a.self_test:
        self_test()
        return 0
    index = a.deploy / "components" / "index.json"
    if a.check:
        errs = check(index)
        print("\n".join(errs) or "ok")
        return 1 if errs else 0
    index.parent.mkdir(parents=True, exist_ok=True)
    data = generate(a.deploy)
    index.write_text(json.dumps(data, indent=1) + "\n")
    print(f"{index}: {sum(len(v) for v in data['components'].values())} components")
    return 0


if __name__ == "__main__":
    sys.exit(main())
