package plates.embed

import java.io.File
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive
import kotlinx.serialization.json.boolean

class ProtocolTest {
    @Test
    fun vectors() {
        val file = File(System.getProperty("plates.vectors"), "../web/protocol_vectors.json")
        val cases = Json.parseToJsonElement(file.readText()).jsonObject["cases"]!!.jsonArray
        assert(cases.isNotEmpty())
        for (c in cases.map { it.jsonObject }) {
            val dir = Dir.valueOf(c["dir"]!!.jsonPrimitive.content)
            assertEquals(c["valid"]!!.jsonPrimitive.boolean, validate(dir, c["message"]), c["name"]!!.jsonPrimitive.content)
        }
    }
}
