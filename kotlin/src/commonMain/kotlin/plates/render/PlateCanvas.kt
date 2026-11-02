package plates.render

import plates.core.alphabet.TextDirection
import plates.core.input.PlateInputSource
import plates.core.input.PlateMode
import plates.core.input.SlotBehavior
import plates.core.input.resolveSlotBehavior
import plates.core.theme.PlateTheme
import plates.core.theme.lerpColor
import plates.core.timing.PlateAnimationStyle
import plates.core.timing.PlatePartFrame
import plates.core.timing.PlatePartId
import plates.core.timing.PlatePartPhase
import plates.core.values.PlateBox
import plates.core.values.PlateCountry
import plates.core.values.PlateRestriction
import plates.core.values.PlateSpec
import plates.core.values.PlateThemeResolver
import plates.core.values.RasterPlateAsset
import plates.core.values.Rect
import kotlin.math.min

/** [H15] How long a livery change cross-fades when the spec resolves its theme from the values. */
const val LIVERY_MS = 350.0

/** [H15] _ThemeTween: the six colours the livery cross-fades; ratios and alert come from [b]. */
fun lerpTheme(a: PlateTheme, b: PlateTheme, t: Double) = b.copy(
    plateBackground = lerpColor(a.plateBackground, b.plateBackground, t),
    plateBorder = lerpColor(a.plateBorder, b.plateBorder, t),
    ink = lerpColor(a.ink, b.ink, t),
    dividerColor = lerpColor(a.dividerColor, b.dividerColor, t),
    activeColor = lerpColor(a.activeColor, b.activeColor, t),
    inactiveColor = lerpColor(a.inactiveColor, b.inactiveColor, t),
)

/** [H4] The theme a plate paints with: the spec's overrides on [theme], then its resolver over [values]. */
fun plateTheme(spec: PlateSpec<*>, theme: PlateTheme?, values: List<String?>): PlateTheme {
    var base = theme ?: PlateTheme.standard()
    spec.borderWidthRatioOverride?.let { base = base.copy(borderWidthRatio = it) }
    spec.inkOverride?.let { base = base.copy(ink = it, plateBorder = it, dividerColor = it, activeColor = it) }
    @Suppress("UNCHECKED_CAST")
    val resolve = spec.resolveTheme as PlateThemeResolver<PlateTheme>?
    return resolve?.invoke(base) { spec.valueOfGroup(it, values) } ?: base
}

/** Every part settled, as the vectors render. */
fun settledFrames(style: PlateAnimationStyle = PlateAnimationStyle()): Frames =
    { PlatePartFrame(PlatePartPhase.settled, 1.0, style.motionFor(it)) }

/** Flutter's Stack clips its children to itself only when one of them overflows it. */
private fun clipOverflow(c: DisplayList, w: Double, h: Double, boxes: List<PlateBox>) {
    if (boxes.any { it.left < 0 || it.top < 0 || it.right > w || it.bottom > h }) c.clipRect(Rect(0.0, 0.0, w, h))
}

private fun glyphStyle(fontSize: Double, color: Int, letterSpacing: Double = 0.0) =
    TextStyle(fontSize, 1.0, color, "Roboto", 700, letterSpacing)

/**
 * [D1] PlateCanvas as a display list in spec units: the frame, the content
 * (panel, bands, rules, labels, decals) and the display-mode inputs (mirrors,
 * slots, the restriction banner), each under the rim clip.
 *
 * [country] replaces the spec's chrome; [size] is the view's size, which the frame
 * stretches to and the content contain-fits (the canvas by default).
 */
