package plates.embed

import kotlinx.serialization.json.JsonArray
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.JsonNull
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.JsonPrimitive
import kotlinx.serialization.json.booleanOrNull
import kotlinx.serialization.json.doubleOrNull
import kotlinx.serialization.json.intOrNull

/** ports/web/protocol.md: the envelope and payload rules every receiver shares. */
enum class Dir { C2H, H2C }

private val c2h = setOf("hello", "ready", "resize", "change", "progress", "error")
private val h2c = setOf("init", "action")
private val langs = setOf("flutter", "typescript", "kotlin", "python")
private val actions = setOf("setSpec", "setValues", "clear", "focus", "setTheme", "leave")

private fun JsonElement?.str() = this is JsonPrimitive && isString
private fun JsonElement?.bool() = this is JsonPrimitive && !isString && booleanOrNull != null
private fun JsonElement?.height() = this is JsonPrimitive && !isString && (doubleOrNull ?: -1.0) >= 0.0
private fun JsonElement?.values() = this is JsonArray && all { it is JsonNull || it.str() }

private fun payloadOk(type: String, p: JsonObject): Boolean = when (type) {
    "hello" -> p["lang"].let { it.str() && (it as JsonPrimitive).content in langs } && p["country"].str() && p["version"].str()
    "ready" -> (p["specs"] as? JsonArray)?.all { it is JsonObject && it["id"].str() && it["label"].str() } == true &&
        p["spec"].str() && p["height"].height()
    "resize" -> p["height"].height()
    "change" -> p["spec"].str() && p["values"].values() && p["text"].str() && p["complete"].bool() &&
        (p["valid"] is JsonNull || p["valid"].bool())
    "progress" -> p["stage"].str() && p["fraction"].let { it is JsonNull || (it is JsonPrimitive && (it.doubleOrNull ?: -1.0) in 0.0..1.0) }
    "error" -> p["code"].str() && p["message"].str() && p["fatal"].bool()
    "init" -> (p["spec"] == null || p["spec"].str()) && (p["values"] == null || p["values"].values()) &&
        (p["theme"] as? JsonPrimitive)?.content.let { it == "light" || it == "dark" } && p["theme"].str() &&
        p["locale"].str() && p["keypad"].bool()
    "action" -> p["name"].let { it.str() && (it as JsonPrimitive).content in actions } && p["args"] is JsonObject
    else -> false
}

/** True iff [m] is a well-formed message travelling in direction [dir]. */
fun validate(dir: Dir, m: JsonElement?): Boolean {
    if (m !is JsonObject || !m["ns"].str() || (m["ns"] as JsonPrimitive).content != "plate-embed") return false
    if ((m["v"] as? JsonPrimitive)?.let { !it.isString && it.intOrNull == 1 && it.content == "1" } != true) return false
    val type = m["type"]
    val p = m["payload"]
    if (!type.str() || p !is JsonObject) return false
    val t = (type as JsonPrimitive).content
    return t in (if (dir == Dir.C2H) c2h else h2c) && payloadOk(t, p)
}
