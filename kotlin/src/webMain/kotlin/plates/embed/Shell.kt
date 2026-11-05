package plates.embed

import kotlinx.browser.document
import kotlinx.browser.window
import kotlinx.coroutines.Job
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.merge
import kotlinx.coroutines.launch
import kotlinx.serialization.json.JsonArray
import kotlinx.serialization.json.JsonNull
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.JsonPrimitive
import kotlinx.serialization.json.boolean
import kotlinx.serialization.json.booleanOrNull
import kotlinx.serialization.json.contentOrNull
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive
import org.w3c.dom.HTMLElement
import org.w3c.dom.HTMLInputElement
import org.w3c.dom.events.KeyboardEvent
import plates.core.alphabet.PlateAlphabet
import plates.core.input.PlateController
import plates.core.input.PlateInputMachine
import plates.core.input.PlateInputSource
import plates.core.input.PlateMode
import plates.core.input.PlateValuePreservation
import plates.core.input.migrate
import plates.core.timing.PlateAnimationController
import plates.countries.LoadedCountry
import plates.keypad.PlateKeypad
import plates.keypad.PlateKeypadHooks
import plates.keypad.PlateKeypadOptions
import plates.keypad.kPlateBackspaceKey
import plates.ui.PlateCanvas
import plates.ui.focusSlot
import plates.ui.pageNow
import plates.ui.slotInputElement

private const val VERSION = "1.0.0"

private class Entry(val id: String, val label: String, val spec: String, val theme: String?, val country: String?, val validator: String?, val sampleValues: List<String?>?)

private data class State(val spec: String, val values: List<String?>, val text: String, val complete: Boolean, val valid: Boolean?)

/** Boots the shell for [country]; [load] is that country's own module, nothing else is linked (W7). */
fun startShell(country: String, galleryOrigin: String?, load: () -> LoadedCountry) {
    var shell: Shell? = null
    var pending: JsonObject? = null
    val host = Host(
        "kotlin", country, VERSION, galleryOrigin ?: window.location.origin,
        onInit = { p -> shell?.init(p) ?: run { pending = p } },
        onAction = { name, args -> shell?.action(name, args) },
    )
    host.hello()
    host.progress("Loading plates", null)
    MainScope().launch {
        delay(0)
        try {
            val s = Shell((document.getElementById("app") ?: document.body!!) as HTMLElement, load(), host)
            shell = s
            pending?.let(s::init)
            document.getElementById("splash")?.remove()
            host.ready(s.specs(), s.spec())
            while (true) { host.reportHeight(); delay(250) }
        } catch (e: Throwable) {
            host.error("load_failed", e.toString(), true)
        }
    }
}

private class Shell(root: HTMLElement, private val loaded: LoadedCountry, private val host: Host) {
    private val scope = MainScope()
    private val entries = loaded.data["gallery"]!!.jsonArray.map {
        val o = it.jsonObject
        fun s(k: String) = o[k]?.jsonPrimitive?.contentOrNull
        Entry(s("id")!!, s("label")!!, s("spec")!!, s("theme"), s("country"), s("validator"), (o["sampleValues"] as? JsonArray)?.map { v -> v.jsonPrimitive.contentOrNull })
    }
    private fun el(tag: String, css: String = "") = (document.createElement(tag) as HTMLElement).also { it.style.cssText = css }
    private val stage = el("div", "position:relative;width:100%")
    // The inputs' percentages are of the plate's own box at rest, not the stage the ghost shares.
    private val layer = el("div", "position:absolute;left:0;top:0;width:100%")
    private val art = el("div")
    private val keypadBox = el("div", "margin-top:8px")
    private val verdict = el("p", "font:14px system-ui;margin:8px 0 0")

    private var entry = entries[0]
    private var canvas: PlateCanvas? = null
    private var machine: PlateInputMachine? = null
    private var keypad: PlateKeypad? = null
    private var showKeypad = true
    // [plateOnly] The gallery's detail card: the plate alone, showing each type's sample.
    private var plateOnly = false
    private var inputs = emptyMap<Int, HTMLInputElement>()
    private var watch: Job? = null
    private var last: State? = null
    private val anim = PlateAnimationController()
    private var endSwap: () -> Unit = {}
    private var ticking = false

    init {
        verdict.setAttribute("role", "status")
        stage.appendChild(art)
        stage.appendChild(layer)
        listOf(stage, keypadBox, verdict).forEach(root::appendChild)
        build(null, null, "intro")
    }

    fun specs() = entries.map { it.id to it.label }

    fun spec() = entry.id

    private fun entryOf(id: String?) = entries.find { it.id == id } ?: entries.find { it.spec == id } ?: entries[0]

    private fun state(): State {
        val c = canvas!!.controller
        return State(entry.id, c.values, c.text(), c.isCompleted, c.validation?.let { it.reason == null })
    }

    private fun emit(force: Boolean = false) {
        val s = state()
        if (!force && s == last) return
        last = s
        host.change(s.spec, s.values, s.text, s.complete, s.valid)
    }

    private fun theme(t: String) {
        document.documentElement!!.setAttribute("data-theme", t)
        (document.documentElement as HTMLElement).style.setProperty("color-scheme", t)
    }

    fun init(p: JsonObject) {
        plateOnly = p["plateOnly"]?.jsonPrimitive?.booleanOrNull == true
        showKeypad = p["keypad"]!!.jsonPrimitive.boolean && !plateOnly
        verdict.hidden = plateOnly
        keypadBox.hidden = plateOnly
        (document.documentElement as HTMLElement).style.overflowX = "hidden"
        (document.documentElement as HTMLElement).style.overflowY = "hidden"
        if (plateOnly) document.body!!.style.padding = "0"
        theme(p["theme"]!!.jsonPrimitive.content)
        build(p["spec"]?.jsonPrimitive?.content ?: entry.id, p["values"]?.jsonArray?.map { it.jsonPrimitive.contentOrNull }, "intro")
    }

