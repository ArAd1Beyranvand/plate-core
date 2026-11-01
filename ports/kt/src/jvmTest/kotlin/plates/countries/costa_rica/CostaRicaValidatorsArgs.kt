package plates.countries.costa_rica

import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.boolean
import kotlinx.serialization.json.int
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive

/** Builds the [CostaRicaValidator] its vectors describe in [a] (`input.validator.args`). */
internal fun costaRicaValidatorOf(a: JsonObject): CostaRicaValidator = CostaRicaValidator(
    CostaRicaFormat(
        a["format"]!!.jsonArray.map {
            val f = it.jsonObject
            CostaRicaField(
                f["key"]!!.jsonPrimitive.content, f["name"]!!.jsonPrimitive.content,
                f["letters"]!!.jsonPrimitive.boolean, f["min"]!!.jsonPrimitive.int, f["max"]!!.jsonPrimitive.int,
            )
        },
    ),
)
