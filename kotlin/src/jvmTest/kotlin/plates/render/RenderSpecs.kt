package plates.render

import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonNull
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive
import plates.core.theme.PlateTheme
import plates.core.values.PlateSpec
import plates.countries.countryJson
import plates.countries.load

/** A whole spec from ports/data; [codeRender] marks a label or theme resolver only code can run. */
class RenderSpec(val spec: PlateSpec<PlateTheme>, val codeRender: Boolean, val data: JsonObject)

private val loaded = HashMap<String, Map<String, RenderSpec>>()

fun renderSpecOf(pkg: String, id: String): RenderSpec = loaded.getOrPut(pkg) {
    val country = load(Json.parseToJsonElement(countryJson(pkg)).jsonObject)
    val resolvers = country.data["resolvers"]!!.jsonObject
    fun isCode(name: JsonElement?) = name != null && name !is JsonNull && resolvers[name.jsonPrimitive.content]!!.jsonObject["kind"]!!.jsonPrimitive.content != "table"
    country.data["specs"]!!.jsonArray.associate { e ->
        val s = e.jsonObject
        val id = s["id"]!!.jsonPrimitive.content
        val codeRender = isCode(s["resolveTheme"]) || s["labels"]!!.jsonArray.any { isCode(it.jsonObject["resolve"]) }
        id to RenderSpec(country.specs.getValue(id), codeRender, country.data)
    }
}[id]!!
