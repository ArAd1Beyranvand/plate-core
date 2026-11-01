from enum import Enum


class PlateInputSource(Enum):
    SYSTEM = "system"
    HARDWARE_KEYBOARD = "hardwareKeyboard"
    PACKAGE_KEYPAD = "packageKeypad"
    HOST = "host"
    KEYPAD_FIRST = "keypadFirst"


def default_input_source() -> PlateInputSource:
    return PlateInputSource.HARDWARE_KEYBOARD
