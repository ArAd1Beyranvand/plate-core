// Runs ports/vectors against a hand-ported [D4-code] unit; the generated unit tests call these.
package plates.countries

import java.io.File
import kotlin.test.assertEquals
import org.junit.Assume.assumeFalse
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonArray
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.JsonNull
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.JsonPrimitive
import kotlinx.serialization.json.boolean
import kotlinx.serialization.json.contentOrNull
import kotlinx.serialization.json.double
import kotlinx.serialization.json.doubleOrNull
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive
import plates.VectorCase
import plates.core.theme.PlateTheme
import plates.core.validators.PlateEntry
import plates.core.validators.PlateValidator
import plates.core.values.PlateLabelResolver
import plates.core.values.PlateThemeResolver
import plates.loadVectors

// Readers for `input.validator.args`; the generated tests build constructor arguments with them.
fun JsonElement.int() = jsonPrimitive.content.toInt()
fun JsonElement.dbl() = jsonPrimitive.double
fun JsonElement.bool() = jsonPrimitive.boolean
fun JsonElement.str() = jsonPrimitive.content
fun JsonElement.at(i: Int) = jsonArray[i]
fun <T> JsonElement.list(f: (JsonElement) -> T) = jsonArray.map(f)
fun <T> JsonElement.orNull(f: (JsonElement) -> T): T? = if (this is JsonNull) null else f(this)

private val data = File(System.getProperty("plates.vectors"), "../data")
private val alphabets by lazy { Json.parseToJsonElement(File(data, "alphabets.json").readText()).jsonObject["alphabets"]!!.jsonObject }
private val loaded = HashMap<String, LoadedCountry>()

/** ports/data/countries/<pkg>.json with its alphabets inlined, the shape the generated `Data.kt` embeds. */
fun countryJson(pkg: String): String {
    val d = Json.parseToJsonElement(File(data, "countries/$pkg.json").readText()).jsonObject
    val inlined = d["alphabets"]!!.jsonArray.associate { it.str() to alphabets[it.str()]!! }
    return JsonObject(d + ("alphabets" to JsonObject(inlined))).toString()
}

/** Every spec of [pkg] with no code wired, so a stub elsewhere cannot break these tests. */
fun countrySpecs(pkg: String) = loaded.getOrPut(pkg) { loadCountry(countryJson(pkg)) }.specs

/** Numbers compare by value: Dart writes `1.0` where Kotlin may read `1`. */
internal fun norm(e: JsonElement?): JsonElement? = when (e) {
    is JsonObject -> JsonObject(e.mapValues { norm(it.value)!! })
    is JsonArray -> JsonArray(e.map { norm(it)!! })
    is JsonPrimitive -> if (!e.isString && e.doubleOrNull != null) JsonPrimitive(e.double) else e
    else -> e
}

/**
 * Fails with the first few cases whose result differs from `expect`. A unit that is still a stub fails too,
 * unless the run passes `-Pstubs=skip` (oracle_all): then it is skipped, so the whole suite stays green.
 */
private fun check(cases: List<VectorCase>, run: (JsonObject) -> JsonElement) {
    val bad = cases.mapNotNull { c ->
        val got = try {
            run(c.input.jsonObject)
        } catch (e: Throwable) {
            assumeFalse("not ported", e is NotImplementedError && "not ported" in e.message.orEmpty() && System.getProperty("plates.stubs") == "skip")
            JsonObject(mapOf("throws" to JsonPrimitive(e.toString())))
        }
        if (norm(got) == norm(c.expect)) null else "${c.name}: got $got want ${c.expect}"
    }
    assertEquals(emptyList(), bad.take(5), "${bad.size} of ${cases.size} cases fail")
}

fun validatorVectors(cls: String, make: (JsonObject) -> PlateValidator) =
    check(loadVectors("validators/$cls.json").filter { it.input.jsonObject["validator"]!!.jsonObject["class"]!!.str() == cls }) { i ->
        val v = make(i["validator"]!!.jsonObject["args"]?.jsonObject ?: JsonObject(emptyMap()))
        val values = i["values"]!!.jsonArray.map { it.jsonPrimitive.contentOrNull }
        val reason = v.validate(PlateEntry(countrySpecs(i["package"]!!.str()).getValue(i["spec"]!!.str()), values)).reason
        JsonObject(mapOf("valid" to JsonPrimitive(reason == null), "reason" to JsonPrimitive(reason)))
    }

private fun JsonObject.group(): (String) -> String = { k -> this["groups"]!!.jsonObject[k]?.str() ?: "" }

fun labelVectors(name: String, resolve: PlateLabelResolver) =
    check(loadVectors("resolvers/$name.json")) { i -> JsonPrimitive(resolve(i.group())) }

fun themeVectors(name: String, resolve: PlateThemeResolver<PlateTheme>) =
    check(loadVectors("resolvers/$name.json")) { i ->
        val t = resolve(themeOf(i["base"]!!.jsonObject), i.group())
        fun c(v: Int) = JsonPrimitive(v.toLong() and 0xFFFFFFFFL)
        JsonObject(
            mapOf(
                "plateBackground" to c(t.plateBackground), "plateBorder" to c(t.plateBorder), "ink" to c(t.ink),
                "dividerColor" to c(t.dividerColor), "borderWidthRatio" to JsonPrimitive(t.borderWidthRatio),
                "plateRadiusRatio" to JsonPrimitive(t.plateRadiusRatio), "activeColor" to c(t.activeColor),
                "inactiveColor" to c(t.inactiveColor), "alertColor" to c(t.alertColor),
            ).filterKeys { it in i["base"]!!.jsonObject },
        )
    }
