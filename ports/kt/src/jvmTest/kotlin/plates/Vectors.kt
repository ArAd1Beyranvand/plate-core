package plates

import java.io.File
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive

class VectorCase(val name: String, val input: JsonElement, val expect: JsonElement)

/** Loads `ports/vectors/<rel>` (e.g. `core/alphabet.json`) and returns its cases. */
fun loadVectors(rel: String): List<VectorCase> {
    val root = File(System.getProperty("plates.vectors"))
    val cases = Json.parseToJsonElement(File(root, rel).readText()).jsonObject["cases"]!!.jsonArray
    return cases.map {
        val o = it.jsonObject
        VectorCase(o["name"]!!.jsonPrimitive.content, o["input"] ?: JsonObject(emptyMap()), o["expect"]!!)
    }
}
