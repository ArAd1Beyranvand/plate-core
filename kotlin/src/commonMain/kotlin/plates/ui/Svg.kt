package plates.ui

import plates.core.alphabet.TextDirection
import plates.render.DisplayOp
import plates.render.Draw
import plates.render.Matrix
import plates.render.Paint
import plates.render.RRect
import plates.render.TextAlign
import plates.render.n4
import kotlin.math.roundToInt

/** [D1][H14] One SVG tree for the whole plate: a display list painted as nested groups. */

private fun css(c: Int) =
    "rgba(${(c ushr 16) and 255},${(c ushr 8) and 255},${c and 255},${n4(((c ushr 24) and 255) / 255.0)})"

private fun spans(d: Draw.Text): String {
    val a = d.alphas ?: return attr(d.text)
    var i = 0
    return d.text.map { ch -> "<tspan fill-opacity=\"${((a.getOrNull(i++) ?: 1.0) * 1000).roundToInt() / 1000.0}\">${attr(ch.toString())}</tspan>" }.joinToString("")
}

private fun attr(s: String) = s.replace("&", "&amp;").replace("<", "&lt;").replace("\"", "&quot;")

private fun tf(m: Matrix) = if (m == Matrix.identity) "" else " transform=\"matrix(${m.toList().joinToString(" ") { n4(it) }})\""

/** An rrect as path data; each corner takes its own x/y radii. */
private fun rrectD(r: RRect): String {
    val (l, t) = r.rect.left to r.rect.top
    val (rt, b) = r.rect.right to r.rect.bottom
    val (tlx, tly, trx, try_) = r.radii
    val (brx, bry, blx, bly) = r.radii.drop(4)
    return listOf(
        "M${l + tlx} $t H${rt - trx} A$trx $try_ 0 0 1 $rt ${t + try_} V${b - bry} A$brx $bry 0 0 1 ${rt - brx} $b",
        "H${l + blx} A$blx $bly 0 0 1 $l ${b - bly} V${t + tly} A$tlx $tly 0 0 1 ${l + tlx} $t Z",
    ).joinToString(" ")
}

private fun rectAttrs(m: Matrix, r: plates.core.values.Rect) = "${tf(m)} x=\"${r.left}\" y=\"${r.top}\" width=\"${r.width}\" height=\"${r.height}\""

/**
 * The display list as the inside of an `<svg>`. Clips stay open to the matching restore,
 * as on a canvas; [resolveAsset] turns a package asset into a URL the host serves.
 */
fun opsToSvg(ops: List<DisplayOp>, resolveAsset: (String, String) -> String = { p, a -> "packages/$p/$a" }): String {
    val defs = StringBuilder()
    val out = StringBuilder()
    var n = 0
    fun id() = "p${n++}"
    val open = mutableListOf(0)
    fun clip(shape: String) {
        val c = id()
        defs.append("<clipPath id=\"$c\">$shape</clipPath>")
        out.append("<g clip-path=\"url(#$c)\">")
        open[open.size - 1]++
    }
    fun fill(p: Paint): String {
        if (p.stroke != null) {
            return " fill=\"none\" stroke=\"${css(p.color)}\" stroke-width=\"${p.stroke}\" stroke-linecap=\"${p.cap?.name ?: "butt"}\" stroke-linejoin=\"${p.join?.name ?: "miter"}\""
        }
        val fog = p.shader ?: return " fill=\"${css(p.color)}\""
        val g = id()
        val c = css(fog.color)
        defs.append(
            "<radialGradient id=\"$g\" cx=\"0\" cy=\"0\" r=\"1\" gradientUnits=\"userSpaceOnUse\"><stop offset=\"0\" stop-color=\"$c\"/>" +
                "<stop offset=\"${fog.plateau}\" stop-color=\"$c\"/><stop offset=\"1\" stop-color=\"${css(fog.color and 0xFFFFFF)}\"/></radialGradient>",
        )
        return " fill=\"url(#$g)\""
    }
    for (o in ops) {
        val m = tf(o.m)
        when (val d = o.draw) {
            Draw.Save -> open.add(0)
            is Draw.Layer -> {
                open.add(1)
                out.append("<g opacity=\"${n4(((d.paint.color ushr 24) and 255) / 255.0)}\">")
            }
            Draw.Restore -> out.append("</g>".repeat(open.removeAt(open.size - 1)))
            is Draw.ClipRect -> clip("<rect${rectAttrs(o.m, d.rect)}/>")
            is Draw.ClipRRect -> clip("<path$m d=\"${rrectD(d.rrect)}\"/>")
            is Draw.ClipPath -> clip("<path$m clip-rule=\"${d.path.substringBefore(':')}\" d=\"${d.path.substringAfter(':')}\"/>")
            is Draw.RectOp -> out.append("<rect${rectAttrs(o.m, d.rect)}${fill(d.paint)}/>")
            is Draw.RRectOp -> out.append("<path$m d=\"${rrectD(d.rrect)}\"${fill(d.paint)}/>")
            is Draw.DRRect -> out.append("<path$m fill-rule=\"evenodd\" d=\"${rrectD(d.outer)} ${rrectD(d.inner)}\"${fill(d.paint)}/>")
            is Draw.PathOp -> out.append("<path$m fill-rule=\"${d.path.substringBefore(':')}\" d=\"${d.path.substringAfter(':')}\"${fill(d.paint)}/>")
            is Draw.Circle -> out.append("<circle$m cx=\"${d.cx}\" cy=\"${d.cy}\" r=\"${d.radius}\"${fill(d.paint)}/>")
            is Draw.Text -> {
                // [H12] Line height 1 from the box top: the baseline sits at about 0.8 em.
                val b = d.box
                val x = if (d.align == TextAlign.center) b.left + b.width / 2 else if (d.direction == TextDirection.rtl) b.right else b.left
                val anchor = if (d.align == TextAlign.center) "middle" else "start"
                val s = d.style
                out.append(
                    "<text$m x=\"$x\" y=\"${b.top + b.height / 2}\" dominant-baseline=\"central\" text-anchor=\"$anchor\" direction=\"${d.direction}\"" +
                        " font-family=\"${attr(s.fontFamily)}\" font-size=\"${s.fontSize}\" font-weight=\"${s.fontWeight}\"" +
                        " letter-spacing=\"${s.letterSpacing}\" fill=\"${css(s.color)}\">${spans(d)}</text>",
                )
            }
            is Draw.Asset -> out.append(
                "<image${rectAttrs(o.m, d.box)} preserveAspectRatio=\"xMidYMid meet\" href=\"${attr(resolveAsset(d.`package`, d.path))}\"/>",
            )
        }
    }
    out.append("</g>".repeat(open.sum()))
    return "<defs>$defs</defs>$out"
}
