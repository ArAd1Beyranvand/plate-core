import 'package:flutter/widgets.dart';
import 'package:plate_core/plate_core.dart';
import 'package:venezuela_plate/venezuela_plate.dart';

void main() => runApp(
  PlateExampleApp(spec: VenezuelaPlates.car, theme: VenezuelaThemes.standard),
);
