package plates.ui

import plates.core.input.PlateController
import plates.core.input.PlateInputSource
import plates.core.input.PlateMode
import plates.core.input.SlotBehavior
import plates.core.input.resolveSlotBehavior
import plates.core.theme.PlateTheme
import plates.core.timing.PlateAnimationController
import plates.core.values.PlateCountry
import plates.core.values.PlateSpec
import plates.core.values.Rect
import plates.render.DisplayOp
import plates.render.Frames
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
) {
    val controller = controller ?: PlateController(spec, values)

    private val clock = animation?.let { PartClock(it, now) }

    /** True while an animated part still moves; the host keeps repainting until it clears. */
    val animating get() = clock?.running == true

    val spec get() = controller.spec

    val values get() = controller.values

    fun setValues(values: List<String?>) = controller.setValues(values)

    fun displayList(): List<DisplayOp> = renderPlate(
        spec, values, theme, country ?: spec.country, frames ?: clock?.frames() ?: settledFrames(), mode, inputSource,
        controller.isCompleted, controller.rejection.value,
    )

    /** In input mode, the slots the display list leaves for native inputs. */
    fun slotInputs(): List<SlotInput> {
        if (mode != PlateMode.input) return emptyList()
        return spec.slots.mapIndexedNotNull { i, s ->
            val behavior = resolveSlotBehavior(mode, s.alphabet.input, inputSource)
            if (behavior == SlotBehavior.glyph) null else SlotInput(i, behavior, s.box.rect)
        }
    }

    fun svg(resolveAsset: (String, String) -> String = { p, a -> "packages/$p/$a" }) =
        "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 ${spec.canvasWidth.fmt()} ${spec.canvasHeight.fmt()}\">" +
            opsToSvg(displayList(), resolveAsset) + "</svg>"
}

private fun Double.fmt() = if (this == toLong().toDouble()) toLong().toString() else toString()
