import 'package:flutter/foundation.dart';

import '../input/plate_controller.dart';

/// How characters get into a plate slot.
enum PlateInputSource {
  /// The platform keyboard (IME).
  system,

  /// Physical keys only; the IME is suppressed.
  hardwareKeyboard,

  /// The `plate_keypad` on-screen keypad; the IME is suppressed.
  packageKeypad,

  /// The host supplies every character through [PlateController]; the IME is
  /// suppressed.
  host,

  /// The on-screen keypad, with physical keys always accepted. Tapping a typed
  /// slot asks for the platform keyboard instead; it stays up while focus
  /// moves between typed slots and drops back when a keypad key is pressed,
  /// focus reaches a chosen slot, or focus leaves the plate. The host shows its keypad unless
  /// [PlateController.systemKeyboardActive].
  keypadFirst,
}

/// Hardware keyboard on desktop, the system IME elsewhere (on web
/// [defaultTargetPlatform] reports the underlying OS).
PlateInputSource defaultInputSource() {
  switch (defaultTargetPlatform) {
    case TargetPlatform.windows:
    case TargetPlatform.linux:
    case TargetPlatform.macOS:
      return PlateInputSource.hardwareKeyboard;
    default:
      return PlateInputSource.system;
  }
}
