package plates.ui

import plates.core.input.PlateController
import plates.core.input.PlateInputSource
import plates.core.input.PlateMode
import plates.core.input.SlotBehavior
import plates.core.input.resolveSlotBehavior
import plates.core.theme.PlateTheme
import plates.core.timing.PlateAnimationController
import plates.core.timing.PlateCurves
import plates.core.values.PlateCountry
import plates.core.values.PlateSpec
import plates.core.values.Rect
import plates.render.DisplayOp
import plates.render.Frames
import plates.render.LIVERY_MS
import plates.render.StaggeredText
import plates.render.lerpTheme
import plates.render.plateTheme
import plates.render.renderPlate
import plates.render.settledFrames

/** Where the UI places a native input over the painted plate [D2]; [box] is in spec units. */
data class SlotInput(val index: Int, val behavior: SlotBehavior, val box: Rect)

/**
 * [D1][D7] The headless half of the web plate: core state in, display list out.
 * State lives in [controller] (a host's, or one made here); painting is [svg],
 * native inputs go at [slotInputs]. The DOM side collects [PlateController.changes].
 */
class PlateCanvas(
    spec: PlateSpec<*>,
    controller: PlateController? = null,
    values: List<String?>? = null,
    var theme: PlateTheme? = null,
    var country: PlateCountry? = null,
    var mode: PlateMode = PlateMode.display,
    var inputSource: PlateInputSource = PlateInputSource.system,
    /** Fixed part frames (H11); when null, [animation] drives them through a [PartClock]. */
    var frames: Frames? = null,
    animation: PlateAnimationController? = null,
    now: () -> Double = { 0.0 },
    /** The slot being edited, whose underline lights. */
    var activeIndex: Int? = null,
    /** The size to draw at this frame, when another canvas owns it (a spec swap's ghost). */
    private val sizeOf: (() -> Pair<Double, Double>)? = null,
) {
    private val time = now
    val controller = controller ?: PlateController(spec, values)

    private val clock = animation?.let { PartClock(it, now) }

    /** True while something still moves (a part, the livery fade, a label's stagger); the host keeps repainting until it clears. */
    val animating get() = clock?.running == true || fading || labels.values.any { it.running }

    private class Tween(val start: PlateTheme, val end: PlateTheme, val at: Double, val ms: Double)

    private var tween: Tween? = null
    private var morph: Pair<PlateTheme, Double>? = null
    private val labels = HashMap<Int, StaggeredText>()
    private val livery = { t: PlateTheme -> listOf(t.plateBackground, t.plateBorder, t.ink, t.dividerColor, t.activeColor, t.inactiveColor) }

    private class Resize(val start: Pair<Double, Double>, val at: Double, val ms: Double)

    private var resize: Resize? = null

    private val fading get() = tween?.let { time() - it.at < it.ms } == true || resize?.let { time() - it.at < it.ms } == true

    /**
     * The face starts as [start] at [size] and tweens to its own colours and size over [ms]: the frame
     * stretches to the size between, the content contain-fits in it. Call before the first paint.
     */
    fun morphFrom(start: PlateTheme, size: Pair<Double, Double>, ms: Double) {
        morph = start to ms
        resize = Resize(size, time(), ms)
    }

    /** The size the plate is drawn at now, in spec units. */
    fun size(): Pair<Double, Double> {
        val w = spec.canvasWidth
        val h = spec.canvasHeight
        val r = resize
        val t = time()
        if (r == null || r.ms <= 0 || t - r.at >= r.ms) return w to h
        val k = PlateCurves.easeInOut.transform((t - r.at) / r.ms)
        return (r.start.first + (w - r.start.first) * k) to (r.start.second + (h - r.start.second) * k)
    }

    /** [H15] The resolved theme now: a change of livery fades from where the last one had got to. */
    fun resolvedTheme(): PlateTheme {
        val target = plateTheme(spec, theme, values)
        if (clock == null) return target
        val t = time()
        val tw = tween
        if (tw == null) tween = morph?.let { Tween(it.first, target, t, it.second) } ?: Tween(target, target, t, 0.0)
        else if (livery(tw.end) != livery(target)) tween = Tween(themeAt(t), target, t, if (spec.resolveTheme != null) LIVERY_MS else 0.0)
        return themeAt(t)
    }

    private fun themeAt(t: Double): PlateTheme {
        val tw = tween!!
        if (tw.ms <= 0 || t - tw.at >= tw.ms) return tw.end
        return lerpTheme(tw.start, tw.end, PlateCurves.easeInOut.transform((t - tw.at) / tw.ms))
    }

    private fun labelText(i: Int, value: String): Pair<String, List<Double>?> =
        if (clock == null) value to null else labels.getOrPut(i) { StaggeredText(value) }.frame(value, time())

    val spec get() = controller.spec

    val values get() = controller.values

    fun setValues(values: List<String?>) = controller.setValues(values)

    fun displayList(): List<DisplayOp> = renderPlate(
        spec, values, theme, country ?: spec.country, frames ?: clock?.frames() ?: settledFrames(), mode, inputSource,
        controller.isCompleted, controller.rejection.value,
        hintAt = { controller.hintAt(it) }, activeIndex = activeIndex, resolvedTheme = resolvedTheme(), labelText = ::labelText,
        size = sizeOf?.invoke() ?: size(),
    )

    /** In input mode, the slots the display list leaves for native inputs. */
    fun slotInputs(): List<SlotInput> {
        if (mode != PlateMode.input) return emptyList()
        return spec.slots.mapIndexedNotNull { i, s ->
            val behavior = resolveSlotBehavior(mode, s.alphabet.input, inputSource)
            if (behavior == SlotBehavior.glyph) null else SlotInput(i, behavior, s.box.rect)
        }
    }

    fun svg(resolveAsset: (String, String) -> String = { p, a -> "packages/$p/$a" }): String {
        val ops = displayList()
        val (w, h) = sizeOf?.invoke() ?: size()
        return "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 ${w.fmt()} ${h.fmt()}\">" + opsToSvg(ops, resolveAsset) + "</svg>"
    }
}

private fun Double.fmt() = if (this == toLong().toDouble()) toLong().toString() else toString()
