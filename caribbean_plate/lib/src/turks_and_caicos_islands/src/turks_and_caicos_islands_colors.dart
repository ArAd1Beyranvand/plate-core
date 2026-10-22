import 'package:flutter/widgets.dart';

/// The colours of the Turks and Caicos plates.
///
/// Only [red] is sampled: the median ink of `Turks___Caicos_car_plate_2019`
/// (`8A0812`), white-balanced in the offline stage. The photo's field came out
/// `CAE4ED`, a blue cast on a white plate, so [white] is written as white. The
/// green, yellow and black are NOT sampled: no photo shows those plates and
/// the article only names the colours.
abstract final class TurksAndCaicosIslandsColors {
  static const Color white = Color(0xFFFFFFFF); // CALIBRATE
  static const Color red = Color(0xFF8A0812);
  static const Color black = Color(0xFF1C1E1E); // CALIBRATE
  static const Color green = Color(0xFF00693E); // CALIBRATE
  static const Color yellow = Color(0xFFF2C500); // CALIBRATE
  static const Color inactive = Color(0xFFB0B0B0);
}
