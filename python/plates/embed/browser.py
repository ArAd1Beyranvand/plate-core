"""[W11] The shell's page seam under Pyodide. `js.plateBridge` (web/boot.js) already said hello, queued early
messages and holds the build-time gallery origin; messages cross it as JSON text, so no FFI conversion."""
from __future__ import annotations

import json

from ..render.text_measure import set_text_measurer
from ..ui.dom import browser, browser_timing, canvas_measurer


class BrowserEnv:
    def __init__(self):
        import js  # noqa: PLC0415 - only exists in the browser
        from pyodide.ffi import create_once_callable  # noqa: PLC0415
        self.js, self.once = js, create_once_callable
        self.document, self.proxy = browser()
        self.bridge = js.plateBridge
        self.root = self.document.getElementById("app")
        self.now, self.schedule = browser_timing()
        self.greeted, self.gallery_origin = bool(self.bridge.greeted), str(self.bridge.galleryOrigin)
        set_text_measurer(canvas_measurer(self.document))

    def post(self, message: dict, origin: str) -> None:
        self.bridge.post(json.dumps(message), origin)

    def on_message(self, fn) -> None:
        def received(from_parent: bool, origin: str, text: str) -> None:
            try:
                data = json.loads(text)
            except ValueError:
                return
            fn(from_parent, origin, data)
        self.bridge.listen(self.proxy(received))

    def height(self) -> float:
        return self.document.body.offsetHeight

    def on_resize(self, fn) -> None:
        self.js.ResizeObserver.new(self.proxy(lambda *_: fn())).observe(self.document.body)

    def set_theme(self, theme: str) -> None:
        root = self.document.documentElement
        root.dataset.theme, root.style.colorScheme = theme, theme

    def set_timeout(self, fn, ms: float):
        return self.js.setTimeout(self.once(fn), ms)

    def clear_timeout(self, handle) -> None:
        self.js.clearTimeout(handle)

    def remove_splash(self) -> None:
        splash = self.document.getElementById("splash")
        if splash:
            splash.remove()
