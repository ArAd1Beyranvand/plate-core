// Turns a generated country module's data (ports/data, D3) into specs. Shared runtime: no country here (W6, W7).
package plates.countries

import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.JsonNull
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.boolean
import kotlinx.serialization.json.contentOrNull
import kotlinx.serialization.json.double
import kotlinx.serialization.json.int
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive
import kotlinx.serialization.json.long
import plates.core.alphabet.AlphabetInput
import plates.core.alphabet.PlateAlphabet
import plates.core.alphabet.TextDirection
import plates.core.alphabet.splitRunes
import plates.core.theme.PlateTheme
import plates.core.validators.PlateValidator
import plates.core.values.Axis
import plates.core.values.Color
import plates.core.values.Insets
import plates.core.values.PlateAsset
import plates.core.values.PlateBand
import plates.core.values.PlateBox
import plates.core.values.PlateCircleShape
import plates.core.values.PlateCountry
import plates.core.values.PlateCrescentShape
import plates.core.values.PlateDecal
import plates.core.values.PlateDrawing
import plates.core.values.PlateFill
import plates.core.values.PlateFog
import plates.core.values.PlateGraphic
import plates.core.values.PlateLabel
import plates.core.values.PlateLabelResolver
import plates.core.values.PlateMirror
import plates.core.values.PlatePanel
import plates.core.values.PlatePart
import plates.core.values.PlatePolygonShape
import plates.core.values.PlateRectShape
import plates.core.values.PlateRingShape
import plates.core.values.PlateRule
import plates.core.values.PlateSection
import plates.core.values.PlateShape
import plates.core.values.PlateSlot
import plates.core.values.PlateSpec
import plates.core.values.PlateStarRingShape
import plates.core.values.PlateStarShape
import plates.core.values.PlateTextGroup
import plates.core.values.PlateThemeResolver
import plates.core.values.Point
import plates.core.values.RasterPlateAsset
import plates.core.values.Size
import plates.core.values.SvgPlateAsset
import plates.core.values.ValuesRestriction

/** The hand-ported `[D4-code]` names a country wires into its specs. */
class CountryCode(
    val labels: Map<String, PlateLabelResolver> = emptyMap(),
    val themes: Map<String, PlateThemeResolver<PlateTheme>> = emptyMap(),
    val validators: Map<String, () -> PlateValidator> = emptyMap(),
)

/** One `ports/data/countries/<package>.json`, with `alphabets` inlined as ref → alphabet; `expandCountry` builds it. */
class LoadedCountry(
    val pkg: String,
    /** By spec id; ids are unique within a package only. */
    val specs: Map<String, PlateSpec<PlateTheme>>,
    val countries: Map<String, PlateCountry>,
    val themes: Map<String, PlateTheme>,
    val validators: Map<String, () -> PlateValidator>,
    val data: JsonObject,
)

private val JsonElement.isNull get() = this is JsonNull
private fun JsonObject.opt(k: String) = this[k]?.takeUnless { it.isNull }
private fun JsonElement.str() = jsonPrimitive.contentOrNull
private fun JsonElement.d() = jsonPrimitive.double
private fun JsonElement.color(): Color = jsonPrimitive.long.toInt()
private fun JsonElement.box() = jsonArray.map { it.d() }.let { PlateBox(it[0], it[1], it[2], it[3]) }
private fun JsonObject.dbl(k: String) = this[k]!!.d()

fun alphabetOf(a: JsonObject) = PlateAlphabet.listed(
    id = a["id"]!!.str()!!,
    characters = a["characters"]!!.jsonArray.map { it.str()!! },
    input = AlphabetInput.valueOf(a["input"]!!.str()!!),
    isNumeric = a["isNumeric"]!!.jsonPrimitive.boolean,
    glyphs = a["glyphs"]!!.jsonArray.associateTo(LinkedHashMap()) { it.jsonArray[0].str()!! to it.jsonArray[1].str()!! },
    direction = TextDirection.valueOf(a["direction"]!!.str()!!),
    placeholder = a["placeholder"]!!.str()!!,
)

