package plates.embed

import kotlinx.browser.document
import kotlinx.browser.window
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonArray
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.JsonNull
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.JsonPrimitive
import kotlinx.serialization.json.buildJsonObject
import kotlinx.serialization.json.put
import org.w3c.dom.MessageEvent

@JsName("JSON")
external object JsJson {
    fun parse(s: String): JsAny?
    fun stringify(o: JsAny?): String
}

/** The component end of ports/web/protocol.md: validates what arrives, answers only the origin that sent `init`. */
class Host(
    private val lang: String,
    private val country: String,
    private val version: String,
    private val galleryOrigin: String,
    private val onInit: (JsonObject) -> Unit,
    private val onAction: (String, JsonObject) -> Unit,
) {
    private var host: String? = null
    private var lastHeight = -1

    init {
        window.addEventListener("message", { e ->
            e as MessageEvent
            if (e.source !== window.parent || (host != null && e.origin != host)) return@addEventListener
            val m = runCatching { Json.parseToJsonElement(JsJson.stringify(e.data)) }.getOrNull()
            if (!validate(Dir.H2C, m)) return@addEventListener
            val payload = ((m as JsonObject)["payload"] as JsonObject)
            if ((m["type"] as JsonPrimitive).content == "init") {
                if (host == null) host = e.origin
                onInit(payload)
            } else if (host != null) onAction((payload["name"] as JsonPrimitive).content, payload["args"] as JsonObject)
        })
    }

    private fun send(type: String, payload: JsonObject) {
        val message = buildJsonObject {
            put("ns", "plate-embed")
            put("v", 1)
            put("type", type)
            put("payload", payload)
        }
        window.parent.postMessage(JsJson.parse(message.toString()), host ?: galleryOrigin)
    }

    private fun height() = document.body!!.offsetHeight

    fun hello() = send("hello", buildJsonObject { put("lang", lang); put("country", country); put("version", version) })

    fun progress(stage: String, fraction: Double?) =
        send("progress", buildJsonObject { put("stage", stage); put("fraction", fraction?.let(::JsonPrimitive) ?: JsonNull) })

    fun ready(specs: List<Pair<String, String>>, spec: String) = send("ready", buildJsonObject {
        put("specs", JsonArray(specs.map { (id, label) -> buildJsonObject { put("id", id); put("label", label) } }))
        put("spec", spec)
        put("height", height())
    })

    fun change(spec: String, values: List<String?>, text: String, complete: Boolean, valid: Boolean?) = send("change", buildJsonObject {
        put("spec", spec)
        put("values", JsonArray(values.map { it?.let(::JsonPrimitive) ?: JsonNull }))
        put("text", text)
        put("complete", complete)
        put("valid", valid?.let(::JsonPrimitive) ?: JsonNull)
    })

    fun error(code: String, message: String, fatal: Boolean = false) =
        send("error", buildJsonObject { put("code", code); put("message", message); put("fatal", fatal) })

    /** Posts `resize` when the document height changed since the last call; silent before `init`. */
    fun reportHeight() {
        val h = height()
        if (h != lastHeight && host != null) {
            lastHeight = h
            send("resize", buildJsonObject { put("height", h) })
        }
    }
}
