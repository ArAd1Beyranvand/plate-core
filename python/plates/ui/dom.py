"""[D2][D8] Binds a PlateCanvas to a page under Pyodide: the SVG in a host element, one <input> per
slot input absolutely positioned over the viewBox, edits written through the controller (D7).

Everything browser-side goes through `document` (Pyodide's `js.document`) and `proxy` (Pyodide's
`create_proxy`), so tests pass fakes and the module imports without a browser."""
from __future__ import annotations

from ..core.theme.plate_theme import PlateTheme
from ..core.model.slot_behavior import SlotBehavior
from .plate_canvas import PlateCanvas
from .svg import AssetResolver, css


def browser():
    """(document, create_proxy) under Pyodide."""
    import js  # noqa: PLC0415 - only exists in the browser
    from pyodide.ffi import create_proxy  # noqa: PLC0415
    return js.document, create_proxy


def browser_timing():
    """(clock, schedule) for PlateCanvas's animator: the current frame's time, so a ghost and the plate under
    it read the same instant, and requestAnimationFrame."""
    import js  # noqa: PLC0415
    from pyodide.ffi import create_once_callable  # noqa: PLC0415
    timeline = js.document.timeline
    return lambda: timeline.currentTime or js.performance.now(), lambda fn: js.requestAnimationFrame(create_once_callable(lambda _t: fn()))


def canvas_measurer(document):
    """[H12] A text measurer over a 2D canvas context, for plates.render.text_measure."""
    ctx = document.createElement("canvas").getContext("2d")

    def measure(text: str, s: dict) -> float:
        # Not every caller's style names a family (plate_canvas's fitted-run style does not).
        family = s.get("fontFamily", "sans-serif").rsplit("/", 1)[-1]
        ctx.font = f'{s.get("fontWeight", 400)} {s["fontSize"]}px "{family}", sans-serif'
        return ctx.measureText(text).width + s.get("letterSpacing", 0) * len(text)
    return measure


class DomPlate:
    """Mounts `canvas` into `host`. Sizes are percentages of the viewBox, so the host's CSS width
    alone scales the plate; nothing is measured from layout."""

    def __init__(self, host, canvas: PlateCanvas, document=None, proxy=None,
                 resolve_asset: AssetResolver | None = None):
        if document is None:
            document, proxy = browser()
        self.host, self.canvas, self.resolve_asset = host, canvas, resolve_asset
        self.host.style.position = "relative"
        self.art = document.createElement("div")
        self.host.appendChild(self.art)
        spec = canvas.spec
        # The inputs' percentages are of the plate's own box, not the host, whose height is pinned while a swap plays.
        self.layer = document.createElement("div")
        self.layer.style.cssText = f"position:absolute;left:0;top:0;width:100%;aspect-ratio:{spec.canvas_width} / {spec.canvas_height}"
        self.host.appendChild(self.layer)
        self.inputs = {}
        for s in canvas.slot_inputs():
            e = document.createElement("input")
            st = e.style
            st.position, st.border, st.background, st.textAlign, st.padding = "absolute", "0", "transparent", "center", "0"
            st.left = f"{100 * s.box.left / spec.canvas_width}%"
            st.top = f"{100 * s.box.top / spec.canvas_height}%"
            st.width = f"{100 * s.box.width / spec.canvas_width}%"
            st.height = f"{100 * s.box.height / spec.canvas_height}%"
            st.fontSize = f"{72 * s.box.height / spec.canvas_width}cqw"
            st.fontWeight = "700"
            slot = spec.slots[s.index]
            # Transparent text: the glyphs, placeholder and underline are painted under it, in the slot's script.
            st.color, st.caretColor, st.outline = "transparent", "transparent", "none"
            e.className = "plate-slot"
            e.maxLength = slot.length
            if s.behavior in (SlotBehavior.KEYPAD_FIRST_FIELD, SlotBehavior.EXTERNAL_FIELD):
                e.inputMode = "none"  # [D8] the keypad types; the system keyboard stays down
            self._listen(e, s.index, proxy)
            self.layer.appendChild(e)
            self.inputs[s.index] = e
        self.host.style.containerType = "inline-size"
        canvas.on_render = lambda ops: self.paint()
        self.paint()

    def _listen(self, e, index: int, proxy) -> None:
        def edited(_event=None) -> None:
            if not self.canvas.controller.set_at(index, e.value or None):
                self._sync()
        self._proxy = getattr(self, "_proxy", [])
        self._proxy.append(proxy(edited) if proxy else edited)
        e.addEventListener("input", self._proxy[-1])

    def _sync(self) -> None:
        values = self.canvas.controller.values
        for i, e in self.inputs.items():
            v = values[i] or ""
            if e.value != v:
                e.value = v

    def paint(self) -> None:
        self.art.innerHTML = self.canvas.svg(self.resolve_asset)
        self._sync()

    def dispose(self) -> None:
        self.canvas.dispose()
        for p in getattr(self, "_proxy", []):
            if hasattr(p, "destroy"):
                p.destroy()
        self.host.innerHTML = ""
