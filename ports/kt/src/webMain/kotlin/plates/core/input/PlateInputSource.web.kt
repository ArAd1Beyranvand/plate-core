package plates.core.input

import kotlinx.browser.window

actual fun defaultInputSource(): PlateInputSource =
    if (window.matchMedia("(pointer: coarse)").matches) PlateInputSource.system else PlateInputSource.hardwareKeyboard
