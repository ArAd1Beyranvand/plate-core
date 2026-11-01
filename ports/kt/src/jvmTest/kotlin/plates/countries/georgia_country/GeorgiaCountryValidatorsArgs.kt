package plates.countries.georgia_country

import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.int
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive

/** Builds the [GeorgiaCountryValidator] its vectors describe in [a] (`input.validator.args`). */
internal fun georgiaCountryValidatorOf(a: JsonObject): GeorgiaCountryValidator =
    GeorgiaCountryValidator(
        a["rules"]!!.jsonArray.map {
            val r = it.jsonObject
            GeorgiaFieldRule(
                r["key"]!!.jsonPrimitive.content,
                GeorgiaFieldKind.valueOf(r["kind"]!!.jsonPrimitive.content),
                r["min"]!!.jsonPrimitive.int,
                r["max"]!!.jsonPrimitive.int,
            )
        },
    )