fun renderPlate(
    spec: PlateSpec<*>,
    values: List<String?>,
    theme: PlateTheme? = null,
    country: PlateCountry = spec.country,
    frames: Frames = settledFrames(),
    mode: PlateMode = PlateMode.display,
    inputSource: PlateInputSource? = null,
    isCompleted: Boolean = spec.slots.withIndex().all { (i, s) -> s.isComplete(values.getOrNull(i)) },
    rejection: PlateRestriction? = null,
    size: Pair<Double, Double>? = null,
    hintAt: ((Int) -> String?)? = null,
    activeIndex: Int? = null,
    /** A livery tween in flight; the plate paints with it instead of resolving its own theme. */
    resolvedTheme: PlateTheme? = null,
    /** A resolved label's wording on show and, mid-stagger, its per-character alphas. */
    labelText: ((Int, String) -> Pair<String, List<Double>?>)? = null,
): List<DisplayOp> {
    val t = resolvedTheme ?: plateTheme(spec, theme, values)
    val w = spec.canvasWidth
    val h = spec.canvasHeight
    fun shown(id: PlatePartId) = !frames(id).hidden
    val group = { k: String -> spec.valueOfGroup(k, values) }
    val c = DisplayList()
    val (vw, vh) = size ?: (w to h)
    val k = min(vw / w, vh / h)
    fun fit() {
        c.translate((vw - w * k) / 2, (vh - h * k) / 2)
        c.scale(k)
    }

    c.save()
    c.scale(vw / w, vh / h)
    paintFrame(c, t, w, h, spec.background, country.panelColor, isCompleted, frames)
    c.restore()
    val rim = rimClip(frameGeometry(t, w, h, frames))

    c.save()
    fit()
    c.clipRRect(rim)
    clipOverflow(c, w, h, listOfNotNull(spec.panel?.box) + spec.bands.map { it.box } + spec.rules.map { it.box } + spec.labels.map { it.box } + spec.decals.map { it.box })
    val panel = spec.panel
    if (panel != null && shown(PlatePartId.panel)) {
        paintPanel(c, panel, country, t.ink, !spec.background.paintsPanel, shown(PlatePartId.flag), shown(PlatePartId.caption))
    }
    for ((i, b) in spec.bands.withIndex()) {
        if (!shown(PlatePartId.band(i))) continue
        val top = b.topCornerRadius
        val bottom = b.bottomCornerRadius
        if (top == 0.0 && bottom == 0.0) c.rect(b.box.rect, Paint(b.color))
        else c.rrect(RRect(b.box.rect, listOf(top, top, top, top, bottom, bottom, bottom, bottom)), Paint(b.color))
    }
    for ((i, r) in spec.rules.withIndex()) {
        c.save()
        c.translate(r.box.left, r.box.top)
        paintDivider(c, Rect(0.0, 0.0, r.box.width, r.box.height), t.dividerColor, frames(PlatePartId.rule(i)))
        c.restore()
    }
    for ((i, l) in spec.labels.withIndex()) {
        if (!shown(PlatePartId.label(i))) continue
        var text = l.resolve?.invoke(group) ?: l.text
        var alphas: List<Double>? = null
        if (l.resolve != null && labelText != null) labelText(i, text).let { text = it.first; alphas = it.second }
        val family = if (l.fontPackage != null) "packages/${l.fontPackage}/${l.fontFamily}" else l.fontFamily ?: "Roboto"
        val g = t.glyphStyle(l.glyphHeight, l.color ?: t.ink)
        val style = TextStyle(g.fontSize, l.lineHeight ?: 1.0, g.color, family, g.fontWeight, 0.0)
        paintTextLine(c, text, l.box.rect, style, spec.textDirection, l.rotated, TextAlign.center, alphas)
    }
    for ((i, d) in spec.decals.withIndex()) {
        if (!shown(PlatePartId.decal(i))) continue
        val drawing = d.drawing
        val image = d.image
        if (drawing != null) {
            c.save()
            c.translate(d.box.left, d.box.top)
            paintDrawing(c, drawing, d.box.width, d.box.height, DrawingFit.contain)
            c.restore()
        } else if (image != null) {
            c.asset(if (image is RasterPlateAsset) "raster" else "svg", image.`package`, image.path, d.box.rect)
        }
    }
    c.restore()

    c.save()
    fit()
    c.clipRRect(rim)
    clipOverflow(c, w, h, spec.mirrors.map { it.box } + spec.slots.map { it.box })
    for ((i, m) in spec.mirrors.withIndex()) {
        val v = values.getOrNull(m.source)
        if (!shown(PlatePartId.mirror(i)) || v.isNullOrEmpty()) continue
        val alphabet = m.alphabet ?: spec.slots[m.source].alphabet
        val g = t.glyphStyle(m.glyphHeight, t.ink)
        paintGlyphRun(c, alphabet.renderAll(v), m.box.rect, glyphStyle(g.fontSize, g.color), alphabet.direction)
    }
    for ((i, s) in spec.slots.withIndex()) {
        if (!shown(PlatePartId.slot(i))) continue
        // [D2] Anything but a glyph is a native input the UI layer places at the slot box; its glyphs,
        // placeholder and underline are still painted here, under the transparent field.
        val field = mode == PlateMode.input && inputSource != null && resolveSlotBehavior(mode, s.alphabet.input, inputSource) != SlotBehavior.glyph
        val v = values.getOrNull(i)
        val g = t.glyphStyle(s.box.height, s.color ?: t.ink, s.spacing)
        val style = glyphStyle(g.fontSize, g.color, g.letterSpacing)
        val shown = if (v.isNullOrEmpty()) "" else s.render(v)
        if (!field) { paintGlyphRun(c, shown, s.box.rect, style, s.alphabet.direction); continue }
        val r = s.box.rect
        val inset = s.box.height * 0.14
        val hint = hintAt?.invoke(i) ?: s.alphabet.placeholder
        paintGlyphRun(c, shown, Rect.fromLTRB(r.left, r.top + inset, r.right, r.bottom - inset), style, s.alphabet.direction, hint to t.inactiveColor)
        c.rect(Rect.fromLTWH(r.left, r.bottom - 1, r.width, 1.0), Paint(if (!v.isNullOrEmpty() || activeIndex == i) t.activeColor else t.inactiveColor))
    }
    if (rejection != null) {
        val bh = h * 0.42
        val top = (h - bh) / 2
        c.rect(Rect.fromLTWH(0.0, top, w, bh), Paint(t.alertColor))
        val style = TextStyle(h * 0.26, 1.0, 0xFFFFFFFF.toInt(), "Roboto", 800, 0.25)
        paintTextLine(c, rejection.reason, Rect.fromLTWH(h * 0.1, top, w - h * 0.2, bh), style, TextDirection.ltr, false, TextAlign.start)
    }
    c.restore()
    return c.ops
}