    fun action(name: String, args: JsonObject) {
        try {
            when (name) {
                "setSpec" -> { build(args["spec"]?.jsonPrimitive?.takeIf { it.isString }?.content ?: error("setSpec needs spec"), animate = "swap"); emit(true) }
                "setValues" -> canvas!!.setValues((args["values"] as? JsonArray ?: error("setValues needs values")).map { it.jsonPrimitive.contentOrNull })
                "clear" -> canvas!!.controller.clear()
                "focus" -> machine!!.focusFirstEmptySlot()
                "setTheme" -> theme(args["theme"]!!.jsonPrimitive.content)
                "leave" -> { endSwap(); leave(canvas!!, anim); keypad?.enter(false); paint() }
            }
        } catch (e: Throwable) {
            host.error("bad_action", e.message ?: e.toString())
        }
    }

    private fun alphabetOf(numeric: Boolean) = canvas!!.spec.slots.map { it.alphabet }.firstOrNull { it.isNumeric == numeric }

    /** The keypad follows the slot that takes the next character: the focused one, else the first not yet complete. */
    private fun keypadOptions(): PlateKeypadOptions {
        val c = canvas!!
        val slots = c.spec.slots
        val at = machine?.activeIndex ?: slots.indices.firstOrNull { !slots[it].isComplete(c.controller.valueAt(it)) }
        val current = at?.let { slots.getOrNull(it)?.alphabet }
        val letters = current != null && !current.isNumeric
        return PlateKeypadOptions(
            digitAlphabet = alphabetOf(true) ?: PlateAlphabet.latinDigits,
            letterAlphabet = if (letters) current else alphabetOf(false),
            activeAlphabet = current,
            showLetters = letters,
        )
    }

    private fun build(id: String?, values: List<String?>? = null, animate: String? = null) {
        endSwap()
        endSwap = {}
        val prev = canvas?.let(::outgoing)
        watch?.cancel()
        keypad?.dispose()
        val old = canvas
        val next = entryOf(id)
        val spec = loaded.specs.getValue(next.spec)
        val carry = values ?: next.sampleValues?.takeIf { plateOnly } ?: old?.let { migrate(it.spec, spec, it.values, PlateValuePreservation.byGroupKey) }
        entry = next
        val controller = PlateController(spec, carry, next.validator?.let { loaded.validators[it]?.invoke() })
        val source = if (showKeypad) PlateInputSource.packageKeypad else PlateInputSource.system
        val c = PlateCanvas(
            spec, controller, mode = PlateMode.input, inputSource = source,
            theme = next.theme?.let(loaded.themes::get), country = next.country?.let(loaded.countries::get),
            animation = anim, now = ::pageNow,
        )
        controller.hints.value = next.sampleValues
        canvas = c
        val m = PlateInputMachine(
            spec, { controller.values }, { i, v -> controller.setAt(i, v.ifEmpty { null }) }, source,
            onActiveIndexChanged = { c.activeIndex = it; controller.notifyActiveSlotChanged() },
            onFocusRequested = { i -> inputs[i]?.let(::focusSlot) },
        )
        machine = m
        controller.attach(m)
        inputs.values.forEach { it.remove() }
        layer.style.setProperty("aspect-ratio", "${spec.canvasWidth} / ${spec.canvasHeight}")
        inputs = c.slotInputs().associate { slot ->
            val input = slotInputElement(slot, "", spec.canvasWidth, spec.canvasHeight, "#1a73e8")
            input.onfocus = { m.focusChanged(slot.index); null }
            input.onblur = { if (document.activeElement !is HTMLInputElement) m.focusChanged(null); null }
            input.oninput = {
                val v = input.value.ifEmpty { null }
                if (controller.setAt(slot.index, v) && v != null && spec.slots[slot.index].isFull(v)) m.advanceFrom(slot.index)
                else input.value = controller.valueAt(slot.index) ?: ""
                null
            }
            input.onkeydown = { e ->
                if ((e as KeyboardEvent).key == "Backspace" && input.value.isEmpty()) { e.preventDefault(); m.backspaceCharacter() }
                null
            }
            layer.appendChild(input)
            slot.index to input
        }
        keypadBox.innerHTML = ""
        keypad = if (showKeypad) PlateKeypad(
            keypadOptions(),
            PlateKeypadHooks(onKey = { k ->
                if (m.activeIndex == null) m.focusFirstEmptySlot()
                if (k == kPlateBackspaceKey) controller.backspace() else controller.submit(k)
            }),
        ).also { keypadBox.appendChild(it.el) } else null
        if (animate == "intro") keypad?.enter()
        when {
            prev != null && animate == "swap" -> endSwap = swapSpec(scope, stage, prev, c, anim, ::paint)
            animate != null -> introduce(c, anim)
            else -> anim.settleAll()
        }
        paint()
        last = state()
        watch = scope.launch {
            merge(controller.changes, controller.rejection).collect { paint(); emit() }
        }
    }

    private fun paint() {
        val c = canvas!!
        art.innerHTML = c.svg()
        art.firstElementChild?.setAttribute("style", "width:100%;height:auto;display:block")
        inputs.forEach { (i, input) ->
            val v = c.controller.valueAt(i) ?: ""
            if (input.value != v) input.value = v
        }
        verdict.textContent = c.controller.validation?.reason ?: if (c.controller.isCompleted) "Complete" else "Incomplete"
        keypad?.update(keypadOptions())
        if (c.animating && !ticking) {
            ticking = true
            window.requestAnimationFrame { ticking = false; paint() }
        }
    }
}
