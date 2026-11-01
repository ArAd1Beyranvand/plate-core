package plates.countries.iranshahr

import kotlinx.serialization.json.JsonArray
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.boolean
import kotlinx.serialization.json.int
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive

/** Builds the [TurkmenistanValidator] its vectors describe in [a] (`input.validator.args`). */
internal fun turkmenistanValidatorOf(a: JsonObject): TurkmenistanValidator =
    TurkmenistanValidator(
        a["parts"]!!.jsonArray.map {
            val p = it.jsonObject
            TurkmenistanPart(
                p["group"]!!.jsonPrimitive.content,
                p["length"]!!.jsonPrimitive.int,
                p["digits"]!!.jsonPrimitive.boolean,
                (p["allowed"] as? JsonArray)?.map { v -> v.jsonPrimitive.content },
            )
        },
    )