/** The row a table holds for [key] (the strings of the groups it reads), or null: rows as listed, grouped by value, or
 * `trie` (the prefixes whose every key shares a value, then the exact keys that differ; the longest prefix wins). */
private fun rowOf(r: JsonObject): (List<String>) -> JsonElement? {
    val enc = r["enc"]?.jsonObject
    val trie = enc?.get("trie")?.jsonObject
    if (trie != null) {
        fun rows(k: String) = trie[k]!!.jsonArray.associate { it.jsonArray[0].str()!! to it.jsonArray[1] }
        val exact = rows("exact")
        val prefix = rows("prefix")
        return { key -> key[0].let { s -> exact[s] ?: (s.length downTo 0).firstNotNullOfOrNull { prefix[s.take(it)] } } }
    }
    val rows = (enc?.get("groups")?.jsonArray?.flatMap { g -> g.jsonArray[1].jsonArray.map { k -> k.jsonArray.map { it.str()!! } to g.jsonArray[0] } }
        ?: r["table"]!!.jsonArray.map { row -> row.jsonArray[0].jsonArray.map { it.str()!! } to row.jsonArray[1] }).toMap()
    return { key -> rows[key] }
}

/** A `[D4-table]` resolver: the row keyed by the groups it reads (cut to n code points), else the default. */
fun tableResolver(r: JsonObject): ((String) -> String) -> JsonElement? {
    val row = rowOf(r)
    val cut = r["cut"]!!.jsonObject
    val reads = r["reads"]!!.jsonArray.map { it.str()!! }
    return { group ->
        val key = reads.map { g -> cut[g]?.let { splitRunes(group(g)).take(it.jsonPrimitive.int).joinToString("") } ?: group(g) }
        (row(key) ?: r["default"])?.takeUnless { it.isNull }
    }
}

/** A theme, or a theme patch laid over [base]. */
fun themeOf(t: JsonObject, base: PlateTheme = PlateTheme.standard()): PlateTheme {
    fun c(k: String, d: Color) = t.opt(k)?.color() ?: d
    fun r(k: String, d: Double) = t.opt(k)?.d() ?: d
    return PlateTheme(
        c("plateBackground", base.plateBackground), c("plateBorder", base.plateBorder), c("ink", base.ink),
        c("dividerColor", base.dividerColor), r("borderWidthRatio", base.borderWidthRatio),
        r("plateRadiusRatio", base.plateRadiusRatio), c("activeColor", base.activeColor),
        c("inactiveColor", base.inactiveColor), c("alertColor", base.alertColor),
    )
}

private fun shapeOf(s: JsonObject): PlateShape {
    val col = s["color"]!!.color()
    return when (s["kind"]!!.str()) {
        "rect" -> PlateRectShape(s.dbl("left"), s.dbl("top"), s.dbl("width"), s.dbl("height"), col)
        "polygon" -> PlatePolygonShape(s["points"]!!.jsonArray.map { Point(it.jsonArray[0].d(), it.jsonArray[1].d()) }, col)
        "circle" -> PlateCircleShape(s.dbl("cx"), s.dbl("cy"), s.dbl("radius"), col)
        "ring" -> PlateRingShape(s.dbl("cx"), s.dbl("cy"), s.dbl("radius"), s.dbl("width"), col)
        "crescent" -> PlateCrescentShape(s.dbl("cx"), s.dbl("cy"), s.dbl("radius"), s.dbl("biteDx"), s.dbl("biteRadius"), col)
        "star" -> PlateStarShape(s.dbl("cx"), s.dbl("cy"), s.dbl("radius"), col, s["points"]!!.jsonPrimitive.int, s.dbl("innerRatio"), s.dbl("rotation"))
        else -> PlateStarRingShape(s.dbl("cx"), s.dbl("cy"), s.dbl("ringRadius"), s.dbl("starRadius"), s["count"]!!.jsonPrimitive.int, col, s["points"]!!.jsonPrimitive.int, s.dbl("innerRatio"))
    }
}

