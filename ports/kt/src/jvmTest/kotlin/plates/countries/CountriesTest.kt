package plates.countries

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonObject

class CountriesTest {
    /** Every generated `Data.kt` round-trips to its ports/data file, and loads. */
    @Test fun everyCountryLoads() {
        for ((id, load) in countries) {
            val c = load()
            val file = Json.parseToJsonElement(countryJson("${id}_plate")).jsonObject
            // Node writes 1.0 as 1, so numbers compare by value.
            assertEquals(norm(JsonObject(file.filterKeys { it in c.data })), norm(c.data), id)
            assertEquals(c.data["specs"]!!.jsonArray.size, c.specs.size, id)
        }
    }
}
