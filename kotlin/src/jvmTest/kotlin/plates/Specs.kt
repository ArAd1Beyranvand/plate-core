package plates

import kotlinx.serialization.json.JsonNull
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive
import plates.core.values.PlateSpec
import plates.countries.countryJson
import plates.countries.loadCountry

/** A spec from ports/data, with what the input tests need; [codeRegion] marks a region resolver only code can run. */
class LoadedSpec(val spec: PlateSpec<Any>, val codeRegion: Boolean)

private val packages = HashMap<String, Map<String, LoadedSpec>>()

@Suppress("UNCHECKED_CAST")
fun specOf(pkg: String, id: String): LoadedSpec = packages.getOrPut(pkg) {
    val country = loadCountry(countryJson(pkg))
    val resolvers = country.data["resolvers"]!!.jsonObject
    country.data["specs"]!!.jsonArray.associate { e ->
        val s = e.jsonObject
        val region = s["resolveRegion"]?.takeUnless { it is JsonNull }?.let { resolvers[it.jsonPrimitive.content]!!.jsonObject }
        val id = s["id"]!!.jsonPrimitive.content
        id to LoadedSpec(country.specs.getValue(id) as PlateSpec<Any>, region != null && region["kind"]!!.jsonPrimitive.content != "table")
    }
}[id]!!
