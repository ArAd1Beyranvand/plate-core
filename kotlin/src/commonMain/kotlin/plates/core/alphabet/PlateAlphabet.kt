package plates.core.alphabet

enum class TextDirection { ltr, rtl }

enum class AlphabetInput {
    /** Typed into a text field. */
    typed,

    /** Picked from a chooser or fed in by the host, for characters absent from a normal keyboard. */
    chosen,
}

/** [value] as code points. */
fun codePoints(value: String): List<Int> {
    val out = ArrayList<Int>(value.length)
    var i = 0
    while (i < value.length) {
        val c = value[i]
        if (c.isHighSurrogate() && i + 1 < value.length && value[i + 1].isLowSurrogate()) {
            out.add(((c.code - 0xD800) shl 10) + (value[i + 1].code - 0xDC00) + 0x10000)
            i += 2
        } else {
            out.add(c.code)
            i++
        }
    }
    return out
}

fun fromCodePoint(cp: Int): String {
    if (cp < 0x10000) return cp.toChar().toString()
    val v = cp - 0x10000
    return charArrayOf((0xD800 + (v shr 10)).toChar(), (0xDC00 + (v and 0x3FF)).toChar()).concatToString()
}

/** [value] one string per code point. */
fun splitRunes(value: String): List<String> = codePoints(value).map(::fromCodePoint)

private fun tokens(pattern: String): List<String> = buildList {
    for (token in pattern.split(' ')) {
        if (token.isEmpty()) continue
        val runes = codePoints(token)
        if (runes.size == 3 && runes[1] == 0x2D) {
            for (r in runes[0]..runes[2]) add(fromCodePoint(r))
        } else {
            add(token)
        }
    }
}

/** The characters a slot accepts and how they are rendered. Equal iff the ids match. */
class PlateAlphabet private constructor(
    val id: String,
    private val source: () -> List<String>,
    val input: AlphabetInput,
    val isNumeric: Boolean,
    /** Storage form to display form, in insertion order; the first key wins on a shared glyph. */
    val glyphs: Map<String, String>,
    val direction: TextDirection,
    val placeholder: String,
) {
    /** Every legal character in canonical (storage) form, in picker order. */
    val characters: List<String> by lazy(source)

    private val set: Set<String> by lazy { characters.toSet() }

    fun accepts(value: String): Boolean = canonical(value) in set

    /** [value] folded to storage form; anything unrecognised is returned unchanged. */
    fun canonical(value: String): String {
        if (value in set) return value
        for ((key, glyph) in glyphs) if (glyph == value) return key
        val upper = value.uppercase()
        return if (upper != value && upper in set) upper else value
    }

    fun render(value: String): String = glyphs[value] ?: value

    fun renderAll(value: String): String = glyphs[value] ?: splitRunes(value).joinToString("") { render(it) }

    fun canonicalAll(value: String): String {
        val whole = canonical(value)
        return if (whole in set) whole else splitRunes(value).joinToString("") { canonical(it) }
    }

    override fun equals(other: Any?) = other is PlateAlphabet && other.id == id

    override fun hashCode() = id.hashCode()

    companion object {
        fun listed(
            id: String, characters: List<String>, input: AlphabetInput, isNumeric: Boolean,
            glyphs: Map<String, String> = emptyMap(), direction: TextDirection = TextDirection.ltr,
            placeholder: String = "?",
        ) = PlateAlphabet(id, { characters.toList() }, input, isNumeric, glyphs, direction, placeholder)

        /** `X-Y` tokens are code point ranges; excluded tokens are removed from the included ones. */
        fun pattern(
            id: String, include: String, exclude: String = "", input: AlphabetInput, isNumeric: Boolean,
            glyphs: Map<String, String> = emptyMap(), direction: TextDirection = TextDirection.ltr,
            placeholder: String = "?",
        ) = PlateAlphabet(
            id, { val drop = tokens(exclude).toSet(); tokens(include).filter { it !in drop } },
            input, isNumeric, glyphs, direction, placeholder,
        )

        val latinDigits = pattern(id = "latin.digits", include = "0-9", input = AlphabetInput.typed, isNumeric = true)
        val latinUppercase = pattern(id = "latin.upper", include = "A-Z", input = AlphabetInput.typed, isNumeric = false)
    }
}
