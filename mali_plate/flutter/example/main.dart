import 'package:flutter/widgets.dart';
import 'package:plate_core/plate_core.dart';
import 'package:mali_plate/mali_plate.dart';

void main() => runApp(
  PlateExampleApp(
    spec: maliStandardPlate(),
    theme: MaliThemes.standard,
    validator: const MaliValidator(),
    autoValidate: true,
  ),
);
