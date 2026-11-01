package plates.keypad

import kotlin.coroutines.resume
import kotlin.math.roundToInt
import kotlinx.browser.document
import kotlinx.coroutines.suspendCancellableCoroutine
import org.w3c.dom.HTMLButtonElement
import org.w3c.dom.HTMLDialogElement
import org.w3c.dom.HTMLElement
import plates.core.alphabet.PlateAlphabet

/**
 * [D8] A modal `<dialog>` with a scroll-snap list over [alphabet]'s characters. Returns the chosen
 * canonical character (not the rendered glyph), or null when dismissed. Pass it to `onChooseCharacter`.
 */
suspend fun showPlateCharacterPicker(alphabet: PlateAlphabet, initial: String? = null, parent: HTMLElement = document.body!!): String? =
    suspendCancellableCoroutine { cont ->
        val dialog = document.createElement("dialog") as HTMLDialogElement
        val list = document.createElement("div") as HTMLElement
        list.style.cssText = "height:280px;overflow-y:auto;scroll-snap-type:y mandatory;width:200px;margin:auto"
        val items = pickerItems(alphabet)
        var index = items.indexOfFirst { it.value == initial }.coerceAtLeast(0)
        items.forEach { item ->
            val row = document.createElement("div") as HTMLElement
            row.style.cssText = "height:64px;display:flex;align-items:center;justify-content:center;font-size:32px;scroll-snap-align:center;cursor:pointer"
            if (wheelchairGlyph in item.glyph) row.innerHTML = wheelchairIcon(36) else row.textContent = item.glyph
            row.addEventListener("click", { row.scrollIntoView() })
            list.appendChild(row)
        }
        list.addEventListener("scroll", { index = (list.scrollTop / 64).roundToInt().coerceIn(0, items.lastIndex) })
        val ok = document.createElement("button") as HTMLButtonElement
        ok.textContent = "OK"
        ok.style.cssText = "display:block;margin:8px auto 0;font-size:18px"
        ok.addEventListener("click", { dialog.close(items.getOrNull(index)?.value ?: "") })
        dialog.appendChild(list)
        dialog.appendChild(ok)
        dialog.addEventListener("close", {
            dialog.remove()
            if (cont.isActive) cont.resume(dialog.returnValue.ifEmpty { null })
        })
        cont.invokeOnCancellation { dialog.remove() }
        parent.appendChild(dialog)
        dialog.showModal()
        list.scrollTop = index * 64.0
    }
