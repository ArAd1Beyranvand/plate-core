package plates.render

import java.io.File
import kotlin.math.abs
import kotlin.test.Test
import kotlin.test.fail
import kotlinx.serialization.json.JsonArray
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.JsonNull
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.JsonPrimitive
import kotlinx.serialization.json.booleanOrNull
import kotlinx.serialization.json.contentOrNull
import kotlinx.serialization.json.doubleOrNull
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive
import plates.core.input.PlateController
import plates.core.values.Rect
import plates.countries.countryOf
import plates.countries.themeOf
import plates.loadVectors

private fun col(c: Int) = (c.toLong() and 0xFFFFFFFFL).toDouble()
private fun box(r: Rect) = listOf(r.left, r.top, r.width, r.height)
private fun rr(r: RRect) = box(r.rect) + r.radii

private fun paint(p: Paint): Map<String, Any?> = buildMap {
    put("color", col(p.color))
    p.stroke?.let { put("stroke", it) }
    p.cap?.let { put("cap", it.name) }
    p.join?.let { put("join", it.name) }
    // The fog's gradient is recorded as a flag only.
    p.shader?.let { put("shader", true) }
}

/** An op as the vectors write it, numbers as doubles. */
fun opJson(o: DisplayOp): Map<String, Any?> {
    val body: Map<String, Any?> = when (val d = o.draw) {
        Draw.Save -> mapOf("op" to "save")
        Draw.Restore -> mapOf("op" to "restore")
        is Draw.Layer -> mapOf("op" to "layer", "bounds" to d.bounds?.let(::box), "paint" to paint(d.paint))
        is Draw.ClipRect -> mapOf("op" to "clipRect", "rect" to box(d.rect))
        is Draw.ClipRRect -> mapOf("op" to "clipRRect", "rrect" to rr(d.rrect))
        is Draw.ClipPath -> mapOf("op" to "clipPath", "path" to d.path)
        is Draw.RectOp -> mapOf("op" to "rect", "rect" to box(d.rect), "paint" to paint(d.paint))
        is Draw.RRectOp -> mapOf("op" to "rrect", "rrect" to rr(d.rrect), "paint" to paint(d.paint))
        is Draw.DRRect -> mapOf("op" to "drrect", "outer" to rr(d.outer), "inner" to rr(d.inner), "paint" to paint(d.paint))
        is Draw.PathOp -> mapOf("op" to "path", "path" to d.path, "paint" to paint(d.paint))
        is Draw.Circle -> mapOf("op" to "circle", "center" to listOf(d.cx, d.cy), "radius" to d.radius, "paint" to paint(d.paint))
        is Draw.Text -> mapOf(
            "op" to "text", "text" to d.text, "align" to d.align.name, "direction" to d.direction.name,
            "fontSize" to d.style.fontSize, "height" to d.style.height, "color" to col(d.style.color),
            "fontFamily" to d.style.fontFamily, "fontWeight" to d.style.fontWeight.toDouble(), "letterSpacing" to d.style.letterSpacing,
        )
        is Draw.Asset -> mapOf("op" to "asset", "kind" to d.kind, "package" to d.`package`, "path" to d.path, "box" to box(d.box))
    }
    return body + ("m" to o.m.toList())
}

private fun plain(e: JsonElement): Any? = when (e) {
    is JsonNull -> null
    is JsonArray -> e.map(::plain)
    is JsonObject -> e.mapValues { plain(it.value) }
    is JsonPrimitive -> if (e.isString) e.content else e.booleanOrNull ?: e.doubleOrNull
}

private fun near(a: Any?, b: Any?, t: Double): Boolean = when {
    a is Double && b is Double -> abs(a - b) <= t
    a is List<*> && b is List<*> -> a.size == b.size && a.indices.all { near(a[it], b[it], t) }
    a is Map<*, *> && b is Map<*, *> -> (a.keys + b.keys).all { near(a[it], b[it], t) }
    else -> a == b
}

private val numbers = Regex("-?\\d+(\\.\\d+)?([eE]-?\\d+)?")

/** A path's bounding box in its own units; vectors sample every 0.25, so corners may be cut by half a step. */
private fun pathBox(path: String): List<Double> {
    val n = numbers.findAll(path.substringAfter(':')).map { it.value.toDouble() }.toList()
    val xs = n.filterIndexed { i, _ -> i % 2 == 0 }
    val ys = n.filterIndexed { i, _ -> i % 2 == 1 }
    return if (xs.isEmpty()) emptyList() else listOf(xs.min(), ys.min(), xs.max(), ys.max())
}

