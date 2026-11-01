package plates.countries.colombia

import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.jsonPrimitive

/** Builds the [ColombiaValidator] its vectors describe in [a] (`input.validator.args`). */
internal fun colombiaValidatorOf(a: JsonObject): ColombiaValidator {
    val id = a["series"]!!.jsonPrimitive.content
    return ColombiaValidator(ColombiaSeries.values.first { it.id == id })
}
