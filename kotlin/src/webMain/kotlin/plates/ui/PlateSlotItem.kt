package plates.ui

import kotlinx.browser.document
import kotlinx.browser.window
import org.w3c.dom.HTMLInputElement
import plates.core.input.SlotBehavior

/**
 * [D8] A native `<input>` over one slot box: transparent text (the glyph run is painted under it),
 * caret in [activeColor]; keypad behaviours open no IME. Boxes are percent of the canvas.
 */
fun slotInputElement(slot: SlotInput, value: String, canvasWidth: Double, canvasHeight: Double, activeColor: String = "black"): HTMLInputElement {
    val input = document.createElement("input") as HTMLInputElement
    val b = slot.box
    input.value = value
    input.setAttribute("data-slot", slot.index.toString())
    input.setAttribute("autocomplete", "off")
    input.spellcheck = false
    if (slot.behavior == SlotBehavior.externalField || slot.behavior == SlotBehavior.keypadFirstField) input.setAttribute("inputmode", "none")
    if (slot.behavior == SlotBehavior.sheet) input.readOnly = true
    input.style.apply {
        position = "absolute"
        left = "${b.left / canvasWidth * 100}%"
        top = "${b.top / canvasHeight * 100}%"
        width = "${b.width / canvasWidth * 100}%"
        height = "${b.height / canvasHeight * 100}%"
        background = "transparent"
        border = "0"
        padding = "0"
        outline = "none"
        color = "transparent"
        textAlign = "center"
        setProperty("caret-color", "transparent")
    }
    return input
}

/** [H14] Focus without scrolling the page, as _HoldsPageStill did. */
fun focusSlot(input: HTMLInputElement) {
    val x = window.scrollX
    val y = window.scrollY
    input.focus()
    window.scrollTo(x, y)
}
