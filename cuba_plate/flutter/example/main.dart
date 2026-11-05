import 'package:flutter/widgets.dart';
import 'package:plate_core/plate_core.dart';
import 'package:cuba_plate/cuba_plate.dart';

void main() =>
    runApp(PlateExampleApp(spec: CubaPlates.car, theme: CubaThemes.standard));
