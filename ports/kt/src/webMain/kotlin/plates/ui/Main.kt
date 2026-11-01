package plates.ui

import kotlinx.browser.document

/** Shared by js and wasmJs; the SVG/DOM painter over the display list lives here. */
fun main() {
    document.body?.setAttribute("data-plates", plates.LIBRARY)
}
