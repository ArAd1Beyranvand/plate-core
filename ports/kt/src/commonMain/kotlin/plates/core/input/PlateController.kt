package plates.core.input

import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import plates.core.alphabet.AlphabetInput
import plates.core.alphabet.PlateAlphabet
import plates.core.alphabet.splitRunes
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidation
import plates.core.validators.PlateValidator
import plates.core.values.PlateRestriction
import plates.core.values.PlateSlot
import plates.core.values.PlateSpec

/** What happens to the characters on a plate when [PlateController.adoptSpec] swaps its [PlateSpec]. */
enum class PlateValuePreservation {
    /** Start the new plate empty. */
    none,

    /** Copy slot by slot while both plates have a slot at that position. */
    byIndex,

    /** Copy register by register, matching [PlateTextGroup.key] between the specs. */
    byGroupKey,
}

private val alwaysNull: StateFlow<String?> = MutableStateFlow<String?>(null).asStateFlow()

/**
 * Owns a plate's characters and drives focus and navigation.
 *
 * Listen at four grains, each a [StateFlow]: [slot] per position, [completed]
 * on a full/not-full flip, [rejection], and [changes], a revision counter that
 * steps on every change of the whole.
 */
class PlateController(
    spec: PlateSpec<*>,
    values: List<String?>? = null,
    /** Judges the plate for [validation]; [rejection] outranks it. */
    var validator: PlateValidator? = null,
) {
    /** Changed only through [adoptSpec]. */
    var spec: PlateSpec<*> = spec
        private set

    private var _values: MutableList<String?> = MutableList(spec.slotCount) { printedCharacter(spec, it) }
    private lateinit var _slots: List<MutableStateFlow<String?>>
    private val _completed: MutableStateFlow<Boolean>
    private val _rejection: MutableStateFlow<PlateRestriction?>
    private val _changes = MutableStateFlow(0)
    private var target: PlateInputTarget? = null

    init {
        if (values != null) {
            for (i in 0 until minOf(spec.slotCount, values.size)) {
                if (printedCharacter(spec, i) != null) continue
                _values[i] = sanitize(spec, i, values[i])
            }
        }
        val refused = clearRestricted(spec, _values)
        foundSlots()
        _completed = MutableStateFlow(computeCompleted())
        _rejection = MutableStateFlow(refused)
    }

    /** A sample value per slot, drawn faintly; never touches values or completion. */
    val hints = MutableStateFlow<List<String?>?>(null)

    /** [hints] at slot [index], rendered through [alphabet] (a mirror's) or the slot's own; null for none. */
    fun hintAt(index: Int, alphabet: PlateAlphabet? = null): String? {
        val hint = hints.value ?: return null
        if (index >= hint.size || index >= spec.slotCount) return null
        val v = hint[index]
        if (v.isNullOrEmpty()) return null
        return alphabet?.renderAll(v) ?: spec.slots[index].render(v)
    }

    /** A snapshot in slot order. */
    val values: List<String?> get() = _values.toList()

    /** Null when [index] is outside the plate. */
    fun valueAt(index: Int): String? = _values.getOrNull(index)

    /**
     * Stores [value] at [index]; '' or null clears. A refused character or a
     * write to a printed slot is a no-op; a restricted value is refused and
     * published on [rejection]. Returns whether it was stored.
     */
    fun setAt(index: Int, value: String?): Boolean {
        if (index < 0 || index >= _values.size) return false
        if (printedCharacter(spec, index) != null) return false
        val next = sanitize(spec, index, value)
        if (next == null && !value.isNullOrEmpty()) return false
        return store(mapOf(index to next))
    }

    /** Writes every slot in index order, notifying once. Printed slots keep their character. */
    fun setValues(values: List<String?>): Boolean = store(
        _values.indices.associateWith { printedCharacter(spec, it) ?: sanitize(spec, it, values.getOrNull(it)) },
    )

    fun clear() = setValues(List(_values.size) { null })

    /** Every text group rendered through its alphabets, joined by [sep]. */
    fun text(sep: String = " ") = spec.effectiveTextGroups.joinToString(sep) { spec.renderGroup(it, _values) }

    /** The group named [key] in canonical form; '' for an unknown key. */
    fun group(key: String) = spec.valueOfGroup(key, _values)

    /** [PlateSpec.resolveRegion] over what is typed; null when the spec has none or it cannot tell yet. */
    val regionCaption: String? get() = spec.resolveRegion?.invoke(::group)

    /**
     * Pours [value] across the slots of the group named [key], each taking up to
     * its length (a chosen slot takes the rest whole). A refused share clears its slot.
     */
    fun setGroup(key: String, value: String): Boolean {
        val group = spec.groupNamed(key) ?: return false
        val characters = splitRunes(value)
        val writes = LinkedHashMap<Int, String?>()
        var offset = 0
        for (index in group.indices) {
            if (printedCharacter(spec, index) != null) continue
            val slot = spec.slots[index]
            val take = if (slot.alphabet.input == AlphabetInput.chosen) characters.size - offset else slot.length
            writes[index] = sanitize(spec, index, characters.drop(offset).take(maxOf(take, 0)).joinToString(""))
            offset += take
        }
        return store(writes)
    }

    val isCompleted get() = _completed.value
    val isEmpty get() = _values.none { !it.isNullOrEmpty() }

    /**
     * The character at [index]; out of range gives a flow that stays null.
     * Recreated by [adoptSpec]: call per render rather than caching it.
     */
    fun slot(index: Int): StateFlow<String?> = _slots.getOrNull(index) ?: alwaysNull

    /** Changes only when [isCompleted] flips. */
    val completed: StateFlow<Boolean> get() = _completed

    /** The restriction the last refused write broke; null once a write is stored. */
    val rejection: StateFlow<PlateRestriction?> get() = _rejection

    /** Steps on every change of the whole plate, including focus. */
    val changes: StateFlow<Int> get() = _changes

    /** Swaps the plate, carrying characters across as [preserve] directs, and notifies once. */
    fun adoptSpec(next: PlateSpec<*>, preserve: PlateValuePreservation = PlateValuePreservation.byGroupKey) {
        val migrated = migrate(spec, next, _values, preserve)
        val refused = clearRestricted(next, migrated)
        spec = next
        _values = migrated
        _rejection.value = refused
        foundSlots()
        _completed.value = computeCompleted()
        notifyListeners()
    }

    /** Null without a [validator]; a refused write's reason outranks it. */
    val validation: PlateValidation?
        get() {
            _rejection.value?.let { return PlateValidation.invalid(it.reason) }
            return validator?.validate(PlateEntry(spec, values, activeIndex))
        }

    fun attach(target: PlateInputTarget) {
        this.target = target
        notifyListeners()
    }

    /** Guarded: an old adapter's detach runs after the new one has attached. */
    fun detach(target: PlateInputTarget) {
        if (this.target !== target) return
        this.target = null
        notifyListeners()
    }

    fun notifyActiveSlotChanged() = notifyListeners()

    /** Null when unfocused. */
    val activeIndex: Int? get() = target?.activeIndex

    val activeSlot: PlateSlot? get() = spec.slotAt(activeIndex ?: -1)

    /** True while the platform keyboard stands in for the host's keypad under keypadFirst. */
    val systemKeyboardActive get() = target?.systemKeyboardActive ?: false

    val isAttached get() = target != null

    /** Commits [character] to the active slot and advances focus, as typing does. */
    fun submit(character: String) {
        target?.submitCharacter(character)
    }

    /** Clears the active slot's last character, or the previous slot's if it is empty. */
    fun backspace() {
        target?.backspaceCharacter()
    }

    /** Focuses the first slot that is not full, or the first slot. */
    fun focusFirstEmpty() {
        target?.focusFirstEmptySlot()
    }

    fun focusSlot(index: Int) {
        target?.focusSlot(index)
    }

    private fun notifyListeners() {
        _changes.value++
    }

    private fun foundSlots() {
        _slots = _values.map { MutableStateFlow(it) }
    }

    /** Writes [changes] unless they break a restriction, then notifies once. */
    private fun store(changes: Map<Int, String?>): Boolean {
        val candidate = _values.toMutableList()
        changes.forEach { (i, v) -> candidate[i] = v }
        val broken = spec.restrictionViolatedBy(candidate)
        if (broken != null) {
            // Published although no value changed, so listeners show the error.
            _rejection.value = broken
            notifyListeners()
            return false
        }
        changes.forEach { (i, v) ->
            _values[i] = v
            _slots[i].value = v
        }
        _completed.value = computeCompleted()
        _rejection.value = null
        notifyListeners()
        return true
    }

    private fun computeCompleted() =
        _values.isNotEmpty() && spec.slots.withIndex().all { (i, s) -> s.isComplete(_values[i]) }

    companion object {
        /**
         * Pours [text] into the slots in order, each taking up to its length.
         * Characters the current slot refuses, such as separators, are skipped without consuming it.
         */
        fun fromText(spec: PlateSpec<*>, text: String): PlateController {
            val values = MutableList<String?>(spec.slotCount) { null }
            var index = 0
            for (character in splitRunes(text)) {
                if (index >= spec.slotCount) break
                val slot = spec.slots[index]
                if (!slot.accepts(character)) continue
                values[index] = (values[index] ?: "") + slot.canonical(character)
                if (slot.isFull(values[index])) index++
            }
            return PlateController(spec, values)
        }
    }
}

