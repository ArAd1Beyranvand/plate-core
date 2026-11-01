from enum import Enum

from .plate_alphabet import AlphabetInput
from .plate_input_source import PlateInputSource


class PlateMode(Enum):
    INPUT = "input"
    DISPLAY = "display"


class SlotBehavior(Enum):
    GLYPH = "glyph"
    IME_FIELD = "imeField"
    HARDWARE_FIELD = "hardwareField"
    EXTERNAL_FIELD = "externalField"
    KEYPAD_FIRST_FIELD = "keypadFirstField"
    SHEET = "sheet"


def resolve_slot_behavior(mode: PlateMode, input: AlphabetInput, source: PlateInputSource) -> SlotBehavior:
    """Pure, as in Dart; the ui layer maps imeField/keypadFirstField to hardwareField on desktop."""
    if mode is PlateMode.DISPLAY:
        return SlotBehavior.GLYPH
    S = PlateInputSource
    if source is S.SYSTEM:
        return SlotBehavior.IME_FIELD if input is AlphabetInput.TYPED else SlotBehavior.SHEET
    if source is S.HARDWARE_KEYBOARD:
        return SlotBehavior.HARDWARE_FIELD
    if source in (S.PACKAGE_KEYPAD, S.HOST):
        return SlotBehavior.EXTERNAL_FIELD
    return SlotBehavior.KEYPAD_FIRST_FIELD
