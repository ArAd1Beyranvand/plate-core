package plates.core.values

import plates.core.alphabet.PlateAlphabet
import plates.core.alphabet.TextDirection
import plates.core.alphabet.AlphabetInput
import plates.core.alphabet.splitRunes

enum class Axis { horizontal, vertical }

data class Insets(val left: Double, val top: Double, val right: Double, val bottom: Double)

data class Size(val width: Double, val height: Double)

/** Picks a label's wording from what is typed; null keeps the label's text. Table resolvers become maps. */
typealias PlateLabelResolver = (group: (String) -> String) -> String?

/** Picks a theme from what is typed; T is the render layer's theme type. */
typealias PlateThemeResolver<T> = (base: T, group: (String) -> String) -> T

/** One editable position on a plate. [box].height doubles as the glyph height. */
class PlateSlot(
    val alphabet: PlateAlphabet,
    val box: PlateBox,
    /** Ink for this slot, or null for the theme's. */
    val color: Color? = null,
    val length: Int = 1,
    minLength: Int? = null,
    val spacing: Double = 0.0,
) {
    val minLength: Int = minLength ?: length

    init {
        require(length >= 1) { "A slot holds at least one character." }
        require(this.minLength in 1..length) { "minLength is 1..length." }
    }

    /** Legal, possibly partial, content; a chosen symbol is judged whole. */
    fun accepts(value: String): Boolean {
        if (alphabet.input == AlphabetInput.chosen) return alphabet.accepts(value)
        val characters = splitRunes(value)
        return characters.isNotEmpty() && characters.size <= length && characters.all(alphabet::accepts)
    }

    fun canonical(value: String) = alphabet.canonicalAll(value)

    fun render(value: String) = alphabet.renderAll(value)

    fun isFull(value: String?) = value != null && splitRunes(value).size >= length

    fun isComplete(value: String?) = value != null && splitRunes(value).size >= minLength
}

/** An echo of a slot's value painted elsewhere; owns no position in [PlateSpec.slots]. */
class PlateMirror(
    val source: Int,
    val box: PlateBox,
    val glyphHeight: Double,
    val alphabet: PlateAlphabet? = null,
    val editable: Boolean = false,
)

class PlateRule(val box: PlateBox)

/** The theme's field colour airbrushed over a stripes leaf. */
data class PlateFog(val center: Point, val radii: Size, val opacity: Double = 1.0, val plateau: Double = 0.5)

/** What a [PlateSection] leaf is painted in; the three objects resolve at render time. */
sealed interface PlateFill {
    data class ColorFill(val color: Color) : PlateFill

    /** Parallel bands tilted by [angle] radians; [stops] has one fewer entry than [stripes]. */
    data class StripesFill(
        val stripes: List<PlateFill>, val stops: List<Double>, val angle: Double = 0.0, val fog: PlateFog? = null,
    ) : PlateFill

    object Field : PlateFill
    object Panel : PlateFill
    object Divider : PlateFill
}

val PlateFill.paintsPanel: Boolean
    get() = this is PlateFill.Panel || (this is PlateFill.StripesFill && stripes.any { it is PlateFill.Panel })

/** The paint colour; not meaningful for stripes, paint each stripe. */
fun PlateFill.resolve(field: Color, panel: Color, divider: Color): Color = when (this) {
    is PlateFill.ColorFill -> color
    is PlateFill.StripesFill -> error("paint each stripe")
    PlateFill.Field -> field
    PlateFill.Panel -> panel
    PlateFill.Divider -> divider
}

/** One region of a split; [end] is its far edge along the parent's axis, null on the last part. */
class PlatePart(val section: PlateSection, val end: Double? = null, val divider: Double = 0.0)

class SectionLayout(val leaves: List<Pair<PlateSection, Rect>>, val dividers: List<Rect>)

/** A guillotine tree of columns and rows whose leaves are fills. */
sealed interface PlateSection {
    /** [shape] is an SVG path in leaf-local units. */
    class Leaf(val fill: PlateFill, val shape: String? = null) : PlateSection

    class Split(val axis: Axis, val parts: List<PlatePart>) : PlateSection

    val paintsPanel: Boolean
        get() = when (this) {
            is Leaf -> fill.paintsPanel
            is Split -> parts.any { it.section.paintsPanel }
        }

