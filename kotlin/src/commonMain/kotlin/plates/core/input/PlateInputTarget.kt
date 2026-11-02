package plates.core.input

/** What a [PlateController] drives: a plate's focus and navigation. The web adapter implements it over its inputs. */
interface PlateInputTarget {
    val activeIndex: Int?

    /** Whether the platform keyboard has been requested under [PlateInputSource.keypadFirst]. */
    val systemKeyboardActive: Boolean
    fun submitCharacter(character: String)
    fun backspaceCharacter()
    fun focusFirstEmptySlot()
    fun focusSlot(index: Int)
}
