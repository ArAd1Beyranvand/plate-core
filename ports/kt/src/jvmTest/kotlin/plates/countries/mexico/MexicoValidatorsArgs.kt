package plates.countries.mexico

import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.jsonPrimitive

/** Builds the [MexicoValidator] its vectors describe in [a] (`input.validator.args`). */
internal fun mexicoValidatorOf(a: JsonObject): MexicoValidator =
    MexicoValidator(a["format"]!!.jsonPrimitive.content)