private fun channelsNear(x: Double, y: Double) =
    intArrayOf(24, 16, 8, 0).all { s -> abs(((x.toLong() shr s) and 255) - ((y.toLong() shr s) and 255)) <= 1 }

private val identity = Matrix.identity.toList()
private val textKeys = listOf("text", "align", "direction", "fontSize", "height", "color", "fontFamily", "fontWeight", "letterSpacing")

/** The first difference between two display lists, save/restore aside; null when they match. */
fun diff(got: List<Map<String, Any?>>, want: List<Map<String, Any?>>): String? {
    val g = got.filter { it["op"] != "save" && it["op"] != "restore" }
    val w = want.filter { it["op"] != "save" && it["op"] != "restore" }.map { if ("m" in it) it else it + ("m" to identity) }
    for (i in 0 until maxOf(g.size, w.size)) {
        val a = g.getOrNull(i)
        val b = w.getOrNull(i)
        val at = "op $i: got ${a.toString().take(300)}\n want ${b.toString().take(300)}"
        if (a == null || b == null || a["op"] != b["op"]) return at
        when (a["op"]) {
            "text" -> if (!textKeys.all { near(a[it], b[it], 0.01) }) return at
            "path", "clipPath" -> {
                val pa = a["path"] as String
                val pb = b["path"] as String
                if (pa.substringBefore(':') != pb.substringBefore(':') || !near(a["m"], b["m"], 0.01) ||
                    !near(pathBox(pa), pathBox(pb), 0.15) || !near(a["paint"], b["paint"], 0.0)
                ) return at
            }
            else -> {
                var ra = a
                // The completed border's tint rounds per channel through doubles: allow one step.
                if (a["op"] == "drrect" && channelsNear((a["paint"] as Map<*, *>)["color"] as Double, (b["paint"] as Map<*, *>)["color"] as Double)) {
                    ra = a + ("paint" to b["paint"])
                }
                if (!near(ra, b, 0.01)) return at
            }
        }
    }
    return null
}

class RenderTest {
    @Test
    fun vectors() {
        val dir = File(System.getProperty("plates.vectors"), "render")
        val failures = mutableListOf<String>()
        var ran = 0
        for (file in dir.listFiles()!!.filter { it.name.endsWith(".json") }.sorted()) {
            for (c in loadVectors("render/${file.name}")) {
                val i = c.input.jsonObject
                val pkg = i["package"]!!.jsonPrimitive.content
                val loaded = renderSpecOf(pkg, i["spec"]!!.jsonPrimitive.content)
                if (loaded.codeRender) continue
                val spec = loaded.spec
                // Values reach the plate through a controller, which drops what a slot refuses.
                val controller = PlateController(spec, i["values"]!!.jsonArray.map { it.jsonPrimitive.contentOrNull })
                val values = controller.values
                val country = i["country"]?.jsonPrimitive?.contentOrNull?.let {
                    // The code is shared by a package's variants: the gallery entry names the one shown.
                    val gallery = loaded.data["gallery"]!!.jsonArray.map { g -> g.jsonObject }
                        .firstOrNull { g -> g["id"]!!.jsonPrimitive.content == i["gallery"]?.jsonPrimitive?.contentOrNull }
                    val ref = gallery?.get("country")?.jsonPrimitive?.contentOrNull
                    val all = loaded.data["countries"]!!.jsonObject
                    countryOf((ref?.let { all[it] } ?: all.values.first { c -> c.jsonObject["code"]!!.jsonPrimitive.content == it }).jsonObject)
                }
                val size = i["size"]!!.jsonArray.map { it.jsonPrimitive.content.toDouble() }
                val ops = renderPlate(
                    spec, values,
                    theme = i["theme"]?.takeUnless { it is JsonNull }?.jsonObject?.let(::themeOf),
                    country = country ?: spec.country,
                    isCompleted = controller.isCompleted,
                    // The Flutter test surface is 800x600; a wider plate is laid out squeezed into it.
                    size = minOf(size[0], 800.0) to minOf(size[1], 600.0),
                    rejection = spec.restrictionViolatedBy(values),
                )
                ran++
                @Suppress("UNCHECKED_CAST")
                val want = (plain(c.expect) as List<Map<String, Any?>>)
                diff(ops.map(::opJson), want)?.let { failures.add("${file.name} ${c.name}: $it") }
            }
        }
        if (failures.isNotEmpty()) fail("${failures.size}/$ran render cases differ:\n" + failures.take(5).joinToString("\n\n"))
        println("render vectors: $ran cases")
    }
}