/** [value] as the slot stores it: canonical, or null when cleared or refused. */
private fun sanitize(spec: PlateSpec<*>, index: Int, value: String?): String? {
    if (value.isNullOrEmpty()) return null
    val slot = spec.slotAt(index) ?: return null
    return if (slot.accepts(value)) slot.canonical(value) else null
}

/** The fixed character of a slot whose alphabet holds exactly one: printed, not typed. */
private fun printedCharacter(spec: PlateSpec<*>, index: Int): String? {
    val slot = spec.slots[index]
    val characters = slot.alphabet.characters
    return if (slot.length == 1 && characters.size == 1) characters[0] else null
}

/** Empties, in place, every register that breaks a restriction; returns the last one broken. */
private fun clearRestricted(spec: PlateSpec<*>, values: MutableList<String?>): PlateRestriction? {
    var broken: PlateRestriction? = null
    for (r in spec.restrictions) {
        if (!r.matches(spec.valueOfGroup(r.group, values))) continue
        for (i in spec.indicesOfGroup(r.group)) if (i < values.size) values[i] = null
        broken = r
    }
    return broken
}

private fun hasKeyedGroups(spec: PlateSpec<*>) = spec.effectiveTextGroups.any { it.key != null }

/** The values [to] starts from when it replaces [from] under [preserve]. */
fun migrate(
    from: PlateSpec<*>,
    to: PlateSpec<*>,
    values: List<String?>,
    preserve: PlateValuePreservation,
): MutableList<String?> {
    if (preserve == PlateValuePreservation.none) return MutableList(to.slotCount) { null }

    val byKey = preserve == PlateValuePreservation.byGroupKey && (hasKeyedGroups(from) || hasKeyedGroups(to))
    if (!byKey) return MutableList(to.slotCount) { if (it < values.size) sanitize(to, it, values[it]) else null }

    // Printed slots first, so a matched group still wins.
    val result = MutableList(to.slotCount) { printedCharacter(to, it) }
    for (target in to.effectiveTextGroups) {
        val key = target.key ?: continue
        val source = from.groupNamed(key) ?: continue
        // Gaps are skipped, so a half-typed register carries as far as it got;
        // characters pour by slot length, so two fields can become two cells.
        val characters = source.indices.filter { it < values.size }.flatMap { splitRunes(values[it] ?: "") }
        var next = 0
        for (index in target.indices) {
            val length = to.slots[index].length
            result[index] = sanitize(to, index, characters.drop(next).take(length).joinToString(""))
            next += length
        }
    }
    return result
}
