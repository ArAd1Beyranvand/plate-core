import 'package:flutter/widgets.dart';

/// Each colour is the modal pixel of its region in the Wikipedia artwork. The
/// article calls the commercial characters red; the artwork prints them black
/// and is followed.
abstract final class NigerColors {
  static const Color privateWhite = Color(0xFFFEFEFE);
  static const Color black = Color(0xFF000000);

  static const Color commercialOrange = Color(0xFFFE6A00);

  static const Color dot = Color(0xFF808080);

  static const Color seal = Color(0xFFC0C0C0);

  static const Color inactiveOnLight = Color(0x66666666);
  static const Color inactiveOnOrange = Color(0x66000000);

  // The four colours below belong to plates with no artwork. The article names
  // them; none is sampled from a pixel of those plates.

  static const Color stateBlue = Color(0xFF1F3F9E);

  /// Taken from the flag colours as sampled off the commercial artwork's map.
  static const Color diplomaticGreen = Color(0xFF007E45);
  static const Color diplomaticOrange = Color(0xFFFE6A00);

  static const Color militaryBlack = Color(0xFF000000);
  static const Color militaryWhite = Color(0xFFFFFFFF);

  static const Color inactiveOnGreen = Color(0x66FFFFFF);
  static const Color inactiveOnBlue = Color(0x661F3F9E);
}
