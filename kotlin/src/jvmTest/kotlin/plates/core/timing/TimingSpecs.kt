package plates.core.timing

import java.io.File
import kotlinx.serialization.json.JsonArray
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.contentOrNull
import kotlinx.serialization.json.double
import kotlinx.serialization.json.doubleOrNull
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive
import plates.core.alphabet.TextDirection
import plates.core.values.Axis
import plates.core.values.Insets
import plates.core.values.PlateAsset
import plates.core.values.PlateBand
import plates.core.values.PlateBox
import plates.core.values.PlateCountry
import plates.core.values.PlateDecal
import plates.core.values.PlateFill
import plates.core.values.PlateLabel
import plates.core.values.PlatePanel
import plates.core.values.PlatePart
import plates.core.values.PlateRule
import plates.core.values.PlateSection
import plates.core.values.PlateSpec
import plates.core.values.SvgPlateAsset
import plates.specOf

/**
 * The shared test loader leaves out everything but slots; the timing vectors also need the face, panel, bands,
 * rules, labels and decals, so this reads them from ports/data on top of it.
 */
private val data = File(System.getProperty("plates.vectors"), "../data")
private val raw = HashMap<String, Map<String, JsonObject>>()

private fun JsonElement.box() = jsonArray.map { it.jsonPrimitive.double }.let { PlateBox(it[0], it[1], it[2], it[3]) }
private fun JsonElement?.str() = this?.takeIf { it !is kotlinx.serialization.json.JsonNull }?.jsonPrimitive?.contentOrNull
private fun JsonElement?.num() = this?.takeIf { it !is kotlinx.serialization.json.JsonNull }?.jsonPrimitive?.doubleOrNull
private fun JsonElement?.color() = str()?.toLong()?.toInt()

private fun fill(o: JsonObject): PlateFill = when (o["kind"].str()) {
    "color" -> PlateFill.ColorFill(o["color"].color()!!)
    "field" -> PlateFill.Field
    "panel" -> PlateFill.Panel
    "divider" -> PlateFill.Divider
    else -> PlateFill.StripesFill(o["stripes"]!!.jsonArray.map { fill(it.jsonObject) }, o["stops"]!!.jsonArray.map { it.jsonPrimitive.double })
}

private fun section(o: JsonObject): PlateSection =
    if (o["kind"].str() == "fill") PlateSection.Leaf(fill(o["fill"]!!.jsonObject), o["shape"]?.takeIf { it is JsonObject }?.jsonObject?.get("svg").str())
    else PlateSection.Split(
        if (o["kind"].str() == "columns") Axis.horizontal else Axis.vertical,
        o["parts"]!!.jsonArray.map {
            val p = it.jsonObject
            PlatePart(section(p["section"]!!.jsonObject), p["end"].num(), p["divider"].num()!!)
        },
    )

private val built = HashMap<Pair<String, String>, PlateSpec<Any>>()

/** One instance per spec, so a stripes fill is identical to itself as Dart's const is. */
fun timingSpec(pkg: String, id: String): PlateSpec<Any> = built.getOrPut(pkg to id) { buildSpec(pkg, id) }

private fun buildSpec(pkg: String, id: String): PlateSpec<Any> {
    val file = raw.getOrPut(pkg) {
        Json.parseToJsonElement(File(data, "countries/$pkg.json").readText()).jsonObject["specs"]!!.jsonArray
            .associate { it.jsonObject["id"].str()!! to it.jsonObject }
    }
    val s = file[id]!!
    val base = specOf(pkg, id).spec
    val countries = Json.parseToJsonElement(File(data, "countries/$pkg.json").readText()).jsonObject["countries"]!!.jsonObject
    val c = countries[s["country"].str()!!]!!.jsonObject
    val p = s["panel"]!!.jsonObject
    return PlateSpec(
        id = id,
        country = PlateCountry(c["code"].str()!!, emptyList(), c["panelColor"].color()!!, null),
        canvasWidth = base.canvasWidth,
        canvasHeight = base.canvasHeight,
        panel = if (s["noPanel"]!!.jsonPrimitive.content == "true") null else PlatePanel(
            p["box"]!!.box(), p["flagScale"].num()!!, p["captionScale"].num()!!,
            p["padding"]?.takeIf { it is JsonArray }?.jsonArray?.map { it.jsonPrimitive.double }?.let { Insets(it[0], it[1], it[2], it[3]) },
            if (p["direction"].str() == "horizontal") Axis.horizontal else Axis.vertical,
            p["shape"]?.takeIf { it is JsonObject }?.jsonObject?.get("svg").str(),
        ),
        slots = base.slots,
        background = section(s["background"]!!.jsonObject),
        bands = s["bands"]!!.jsonArray.map {
            val b = it.jsonObject
            PlateBand(b["box"]!!.box(), b["color"].color()!!, b["topCornerRadius"].num()!!, b["bottomCornerRadius"].num()!!)
        },
        rules = s["rules"]!!.jsonArray.map { PlateRule(it.jsonObject["box"]!!.box()) },
        labels = s["labels"]!!.jsonArray.map {
            val l = it.jsonObject
            PlateLabel(
                l["text"].str()!!, l["box"]!!.box(), l["glyphHeight"].num()!!, l["color"].color(), l["rotated"]!!.jsonPrimitive.content == "true",
                l["lineHeight"].num(), l["fontFamily"].str(), l["fontPackage"].str(),
            )
        },
        decals = s["decals"]!!.jsonArray.map { PlateDecal(it.jsonObject["box"]!!.box(), image = SvgPlateAsset("", "")) },
        mirrors = base.mirrors,
        inkOverride = s["inkOverride"].color(),
    )
}
