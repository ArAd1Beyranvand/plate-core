package plates.countries.morocco

import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.boolean
import kotlinx.serialization.json.int
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive

/** Builds the [MoroccoValidator] its vectors describe in [a] (`input.validator.args`). */
internal fun moroccoValidatorOf(a: JsonObject): MoroccoValidator =
    MoroccoValidator(
        a["fields"]!!.jsonArray.map {
            val f = it.jsonObject
            MoroccoField(f["group"]!!.jsonPrimitive.content, f["min"]!!.jsonPrimitive.int, f["max"]!!.jsonPrimitive.int)
        },
        a["requiresSeries"]?.jsonPrimitive?.boolean ?: false,
    )