    /** The leaves and dividers of this tree laid over [bounds], depth-first. */
    fun layout(bounds: Rect): SectionLayout {
        val leaves = mutableListOf<Pair<PlateSection, Rect>>()
        val dividers = mutableListOf<Rect>()
        fun walk(s: PlateSection, r: Rect) {
            if (s is Leaf) {
                leaves.add(s to r)
                return
            }
            s as Split
            val across = s.axis == Axis.horizontal
            var start = if (across) r.left else r.top
            val last = s.parts.size - 1
            for ((i, part) in s.parts.withIndex()) {
                val end = if (i == last) (if (across) r.right else r.bottom) else part.end!!
                walk(
                    part.section,
                    if (across) Rect.fromLTRB(start, r.top, end, r.bottom) else Rect.fromLTRB(r.left, start, r.right, end),
                )
                if (part.divider > 0 && i != last) {
                    val half = part.divider / 2
                    dividers.add(
                        if (across) Rect.fromLTRB(end - half, r.top, end + half, r.bottom)
                        else Rect.fromLTRB(r.left, end - half, r.right, end + half),
                    )
                }
                start = end
            }
        }
        walk(this, bounds)
        return SectionLayout(leaves, dividers)
    }

    companion object {
        val plain: PlateSection = Leaf(PlateFill.Field)
    }
}

class PlateBand(
    val box: PlateBox,
    val color: Color,
    val topCornerRadius: Double = 0.0,
    val bottomCornerRadius: Double = 0.0,
)

/** A fixed image on the plate face: a raster [image] reference, or a [drawing]. */
class PlateDecal(val box: PlateBox, val image: PlateAsset? = null, val drawing: PlateDrawing? = null) {
    init {
        require((image == null) != (drawing == null)) { "A decal is an image or a drawing, not both and not neither." }
    }
}

class PlateLabel(
    val text: String,
    val box: PlateBox,
    val glyphHeight: Double,
    val color: Color? = null,
    val rotated: Boolean = false,
    val lineHeight: Double? = null,
    val fontFamily: String? = null,
    val fontPackage: String? = null,
    val resolve: PlateLabelResolver? = null,
)

class PlatePanel(
    val box: PlateBox,
    val flagScale: Double = 1.0,
    val captionScale: Double = 1.0,
    /** Null means 10% of the panel height on every side. */
    val padding: Insets? = null,
    val direction: Axis = Axis.vertical,
    /** SVG path in panel-box units. */
    val shape: String? = null,
)

class PlateTextGroup(val indices: List<Int>, val prefix: String = "", val key: String? = null)

/** A complete plate design. Equal iff the ids match. */
class PlateSpec<T>(
    val id: String,
    val country: PlateCountry,
    val canvasWidth: Double,
    val canvasHeight: Double,
    val panel: PlatePanel?,
    val slots: List<PlateSlot>,
    val background: PlateSection = PlateSection.plain,
    val bands: List<PlateBand> = emptyList(),
    val rules: List<PlateRule> = emptyList(),
    val labels: List<PlateLabel> = emptyList(),
    val decals: List<PlateDecal> = emptyList(),
    val mirrors: List<PlateMirror> = emptyList(),
    val textDirection: TextDirection = TextDirection.ltr,
    val borderWidthRatioOverride: Double? = null,
    val inkOverride: Color? = null,
    val textGroups: List<PlateTextGroup> = emptyList(),
    val restrictions: List<PlateRestriction> = emptyList(),
    val resolveTheme: PlateThemeResolver<T>? = null,
    val resolveRegion: PlateLabelResolver? = null,
) {
    val slotCount get() = slots.size

    fun slotAt(index: Int): PlateSlot? = slots.getOrNull(index)

    /** [textGroups], or one group per slot when none are declared. */
    val effectiveTextGroups: List<PlateTextGroup>
        get() = textGroups.ifEmpty { slots.indices.map { PlateTextGroup(listOf(it)) } }

    fun groupAt(index: Int) = effectiveTextGroups.firstOrNull { index in it.indices }

    fun groupNamed(key: String) = effectiveTextGroups.firstOrNull { it.key == key }

    fun renderGroup(group: PlateTextGroup, values: List<String?>): String = buildString {
        append(group.prefix)
        for (i in group.indices) append(slotAt(i)?.render(if (i < values.size) values[i] ?: "" else "") ?: "")
    }

    fun nextIndex(index: Int): Int? = if (index >= 0 && index + 1 < slots.size) index + 1 else null

    fun previousIndex(index: Int): Int? = if (index > 0 && index < slots.size) index - 1 else null

    fun indicesOfGroup(key: String): List<Int> = groupNamed(key)?.indices ?: emptyList()

    /** The raw values of the group named [key], concatenated. */
    fun valueOfGroup(key: String, values: List<String?>): String =
        indicesOfGroup(key).filter { it < values.size }.joinToString("") { values[it] ?: "" }

    fun restrictionViolatedBy(values: List<String?>): PlateRestriction? =
        restrictions.firstOrNull { it.matches(valueOfGroup(it.group, values)) }

    fun checkRestrictions(values: List<String?>) {
        restrictionViolatedBy(values)?.let { throw PlateRestrictionException(it) }
    }

    override fun equals(other: Any?) = other is PlateSpec<*> && other.id == id

    override fun hashCode() = id.hashCode()
}
