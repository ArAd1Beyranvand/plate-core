"""[W8] The component side of the plate-embed protocol (ports/web/protocol.md; ports/web/embed-client/client.ts).

`env` is the page seam (see browser.py): post(message, origin), on_message(fn), height(), on_resize(fn)."""
from __future__ import annotations

from typing import Any, Callable

C2H = ("hello", "ready", "resize", "change", "progress", "error")
H2C = ("init", "action")
LANGS = ("flutter", "typescript", "kotlin", "python")
ACTIONS = ("setSpec", "setValues", "clear", "focus", "setTheme", "leave")


def _str(x) -> bool:
    return isinstance(x, str)


def _num(x) -> bool:
    return isinstance(x, (int, float)) and not isinstance(x, bool) and x == x and abs(x) != float("inf")


def _height(x) -> bool:
    return _num(x) and x >= 0


def _values(x) -> bool:
    return isinstance(x, list) and all(e is None or _str(e) for e in x)


PAYLOADS: dict[str, Callable[[dict], bool]] = {
    "hello": lambda p: p.get("lang") in LANGS and _str(p.get("country")) and _str(p.get("version")),
    "ready": lambda p: isinstance(p.get("specs"), list) and all(
        isinstance(s, dict) and _str(s.get("id")) and _str(s.get("label")) for s in p["specs"])
        and _str(p.get("spec")) and _height(p.get("height")),
    "resize": lambda p: _height(p.get("height")),
    "change": lambda p: _str(p.get("spec")) and _values(p.get("values")) and _str(p.get("text"))
        and isinstance(p.get("complete"), bool) and (p.get("valid") is None or isinstance(p["valid"], bool)),
    "progress": lambda p: _str(p.get("stage")) and (
        p.get("fraction") is None or _num(p["fraction"]) and 0 <= p["fraction"] <= 1),
    "error": lambda p: _str(p.get("code")) and _str(p.get("message")) and isinstance(p.get("fatal"), bool),
    "init": lambda p: (("spec" not in p) or _str(p["spec"])) and (("values" not in p) or _values(p["values"]))
        and p.get("theme") in ("light", "dark") and _str(p.get("locale")) and isinstance(p.get("keypad"), bool),
    "action": lambda p: p.get("name") in ACTIONS and isinstance(p.get("args"), dict),
}


def validate(direction: str, m: Any) -> bool:
    """True iff `m` is a well-formed message travelling `direction` ("C2H" or "H2C")."""
    if not isinstance(m, dict) or m.get("ns") != "plate-embed" or not _str(m.get("type")):
        return False
    v = m.get("v")
    if type(v) is not int or v != 1 or not isinstance(m.get("payload"), dict):
        return False
    return m["type"] in (C2H if direction == "C2H" else H2C) and bool(PAYLOADS[m["type"]](m["payload"]))


class Client:
    """Wires a component to its host. `init(payload)` and `action(name, args)` are the handlers.
    Replies go only to the origin of the first valid `init` (before it, to the build-time gallery origin)."""

    def __init__(self, info: dict, init: Callable[[dict], None], action: Callable[[str, dict], None], env):
        self.info, self.env, self._init, self._action = info, env, init, action
        self.host: str | None = None
        self._last = -1
        env.on_message(self._received)
        env.on_resize(self._report)

    def _send(self, type: str, payload: dict) -> None:
        self.env.post({"ns": "plate-embed", "v": 1, "type": type, "payload": payload}, self.host or self.env.gallery_origin)

    def _received(self, from_parent: bool, origin: str, data: Any) -> None:
        if not from_parent or (self.host is not None and origin != self.host) or not validate("H2C", data):
            return
        p = data["payload"]
        if data["type"] == "init":
            self.host = self.host or origin
            self._init(p)
        elif self.host is not None:
            self._action(p["name"], p["args"])

    def _report(self) -> None:
        h = int(self.env.height())
        if h != self._last and self.host is not None:
            self._last = h
            self._send("resize", {"height": h})

    def hello(self) -> None:
        self._send("hello", self.info)

    def ready(self, specs: list[dict], spec: str) -> None:
        self._send("ready", {"specs": specs, "spec": spec, "height": int(self.env.height())})

    def progress(self, stage: str, fraction: float | None = None) -> None:
        self._send("progress", {"stage": stage, "fraction": fraction})

    def change(self, state: dict) -> None:
        self._send("change", state)

    def error(self, code: str, message: str, fatal: bool = False) -> None:
        self._send("error", {"code": code, "message": message, "fatal": fatal})
