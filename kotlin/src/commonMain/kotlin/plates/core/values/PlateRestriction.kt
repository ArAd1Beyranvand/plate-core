package plates.core.values

/** What a [PlateSpec] needs of a restriction: a register value it refuses. */
interface PlateRestriction {
    /** The [PlateTextGroup.key] of the register this restriction watches. */
    val group: String
    val reason: String
    fun matches(groupValue: String): Boolean
}

/** Refused register values, in canonical (storage) form. */
class ValuesRestriction(override val group: String, val values: List<String>, override val reason: String) : PlateRestriction {
    override fun matches(groupValue: String) = groupValue in values
}

/** Thrown by [PlateSpec.checkRestrictions]; the message is the restriction's reason. */
class PlateRestrictionException(val restriction: PlateRestriction) : Exception(restriction.reason)
