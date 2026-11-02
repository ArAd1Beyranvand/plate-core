"""Just enough page for plates.embed: a DOM of recording elements and a FakeEnv for the host side."""
from types import SimpleNamespace


class El:
    def __init__(self, tag):
        self.tag, self.children, self.listeners, self.attrs = tag, [], {}, {}
        self.value, self.innerHTML, self.textContent = "", "", ""
        self.style = SimpleNamespace()
        self.dataset = SimpleNamespace()
        self.removed = False
        self.scrollHeight = 100
        self.offsetHeight = 0

    @property
    def firstElementChild(self):
        return self.children[0] if self.children else None

    def appendChild(self, c):
        self.children.append(c)

    def setAttribute(self, k, v):
        self.attrs[k] = v

    def addEventListener(self, kind, fn):
        self.listeners.setdefault(kind, []).append(fn)

    def fire(self, kind, event=None):
        for fn in list(self.listeners.get(kind, [])):
            fn(event)

    def focus(self):
        self.fire("focus")

    def remove(self):
        self.removed = True


class Doc:
    def __init__(self):
        self.documentElement, self.byId = El("html"), {"app": El("div"), "splash": El("div")}

    def createElement(self, tag):
        return El(tag)

    def getElementById(self, id):
        return self.byId.get(id)


class FakeEnv:
    """The page seam of plates.embed.browser, with the host on the other end of `sent` / `deliver`."""

    gallery_origin = "https://gallery.test"
    proxy = None
    greeted = False

    def __init__(self):
        self.document, self.sent, self.theme, self.later = Doc(), [], None, []
        self.root = self.document.byId["app"]
        self._listen = self._resize = None

    def post(self, message, origin):
        self.sent.append((message, origin))

    def types(self):
        return [m["type"] for m, _ in self.sent]

    def last(self, type):
        return next(m["payload"] for m, _ in reversed(self.sent) if m["type"] == type)

    def on_message(self, fn):
        self._listen = fn

    def on_resize(self, fn):
        self._resize = fn

    def deliver(self, type, payload, origin="https://host.test", from_parent=True, v=1):
        self._listen(from_parent, origin, {"ns": "plate-embed", "v": v, "type": type, "payload": payload})

    def height(self):
        return self.document.documentElement.scrollHeight

    def set_theme(self, theme):
        self.theme = theme

    def remove_splash(self):
        self.document.byId["splash"].remove()

    def now(self):
        return 0.0

    def schedule(self, fn):
        self.later.append(fn)

    def set_timeout(self, fn, ms):
        fn()

    def clear_timeout(self, handle):
        pass