private fun drawingOf(d: JsonObject) = PlateDrawing(d.dbl("width"), d.dbl("height"), d["shapes"]!!.jsonArray.map { shapeOf(it.jsonObject) })

private fun graphicOf(g: JsonObject): PlateGraphic = when (g["kind"]!!.str()) {
    "drawing" -> drawingOf(g)
    "svg" -> SvgPlateAsset(g["path"]!!.str()!!, g["package"]!!.str()!!)
    else -> RasterPlateAsset(g["path"]!!.str()!!, g["package"]!!.str()!!)
}

fun countryOf(c: JsonObject) = PlateCountry(
    c["code"]!!.str()!!,
    c["captionLines"]!!.jsonArray.map { it.str()!! },
    c["panelColor"]!!.color(),
    c.opt("panelTextColor")?.color(),
    c["headingLines"]!!.jsonArray.map { it.str()!! },
    c.dbl("flagAspectRatio"),
    c.opt("flag")?.jsonObject?.let(::graphicOf),
    c.opt("flagBorderColor")?.color(),
)

private fun fillOf(f: JsonObject): PlateFill = when (f["kind"]!!.str()) {
    "color" -> PlateFill.ColorFill(f["color"]!!.color())
    "field" -> PlateFill.Field
    "panel" -> PlateFill.Panel
    "divider" -> PlateFill.Divider
    else -> PlateFill.StripesFill(
        f["stripes"]!!.jsonArray.map { fillOf(it.jsonObject) },
        f["stops"]!!.jsonArray.map { it.d() },
        f.opt("angle")?.d() ?: 0.0,
        f.opt("fog")?.jsonObject?.let {
            val c = it["center"]!!.jsonArray
            val r = it["radii"]!!.jsonArray
            PlateFog(Point(c[0].d(), c[1].d()), Size(r[0].d(), r[1].d()), it.opt("opacity")?.d() ?: 1.0, it.opt("plateau")?.d() ?: 0.5)
        },
    )
}

private fun pathOf(s: JsonElement?) = s?.takeUnless { it.isNull }?.jsonObject?.let { "${it["fillRule"]!!.str()}:${it["svg"]!!.str()}" }

/** Columns lay out horizontally, rows vertically. */
private fun sectionOf(s: JsonObject): PlateSection = when (s["kind"]!!.str()) {
    "fill" -> PlateSection.Leaf(fillOf(s["fill"]!!.jsonObject), pathOf(s["shape"]))
    else -> PlateSection.Split(
        if (s["kind"]!!.str() == "columns") Axis.horizontal else Axis.vertical,
        s["parts"]!!.jsonArray.map {
            val p = it.jsonObject
            PlatePart(sectionOf(p["section"]!!.jsonObject), p.opt("end")?.d(), p.opt("divider")?.d() ?: 0.0)
        },
    )
}

/** Builds every spec of [json], a country's compact data. */
fun loadCountry(json: String, code: CountryCode = CountryCode()): LoadedCountry =
    load(expandCountry(Json.parseToJsonElement(json).jsonObject), code)

