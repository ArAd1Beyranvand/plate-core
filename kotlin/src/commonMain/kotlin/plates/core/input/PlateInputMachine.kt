package plates.core.input

import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import plates.core.alphabet.splitRunes
import plates.core.values.PlateSpec

/** What the focus adapter's text fields need; a DOM input fits. */
interface PlateTextField {
    var value: String
    fun setSelectionRange(start: Int, end: Int)
}

/**
 * The pure half of a plate's input: active index, submit, backspace, advance.
 * Reads values through [readValues] and writes through [commit], so it is
 * independent of host state. Bound to its [spec]: a spec change builds a new machine.
 *
 * The focus adapter owns the inputs: it moves focus on [onFocusRequested] and
 * reports focus back through [focusChanged] (an editable mirror reports its source).
 */
class PlateInputMachine(
    val spec: PlateSpec<*>,
    val readValues: () -> List<String?>,
    /** Writes one slot's value back to the host; '' clears. Focus must not advance past a refusal. */
    val commit: (index: Int, value: String) -> Boolean,
    var inputSource: PlateInputSource,
    /** Fired when the focused slot changes or focus leaves the plate. */
    var onActiveIndexChanged: ((Int?) -> Unit)? = null,
    /** Fired when a chosen slot under [SlotBehavior.sheet] is reached. */
    var onSheetRequested: ((Int) -> Unit)? = null,
    /** The adapter focuses the input at the index. */
    var onFocusRequested: ((Int) -> Unit)? = null,
) : PlateInputTarget {
    private val _systemKeyboard = MutableStateFlow(false)

    /** Under keypadFirst, whether typed slots use the platform keyboard (inputmode "text" vs "none"). */
    val systemKeyboard: StateFlow<Boolean> get() = _systemKeyboard

    // Seeded, unannounced, so a keypad driven by activeIndex starts on the first slot's alphabet.
    override var activeIndex: Int? = if (spec.slots.isNotEmpty()) 0 else null
        private set

    override val systemKeyboardActive get() = _systemKeyboard.value

    /** The plate takes the platform keyboard until a keypad key is pressed or focus leaves the plate. */
    fun requestSystemKeyboard() {
        _systemKeyboard.value = true
    }

    /** The adapter reports where focus is; null when it left the plate. */
    fun focusChanged(active: Int?) {
        // A plate without focus falls back to the keypad.
        if (active == null) _systemKeyboard.value = false
        if (active == activeIndex) return
        activeIndex = active
        onActiveIndexChanged?.invoke(active)
    }

    private fun requestFocus(index: Int) {
        onFocusRequested?.invoke(index)
        focusChanged(index)
    }

    /** Moves focus past [index]: to the next slot, or its sheet if chosen. At the end focus stays. */
    fun advanceFrom(index: Int) {
        val next = spec.nextIndex(index) ?: return
        val behavior = resolveSlotBehavior(PlateMode.input, spec.slots[next].alphabet.input, inputSource)
        if (behavior == SlotBehavior.sheet) onSheetRequested?.invoke(next) else requestFocus(next)
    }

    override fun submitCharacter(character: String) {
        // A keypad key means the keypad is wanted, not the platform keyboard.
        _systemKeyboard.value = false
        val index = activeIndex ?: return
        val slot = spec.slots[index]
        val next = (readValues()[index] ?: "") + slot.alphabet.canonical(character)
        if (!slot.accepts(next)) return
        if (!commit(index, next)) return
        if (slot.isFull(next)) advanceFrom(index)
    }

    override fun backspaceCharacter() {
        _systemKeyboard.value = false
        val values = readValues()
        // Focus can drop once the plate is complete; the keypad still deletes from the end.
        val index = activeIndex ?: values.indexOfLast { !it.isNullOrEmpty() }
        if (index < 0) return
        val current = values[index]
        val empty = current.isNullOrEmpty()
        val target = (if (empty) spec.previousIndex(index) else index) ?: return
        val held = splitRunes(if (empty) values[target] ?: "" else current!!)
        // The Dart reference throws when stepping back onto an empty slot too.
        require(held.isNotEmpty()) { "backspace on two empty slots" }
        commit(target, held.dropLast(1).joinToString(""))
        requestFocus(target)
    }

    override fun focusFirstEmptySlot() {
        val values = readValues()
        val i = spec.slots.indices.indexOfFirst { !spec.slots[it].isFull(values[it]) }
        requestFocus(if (i < 0) 0 else i)
    }

    override fun focusSlot(index: Int) {
        if (index < 0 || index >= spec.slots.size) return
        requestFocus(index)
    }

    companion object {
        /** Shows [stored] in [field] in display form, caret at the end, only when the text differs. */
        fun setText(field: PlateTextField?, stored: String?, render: (String) -> String) {
            if (field == null) return
            val text = if (stored.isNullOrEmpty()) "" else render(stored)
            if (field.value == text) return
            field.value = text
            field.setSelectionRange(text.length, text.length)
        }
    }
}
