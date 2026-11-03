// Country data v2 (codegen/compact.mjs) -> the verbose shape `load` reads. Every object is a tuple of its kind's fields
// with the trailing defaults left off; KINDS is the one table, and must match the one in compact.mjs.
package plates.countries

import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonArray
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.JsonNull
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.JsonPrimitive
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive

/** A field: its default (JSON), the earlier field it copies when that is set, and its child kind (`kind` or `kind[]`). */
private class Field(val name: String, val default: JsonElement, val copyOf: String?, val child: String?)

/** kind -> `field[=default][~child]` words; a default of `@f` copies the earlier field f, and none means required. */
private val KINDS: Map<String, List<Field>> = mapOf(
    "spec" to "id country canvasWidth canvasHeight slots=[]~slot[] labels=[]~label[] panel=null~panel background={\"kind\":\"fill\",\"fill\":{\"kind\":\"field\"},\"shape\":null} bands=[]~band[] rules=[]~rule[] decals=[]~decal[] mirrors=[]~mirror[] textGroups=null~group[] restrictions=[]~restriction[] textDirection=\"ltr\" borderWidthRatioOverride=null inkOverride=null resolveTheme=null resolveRegion=null",
    "slot" to "alphabet box length=1 minLength=@length spacing=0 color=null group=null",
    "label" to "text box glyphHeight color=null rotated=false lineHeight=null fontFamily=null fontPackage=null resolve=null",
    "panel" to "box flagScale=1 captionScale=1 padding=null direction=\"vertical\" shape=null",
    "band" to "box color topCornerRadius=0 bottomCornerRadius=0",
    "rule" to "box",
    "decal" to "box image=null drawing=null",
    "mirror" to "source box glyphHeight alphabet=null editable=false",
    "group" to "indices prefix=\"\" key=null",
    "restriction" to "group values reason",
    "country" to "code panelColor panelTextColor flagAspectRatio captionLines=[] headingLines=[] flag=null flagBorderColor=null",
    "gallery" to "id label spec sampleValues source section note=null theme=null country=null validator=null themeForValues=false bands=[]",
    "alphabet" to "id chars input=\"typed\" isNumeric=false glyphs=[] direction=\"ltr\" placeholder=\"?\"",
).mapValues { (_, words) ->
    words.split(' ').map { word ->
        val (head, child) = word.split('~').let { it[0] to it.getOrNull(1) }
        val (name, default) = head.split('=', limit = 2).let { it[0] to it.getOrNull(1) }
        val copy = default?.takeIf { it.startsWith("@") }?.drop(1)
        Field(name, if (default == null || copy != null) JsonNull else Json.parseToJsonElement(default), copy, child)
    }
}

/** A tuple -> the object of its kind, defaults filled in and children built. */
private fun build(kind: String, t: JsonArray): JsonObject {
    val out = LinkedHashMap<String, JsonElement>()
    KINDS.getValue(kind).forEachIndexed { i, f ->
        val v = t.getOrNull(i)
        out[f.name] = when {
            v == null -> f.copyOf?.let(out::getValue) ?: f.default
            f.child == null || v is JsonNull -> v
            f.child.endsWith("[]") -> JsonArray(v.jsonArray.map { build(f.child.dropLast(2), it.jsonArray) })
            else -> build(f.child, v.jsonArray)
        }
    }
    return JsonObject(out)
}

private fun alphabet(t: JsonArray): JsonObject {
    val a = build("alphabet", t)
    val characters = a.getValue("chars").jsonArray.flatMap { x ->
        if (x is JsonArray) (x[0].jsonPrimitive.content[0]..x[1].jsonPrimitive.content[0]).map { JsonPrimitive(it.toString()) } else listOf(x)
    }
    return JsonObject(a - "chars" + ("characters" to JsonArray(characters)))
}

/** A theme is a plain object, or `[field, ink, border, radius, inactive?, alert?]` for one ink on one field. */
private fun theme(t: JsonElement): JsonObject {
    if (t is JsonObject) return t
    val v = t.jsonArray
    return JsonObject(mapOf(
        "plateBackground" to v[0], "plateBorder" to v[1], "ink" to v[1], "dividerColor" to v[1], "borderWidthRatio" to v[2],
        "plateRadiusRatio" to v[3], "activeColor" to v[1], "inactiveColor" to (v.getOrNull(4) ?: JsonPrimitive(0xFFB0B0B0)),
        "alertColor" to (v.getOrNull(5) ?: JsonPrimitive(0xFFF87171)),
    ))
}

private fun spec(t: JsonArray): JsonObject {
    val s = build("spec", t).toMutableMap()
    val slots = s.getValue("slots").jsonArray.map { it.jsonObject }
    if (s["textGroups"] is JsonNull) {
        val keyed = slots.isNotEmpty() && slots.all { it["group"] !is JsonNull }
        s["textGroups"] = JsonArray(if (keyed) slots.mapIndexed { i, x -> JsonObject(mapOf("indices" to JsonArray(listOf(JsonPrimitive(i))), "prefix" to JsonPrimitive(""), "key" to x.getValue("group"))) } else emptyList())
    }
    s["slots"] = JsonArray(slots.map { JsonObject(it - "group") })
    s["noPanel"] = JsonPrimitive(s["panel"] is JsonNull)
    return JsonObject(s)
}

private fun resolver(r: JsonArray): JsonObject =
    if (r[0].jsonPrimitive.content == "code") JsonObject(mapOf("kind" to r[0], "signature" to r[1]))
    else JsonObject(mapOf("kind" to r[0], "signature" to r[1], "reads" to r[2], "cut" to r[3], "default" to r[4], "enc" to r[5]))

/** Expands one country's compact data to the verbose object [load] reads. */
fun expandCountry(c: JsonObject): JsonObject {
    fun JsonElement.each(f: (JsonElement) -> JsonElement) = JsonObject(jsonObject.mapValues { f(it.value) })
    return JsonObject(mapOf(
        "package" to c.getValue("package"),
        "alphabets" to c.getValue("alphabets").each { alphabet(it.jsonArray) },
        "countries" to c.getValue("countries").each { build("country", it.jsonArray) },
        "themes" to c.getValue("themes").each(::theme),
        "specs" to JsonArray(c.getValue("specs").jsonArray.map { spec(it.jsonArray) }),
        "resolvers" to c.getValue("resolvers").each { resolver(it.jsonArray) },
        "assets" to c.getValue("assets"),
        "gallery" to JsonArray(c.getValue("gallery").jsonArray.map { build("gallery", it.jsonArray) }),
    ))
}
