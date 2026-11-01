package plates.core.input

/** How characters get into a plate slot. Every source but [system] suppresses the platform keyboard. */
enum class PlateInputSource { system, hardwareKeyboard, packageKeypad, host, keypadFirst }

/** Hardware keyboard on desktop, the system IME elsewhere. */
expect fun defaultInputSource(): PlateInputSource
