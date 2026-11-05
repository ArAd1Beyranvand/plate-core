package plates.keypad

import kotlinx.browser.document
import kotlinx.browser.window
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import org.w3c.dom.HTMLButtonElement
import org.w3c.dom.HTMLElement

class PlateKeypadHooks(
    /** Fires with the reported key when an enabled key is tapped. */
    val onKey: ((String) -> Unit)? = null,
    /** [D7] The key to flash; each key collects it on its own so a flash repaints one key. */
    val highlighted: StateFlow<String?>? = null,
    val now: () -> Double = { window.performance.now() },
    val scope: CoroutineScope = MainScope(),
)

private class Key(private val pad: PlateKeypad, private var cell: KeyCell, private val count: Int, now: Double) {
    val el = document.createElement("button") as HTMLButtonElement
    private var shown = cell.enabled
    private var fill: ColorTween
    private var border: ColorTween
    private var ink: ColorTween
    private var turn: Job? = null
    private val watch: Job?

    init {
        el.type = "button"
        el.setAttribute("aria-label", cell.text)
        el.style.cssText = "border-radius:8px;font:500 18px system-ui;padding:0 3px;cursor:pointer;background:none;white-space:nowrap;overflow:hidden"
        if (wheelchairGlyph in cell.text) el.innerHTML = wheelchairIcon(22) else el.textContent = cell.text
        el.addEventListener("pointerdown", { it.preventDefault() })
        el.addEventListener("click", { if (cell.enabled) pad.hooks.onKey?.invoke(cell.key) })
        val t = faceTargets(pad.model.theme, lit(), shown)
        fill = ColorTween(t.fill)
        border = ColorTween(t.border)
        ink = ColorTween(t.ink)
        watch = pad.hooks.highlighted?.let { flow -> pad.hooks.scope.launch { flow.collect { retarget(pad.now(), null) } } }
        retarget(now, 0)
    }

    private fun lit() = isHighlight(pad.hooks.highlighted?.value, cell.key, pad.model.digitsOf(pad.letters))

    /** [H14] The grey-out trails the real enabled state by a per-key stagger. */
    fun setCell(next: KeyCell) {
        cell = next
        if (next.enabled == shown) {
            turn?.cancel()
            turn = null
        } else if (turn == null) {
            turn = pad.hooks.scope.launch {
                delay(turnDelayMs(next.enabled, next.index, count))
                turn = null
                shown = cell.enabled
                retarget(pad.now(), null)
            }
        }
    }

    private fun retarget(now: Double, ms: Long?) {
        val t = faceTargets(pad.model.theme, lit(), shown)
        fill.set(t.fill, now, ms ?: t.ms)
        border.set(t.border, now, ms ?: t.ms)
        ink.set(t.ink, now, ms ?: t.ms)
        pad.wake()
    }

    fun paint(now: Double, presence: Double): Boolean {
        val s = el.style
        val f = fill.value(now)
        s.setProperty("background", cssColor(f))
        s.setProperty("border", "1px solid ${cssColor(border.value(now))}")
        s.setProperty("color", cssColor(ink.value(now)))
        val press = 1 - 0.06 * (((f shr 24) and 255) / 255.0)
        s.setProperty("transform", "scale(${press * (0.6 + 0.4 * presence)})")
        s.setProperty("opacity", presence.toString())
        s.setProperty("pointer-events", if (presence < 1) "none" else "")
        return fill.running(now) || border.running(now) || ink.running(now)
    }

    fun dispose() {
        turn?.cancel()
        watch?.cancel()
    }
}

/** [D8] A soft keyboard of DOM buttons; pointerdown is cancelled so the slot input keeps focus. */
class PlateKeypad(options: PlateKeypadOptions, val hooks: PlateKeypadHooks = PlateKeypadHooks()) {
    val el = document.createElement("div") as HTMLElement
    val model = KeypadModel(options)
    var letters = options.showLetters
        private set
    private val grid = document.createElement("div") as HTMLElement
    private var keys = emptyList<Key>()
    private var raf = false
    private var gridId = ""
    private var disposed = false

    init {
        el.style.cssText = "padding:8px;border-radius:12px;box-sizing:border-box;overflow:hidden"
        el.addEventListener("pointerdown", { it.preventDefault() })
        el.appendChild(grid)
        sync(now())
        paint(now())
    }

    fun now() = hooks.now()

    fun update(options: PlateKeypadOptions) {
        val now = now()
        model.update(options, now)
        sync(now)
        wake()
    }

    fun dispose() {
        disposed = true
        keys.forEach { it.dispose() }
        keys = emptyList()
    }

    /** Rebuilds the grid when the one on screen changes; otherwise only refreshes key states. */
    private fun sync(now: Double) {
        val showing = model.showingLetters(now)
        val g = model.grid(showing)
        val id = "$showing:${g.id}"
        val cells = model.cells(showing)
        if (id != gridId) {
            keys.forEach { it.dispose() }
            gridId = id
            letters = showing
            grid.style.cssText = "display:grid;gap:${keyGap}px;grid-template-columns:repeat(${g.columns},1fr);grid-auto-rows:${keyHeight(model.compact)}px"
            grid.setAttribute("dir", if (showing) model.direction else "ltr")
            keys = cells.map { Key(this, it, cells.size, now) }
            grid.innerHTML = ""
            cells.forEachIndexed { i, c -> grid.appendChild(if (c.label == "") document.createElement("span") else keys[i].el) }
        } else cells.forEachIndexed { i, c -> keys[i].setCell(c) }
    }

    /** Staggers every key in, or out with [coming] false; out, the pad stays empty until the next call. */
    fun enter(coming: Boolean = true) {
        model.enter(now(), coming)
        paint(now())
        wake()
    }

    /** Starts the frame loop if it is not running. */
    fun wake() {
        if (raf || disposed) return
        raf = true
        window.requestAnimationFrame { raf = false; if (!disposed) tick() }
    }

    fun tick() {
        val now = now()
        sync(now)
        if (paint(now)) wake()
    }

    private fun paint(now: Double): Boolean {
        el.style.setProperty("background", cssColor(model.theme.surface))
        el.style.setProperty("opacity", model.padPresence(now).toString())
        grid.style.setProperty("height", if (model.animating(now)) "${model.heightAt(now)}px" else "")
        var running = model.animating(now)
        keys.forEachIndexed { i, k -> if (k.paint(now, model.presence(now, i, keys.size))) running = true }
        return running
    }
}
