package plates.core.validators

import plates.core.validators.PlateCheck
import plates.core.validators.RuledPlateValidator
import plates.core.values.PlateSpec
import plates.core.values.PlateTextGroup

/** The verdict on a plate; [reason] explains an invalid one and is null when valid. */
data class PlateValidation(val reason: String? = null) {
    val isValid get() = reason == null

    companion object {
        val valid = PlateValidation()
        fun invalid(reason: String) = PlateValidation(reason)
    }
}

/** A plate as it stands, for a validator to judge. */
class PlateEntry(val spec: PlateSpec<*>, val values: List<String?>, val activeIndex: Int? = null) {
    /** Canonical value of the group named [key]; '' if none. */
    fun group(key: String) = spec.valueOfGroup(key, values)

    val activeGroup: PlateTextGroup? get() = activeIndex?.let(spec::groupAt)
}

// ASCII only: Char.isDigit() accepts every Unicode Nd (H9).
fun isDigits(value: String) = value.isNotEmpty() && value.all { it in '0'..'9' }

// Code units, safe because isDigits passes ASCII alone (H24).
fun isDigitsOfLength(value: String, length: Int) = value.length == length && isDigits(value)

// ASCII A-Z only, min..max long (H9).
fun isLetters(value: String, min: Int, max: Int = min) = value.length in min..max && value.all { it in 'A'..'Z' }

/** Judges a plate. It never prevents input; what to do with the verdict is the host's decision. */
fun interface PlateValidator {
    fun validate(entry: PlateEntry): PlateValidation
}

/** The verdict a spec's restrictions give on [entry], or null when none is broken. */
fun restrictionVerdict(entry: PlateEntry): PlateValidation? =
    entry.spec.restrictionViolatedBy(entry.values)?.let { PlateValidation.invalid(it.reason) }

/** Quiet until [gateGroup], the last register the user reaches, has content. */
abstract class GatedPlateValidator : PlateValidator {
    abstract val gateGroup: String

    abstract fun judge(entry: PlateEntry): PlateValidation

    override fun validate(entry: PlateEntry) =
        restrictionVerdict(entry) ?: if (entry.group(gateGroup).isEmpty()) PlateValidation.valid else judge(entry)
}

/** One field rule of a [RuledPlateValidator]: the group named [group] must match [pattern] whole, or the plate is invalid
 * for [reason]. An [optional] group may also be empty. Keep classes explicit (`[0-9]`, not `\d`) so only ASCII passes. */
class PlateCheck(val group: String, pattern: String, val reason: String, private val optional: Boolean = false) {
    private val re = Regex(pattern)

    fun passes(value: String) = (optional && value.isEmpty()) || re.matches(value)
}

/** A gated validator that is a list of [checks], judged in order; the first to fail gives the verdict. The gate is [gate],
 * else the last check's group. */
abstract class RuledPlateValidator(private val gate: String? = null) : GatedPlateValidator() {
    abstract val checks: List<PlateCheck>

    override val gateGroup get() = gate ?: checks.last().group

    override fun judge(entry: PlateEntry) =
        checks.firstOrNull { !it.passes(entry.group(it.group)) }?.let { PlateValidation.invalid(it.reason) } ?: PlateValidation.valid
}