/** Builds every spec of [d], a country's verbose data. A code resolver missing from [code] is left out (the core port cannot run it). */
fun load(d: JsonObject, code: CountryCode = CountryCode()): LoadedCountry {
    val resolvers = d["resolvers"]!!.jsonObject
    val alphabets = d["alphabets"]!!.jsonObject.mapValues { alphabetOf(it.value.jsonObject) }
    val countries = d["countries"]!!.jsonObject.mapValues { countryOf(it.value.jsonObject) }
    fun tableOf(name: JsonElement?) = name?.str()?.let { resolvers[it]!!.jsonObject }?.takeIf { it["kind"]!!.str() == "table" }?.let(::tableResolver)
    fun label(name: JsonElement?): PlateLabelResolver? =
        tableOf(name)?.let { r -> { group -> r(group)?.str() } } ?: name?.str()?.let { code.labels[it] }
    fun theme(name: JsonElement?): PlateThemeResolver<PlateTheme>? =
        tableOf(name)?.let { r -> { base, group -> r(group)?.jsonObject?.let { themeOf(it, base) } ?: base } } ?: name?.str()?.let { code.themes[it] }
    val specs = d["specs"]!!.jsonArray.associate { e ->
        val s = e.jsonObject
        val p = s.opt("panel")?.jsonObject
        s["id"]!!.str()!! to PlateSpec(
            id = s["id"]!!.str()!!,
            country = countries.getValue(s["country"]!!.str()!!),
            canvasWidth = s.dbl("canvasWidth"),
            canvasHeight = s.dbl("canvasHeight"),
            panel = if (s["noPanel"]!!.jsonPrimitive.boolean || p == null) null else PlatePanel(
                p["box"]!!.box(), p.dbl("flagScale"), p.dbl("captionScale"),
                p.opt("padding")?.jsonArray?.map { it.d() }?.let { Insets(it[0], it[1], it[2], it[3]) },
                Axis.valueOf(p["direction"]!!.str()!!), pathOf(p["shape"]),
            ),
            slots = s["slots"]!!.jsonArray.map {
                val x = it.jsonObject
                PlateSlot(alphabets.getValue(x["alphabet"]!!.str()!!), x["box"]!!.box(), x.opt("color")?.color(), x["length"]!!.jsonPrimitive.int, x["minLength"]!!.jsonPrimitive.int, x.dbl("spacing"))
            },
            background = sectionOf(s["background"]!!.jsonObject),
            bands = s["bands"]!!.jsonArray.map {
                val b = it.jsonObject
                PlateBand(b["box"]!!.box(), b["color"]!!.color(), b.opt("topCornerRadius")?.d() ?: 0.0, b.opt("bottomCornerRadius")?.d() ?: 0.0)
            },
            rules = s["rules"]!!.jsonArray.map { PlateRule(it.jsonObject["box"]!!.box()) },
            labels = s["labels"]!!.jsonArray.map {
                val l = it.jsonObject
                PlateLabel(
                    l["text"]!!.str()!!, l["box"]!!.box(), l.dbl("glyphHeight"), l.opt("color")?.color(), l["rotated"]!!.jsonPrimitive.boolean,
                    l.opt("lineHeight")?.d(), l.opt("fontFamily")?.str(), l.opt("fontPackage")?.str(), label(l.opt("resolve")),
                )
            },
            decals = s["decals"]!!.jsonArray.map {
                val x = it.jsonObject
                PlateDecal(x["box"]!!.box(), x.opt("image")?.jsonObject?.let { g -> graphicOf(g) as PlateAsset }, x.opt("drawing")?.jsonObject?.let(::drawingOf))
            },
            mirrors = s["mirrors"]!!.jsonArray.map {
                val m = it.jsonObject
                PlateMirror(m["source"]!!.jsonPrimitive.int, m["box"]!!.box(), m.dbl("glyphHeight"), m.opt("alphabet")?.str()?.let(alphabets::getValue), m["editable"]!!.jsonPrimitive.boolean)
            },
            textDirection = TextDirection.valueOf(s["textDirection"]!!.str()!!),
            borderWidthRatioOverride = s.opt("borderWidthRatioOverride")?.d(),
            inkOverride = s.opt("inkOverride")?.color(),
            textGroups = s["textGroups"]!!.jsonArray.map {
                val g = it.jsonObject
                PlateTextGroup(g["indices"]!!.jsonArray.map { i -> i.jsonPrimitive.int }, g["prefix"]!!.str()!!, g.opt("key")?.str())
            },
            restrictions = s["restrictions"]!!.jsonArray.map {
                val r = it.jsonObject
                ValuesRestriction(r["group"]!!.str()!!, r["values"]!!.jsonArray.map { v -> v.str()!! }, r["reason"]!!.str()!!)
            },
            resolveTheme = theme(s.opt("resolveTheme")),
            resolveRegion = label(s.opt("resolveRegion")),
        )
    }
    val themes = d["themes"]!!.jsonObject.mapValues { themeOf(it.value.jsonObject) }
    return LoadedCountry(d["package"]!!.str()!!, specs, countries, themes, code.validators, d)
}
