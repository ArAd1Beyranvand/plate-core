package plates.render

import plates.core.alphabet.TextDirection
import plates.core.values.Axis
import plates.core.values.Color
import plates.core.values.Insets
import plates.core.values.PlateCountry
import plates.core.values.PlatePanel
import plates.core.values.Rect
import plates.core.values.Size
import kotlin.math.max
import kotlin.math.min

/** The flag fills the cross axis by flagScale, then shrinks to fit the main axis. */
fun flagSize(panel: PlatePanel, country: PlateCountry, innerW: Double, innerH: Double): Size {
    val aspect = country.flagAspectRatio
    if (panel.direction == Axis.horizontal) {
        val h = innerH * panel.flagScale
        return if (h * aspect > innerW) Size(innerW, innerW / aspect) else Size(h * aspect, h)
    }
    val w = innerW * panel.flagScale
    return if (w / aspect > innerH) Size(innerH * aspect, innerH) else Size(w, w / aspect)
}

/** One band of wording: its lines, the box they scale down into, and which edge they hug (-1 or 1). */
class PanelWording(val lines: List<String>, val box: Rect, val alignX: Int)

/** [D1] CountryPanel as plain rects in plate units: flag, then heading and caption. */
class PanelLayout(val block: Rect, val flag: Rect, val heading: PanelWording?, val caption: PanelWording)

fun panelLayout(panel: PlatePanel, country: PlateCountry): PanelLayout {
    val b = panel.box
    val pad = b.height * 0.1
    val p = panel.padding ?: Insets(pad, pad, pad, pad)
    val innerW = b.width - p.left - p.right
    val innerH = b.height - p.top - p.bottom
    val x0 = b.left + p.left
    val y0 = b.top + p.top
    val flag = flagSize(panel, country, innerW, innerH)
    val share = if (country.headingLines.isNotEmpty()) 0.5 else 1.0
    fun heading(box: Rect) = if (share < 1) PanelWording(country.headingLines, box, -1) else null
    if (panel.direction == Axis.horizontal) {
        // Row(spaceBetween), children centred on the cross axis.
        val slack = min(max(innerW - flag.width, 0.0), innerW) * share
        val fy = y0 + (innerH - flag.height) / 2
        val fx = if (share < 1) x0 + (innerW - flag.width) / 2 else x0
        return PanelLayout(
            b.rect,
            Rect.fromLTWH(fx, fy, flag.width, flag.height),
            heading(Rect.fromLTWH(x0, y0, slack, innerH)),
            PanelWording(country.captionLines, Rect.fromLTWH(x0 + innerW - slack, y0, slack, innerH), 1),
        )
    }
    // Column(stretch, spaceBetween), the flag centred across.
    val slack = min(max(innerH - flag.height, 0.0), innerH) * share
    val fy = if (share < 1) y0 + slack else y0
    return PanelLayout(
        b.rect,
        Rect.fromLTWH(x0 + (innerW - flag.width) / 2, fy, flag.width, flag.height),
        heading(Rect.fromLTWH(x0, y0, innerW, slack)),
        PanelWording(country.captionLines, Rect.fromLTWH(x0, y0 + innerH - slack, innerW, slack), -1),
    )
}

private const val CAPTION_FONT_SIZE = 24.0

/** [H12] _PanelWording: lines at 24·captionScale, scaled down (never up) to fit the box. */
private fun paintWording(c: DisplayList, w: PanelWording, color: Color, captionScale: Double) {
    if (w.lines.isEmpty()) return
    val fontSize = CAPTION_FONT_SIZE * captionScale
    val style = TextStyle(fontSize, 1.0, color, "Roboto", 800, 0.25)
    val width = w.lines.maxOf { measureText(it, style) }
    val height = fontSize * w.lines.size
    val k = min(1.0, min(w.box.width / width, w.box.height / height))
    // A FittedBox with no room paints nothing.
    if (!(k > 0)) return
    val left = if (w.alignX < 0) w.box.left else w.box.right - width * k
    c.save()
    c.translate(left, w.box.top + (w.box.height - height * k) / 2)
    c.scale(k)
    for ((i, text) in w.lines.withIndex()) {
        c.text(text, Rect.fromLTWH(0.0, i * fontSize, measureText(text, style), fontSize), TextAlign.start, TextDirection.ltr, style)
    }
    c.restore()
}

/** [D1] CountryPanel: the block (unless the background paints it), heading, flag, caption; cut by the panel shape. */
fun paintPanel(
    c: DisplayList, panel: PlatePanel, country: PlateCountry, ink: Color, paintBlock: Boolean,
    showFlag: Boolean = true, showCaption: Boolean = true,
) {
    val l = panelLayout(panel, country)
    val color = country.panelTextColor ?: ink
    c.save()
    if (panel.shape != null) c.clipPath(shiftPath(panel.shape, panel.box.left, panel.box.top))
    if (paintBlock && (country.panelColor ushr 24) != 0) {
        c.save()
        c.translate(l.block.left, l.block.top)
        c.rect(Rect.fromLTWH(0.0, 0.0, l.block.width, l.block.height), Paint(country.panelColor))
        c.restore()
    }
    if (l.heading != null && showCaption) paintWording(c, l.heading, color, panel.captionScale)
    if (showFlag) paintFlag(c, country.flag, l.flag, country.flagBorderColor)
    if (showCaption) paintWording(c, l.caption, color, panel.captionScale)
    c.restore()
}
